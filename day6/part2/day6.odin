package day6

import "core:fmt"
import "core:testing"
import lib "../../."
import "../../../casey-cpu/profiler"
import "core:bytes"

main :: proc() {
    profiler.start_profile()
    lib.run(process)
    profiler.end_profile()
}

process :: proc(file: ^[]byte) -> int {
    profiler.time_function(#procedure)
    res := 1

    time: int
    distance: int
    index := 0

    arr := time
    num := 0
    for i := 11; i < len(file); i += 1 {
        switch file[i] {
        case '0'..='9':
            num = num * 10 + int(file[i] - '0')

        case '\n':
            time = num
            num = 0
        }
    }
    distance = num

    won := 0
    for k in 1..<time {
        if (time - k) * k > distance {
            res = time - (k - 1) * 2
            break
        }
    }

    if res % 2 == 0 {
        res -= 1
    }
    return res
}


@test
test_process :: proc(t: ^testing.T) {
    file := `Time:        7      15     30
Distance:   9     40     200`
    
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 71503
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

