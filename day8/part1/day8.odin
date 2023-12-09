package day8

import lib "../../."
import "core:fmt"
import "core:testing"
import "../../../casey-cpu/profiler"
import "core:strings"

main :: proc() {
    lib.run(process)
}

process :: proc(file: ^[]byte) -> int {
    profiler.time_function(#procedure)
    res: int

    steps := make([dynamic]u8, 0, 250)
    defer delete(steps)

    i := 0
    for ; file[i] != '\n'; i += 1 {
        char := file[i]
        if char == 'L' {
            append(&steps, 0)
        } else if char == 'R' {
            append(&steps, 1)
        }
    }
    i += 1

    network := make(map[string][2]string)
    defer delete(network)

    key := ""
    starter := "AAA"
    last := ""
    for ; i < len(file); i += 1 {
        switch file[i] {
        case 'A'..='Z': 

            key = transmute(string)file[i:i+3]
            i += 3

            last = key

        case '=': 
            left, right := parse_remaining_sentence(file, &i)
            network[key] = [2]string{left, right}
        }
    }

    step_index := 0
    for {
        starter = network[starter][steps[step_index]]
        res += 1
        if starter == "ZZZ" {
            break
        }
        step_index = (step_index + 1) % len(steps)
    }
    
    return res
}

parse_remaining_sentence :: proc(file: ^[]byte, i: ^int) -> (string, string) {
    i^ += 3
    value1 := transmute(string)file[i^:i^+3]
    i^ += 5

    value2 := transmute(string)file[i^:i^+3]
    i^ += 4

    return value1, value2
}

@test
test_process :: proc(t: ^testing.T) {
    file := `RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)`
    
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 2
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_2 :: proc(t: ^testing.T) {
    file := `LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)`
    
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 6
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

