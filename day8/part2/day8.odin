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
    starter := make([dynamic]string)
    defer delete(starter)

    last := ""
    for ; i < len(file); i += 1 {
        switch file[i] {
        case '0'..='9', 'A'..='Z': 
            key = transmute(string)file[i:i+3]
            if key[2] == 'A' do append(&starter, key)
            i += 3
            last = key

        case '=': 
            left, right := parse_remaining_sentence(file, &i)
            network[key] = [2]string{left, right}
        }
    }

    step_index := 0
    current := ""
    found_z := 0
    len_s := len(starter)

    res_dict: map[string]int
    res_arr: [6]int
    arr_index := 0
    for {
        res += 1
        loop: for s in &starter {
            s = network[s][steps[step_index]]
            if s[2] == 'Z' {
                for elem in res_arr {
                    if res == elem {
                        continue loop
                    }
                }
                res_arr[arr_index] = res
                arr_index += 1
                //res_dict[s] = res
            }
        }

        if arr_index == 6 {
            res = lcm(res_arr[0], lcm(res_arr[1], lcm(res_arr[2], lcm(res_arr[3], lcm(res_arr[4], res_arr[5])))))
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

lcm :: proc(n1: int, n2: int) -> (res: int) {
    if n1 == 0 || n2 == 0 {
        return n1 + n2
    }
    
    x := gcd(n1, n2)
    return (n1 * n2) / x
}

gcd :: proc(n1, n2: int) -> int {
    if n1 == 0 || n2 == 0 {
        return n1 + n2
    }

    big := max(n1, n2)
    small := min(n1, n2)
    return gcd(big % small, small)
}


@test
test_process :: proc(t: ^testing.T) {
    file := `LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)`
    
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 6
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

