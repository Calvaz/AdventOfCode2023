package day6

import "core:fmt"
import "core:testing"
import lib "../../."
import "../../../casey-cpu/profiler"

main :: proc() {
    profiler.start_profile()
    lib.run(process)
    profiler.end_profile()
}

process :: proc(file: ^[]byte) -> int {
    profiler.time_function(#procedure)
    res := 1

    time: [4]int
    distance: [4]int
    index := 0

    arr := &time
    for i := 11; i < len(file); i += 1 {
        switch file[i] {
        case '0'..='9':
            num: int
            num, i = lib.get_digits(file, i)
            arr[index] = num
            index += 1

        case '\n':
            arr = &distance
            index = 0
        }
    }

    for i := 0; i < len(time); i += 1 {
        won := 0
        for k := 1; k < time[i]; k += 1 {
            if (time[i] - k) * k > distance[i] {
                won += 1
            }
        }
        if won != 0 {
            res *= won
        }
    }
    return res
}


@test
test_process :: proc(t: ^testing.T) {
    file := `Time:        7      15     30
Distance:   9     40     200`
    
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 288
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}
