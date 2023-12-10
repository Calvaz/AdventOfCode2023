package day9

import lib "../../."
import "core:fmt"
import "core:testing"
import "../../../casey-cpu/profiler"
import "core:math"
import "core:mem"
import "core:runtime"

main :: proc() {
    lib.run(process)
}

process :: proc(file: ^[]byte) -> (res: int) {
    profiler.time_function(#procedure)
    
    arr := make([dynamic][dynamic]int, 0, 200)
    append(&arr, make([dynamic]int, 0, 10))
    defer destroy_arr(arr)

    next_negative := false
    for i := 0; i < len(file); i += 1 {
        switch file[i] {
        case '0'..='9':
            num: int
            num, i = lib.get_digits(file, i)
            if next_negative {
                num *= -1
                next_negative = false
            }
            append(&arr[len(arr) - 1], num)

        case '-':
            next_negative = true

        case '\n':
            append(&arr, make([dynamic]int, 0, 10))
        }
    }

    {
        //arena: mem.Arena
        //buffer: [39192]byte
        //mem.arena_init(&arena, buffer[:])
        //allocator := mem.arena_allocator(&arena)

        for i in 0..<len(arr) {
            num := dive(&arr[i])
            res += (num + arr[i][len(arr[i]) - 1])
        }
    }
    return res
}

dive :: proc(line: ^[dynamic]int, allocator: runtime.Allocator = context.allocator) -> (res: int) {
    context.allocator = allocator
    if len(line) == 0 {
        return 0
    }
    num_zeros := 0
    new_arr := make([dynamic]int, 0, len(line) - 1)
    defer delete(new_arr)

    if line[0] == 0 do num_zeros += 1
    if num_zeros == len(line) do return 0

    for i in 1..<len(line) {
        if line[i] == 0 do num_zeros += 1
        if num_zeros == len(line) do return 0

        n1 := line[i - 1]
        n2 := line[i]
        append(&new_arr, n2 - n1)
    }
    num := dive(&new_arr, allocator)
    return new_arr[len(new_arr) - 1] + num
}

destroy_arr :: proc(arr: [dynamic][dynamic]int) {
    for elem in arr {
        delete(elem)
    }
    delete(arr)
}

@test
test_process :: proc(t: ^testing.T) {
    file := `0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45`
    
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 114
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

