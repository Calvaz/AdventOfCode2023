package day11

import lib "../../."
import "core:fmt"
import "core:testing"
import "../../../casey-cpu/profiler"
import "core:bytes"
import "core:math"

less :: proc(a, b: [2]int) -> (res: bool) {
    return a[1] < b[1]
}

main :: proc() {
    lib.run(process)
}

process :: proc(file: ^[]byte) -> (res: int) {
    profiler.time_function(#procedure)

    lines := bytes.split(file^, []byte{'\n'}, context.temp_allocator)
    defer delete(lines)

    rws := make(map[int]int, 0)
    defer delete(rws)

    columns := make(map[int]int, 0)
    defer delete(columns)

    total := make([dynamic][2]int, 0, len(lines[0]))
    defer delete(total)

    found_s := false
    for i := 0; i < len(lines); i += 1 {
        found_s = false
        for k := 0; k < len(lines[i]); k += 1 {
            if lines[i][k] == '#' {
                append(&total, [2]int{i, k})
                found_s = true
            }
        }

        if !found_s {
            rws[i] = 1
        }
    }

    found_s = false
    for i in 0..<len(lines[0]) - 1 {
        found_s = false
        for k := 0; k < len(lines); k += 1 {
            if lines[k][i] == '#' {
                found_s = true
            }
        }

        if !found_s {
            columns[i] = 1
        }
    }

    for t := 0; t < len(total); t += 1 {
        for i := t + 1; i < len(total); i += 1 {
            path := math.abs(total[t][0] - total[i][0])
            for k, v in rws {
                if k > total[t][0] && k < total[i][0] {
                    path += 999999
                }
            }

            path += math.abs(total[t][1] - total[i][1])
            for k, v in columns {
                if (k > total[t][1] && k < total[i][1]) || (k > total[i][1] && k < total[t][1]) {
                    path += 999999
                }
            }
            res += path
        }
    }
    return res
}

destroy :: proc(arr: [dynamic][dynamic]byte) {
    for elem in arr {
        delete(elem)
    }
    delete(arr)
}

@test
test_process :: proc(t: ^testing.T) {
    
    file := `...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....`

    fb := transmute([]u8)file
    res := process(&fb)

    expected := 8410
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}


