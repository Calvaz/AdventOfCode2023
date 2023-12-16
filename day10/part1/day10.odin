package day10

import lib "../../."
import "core:fmt"
import "core:testing"
import "../../../casey-cpu/profiler"
import "core:bytes"
import "core:mem"

main :: proc() {
    lib.run(process)
}

process :: proc(file: ^[]byte) -> (res: int) {
    profiler.time_function(#procedure)
    
    lines := bytes.split(file^, []byte{'\n'}, context.temp_allocator)
    start: [2]int
    for i := 0; i < len(lines); i += 1 {
        for k := 0; k < len(lines[i]); k += 1 {
            if lines[i][k] == 'S' {
                start = [2]int{i, k}
                break
            }
        }
    }

    steps := visit(&lines, start, start[0] - 1, start[1])
    steps = max(visit(&lines, start, start[0], start[1] + 1), steps)
    steps = max(visit(&lines, start, start[0] + 1, start[1]), steps)
    steps = max(visit(&lines, start, start[0], start[1] - 1), steps)

    // stack overflow
    //steps = dive(&lines, start[0], start[1], start[0] - 1, start[1], curr_steps)
    //steps = max(dive(&lines, start[0], start[1], start[0], start[1] + 1, curr_steps), steps)
    //steps = max(dive(&lines, start[0], start[1], start[0] + 1, start[1], curr_steps), steps)
    //steps = max(dive(&lines, start[0], start[1], start[0], start[1] - 1, curr_steps), steps)

    steps /= 2
    res = steps
    return res
}

visit :: proc(file: ^[][]byte, start: [2]int, row, col: int) -> (steps: int) {
    stack := make([dynamic][2]int, 0, 200)
    defer delete(stack)
    append(&stack, [2]int{row, col})

    next_r, next_c := row, col
    r, c := start[0], start[1]
    if !is_in_bounds(file, next_r, next_c) {
        return steps + 1
    }

    for file[next_r][next_c] != 'S' {
        elem := pop(&stack)
        if file[r][c] == '.' {
            break
        }
        steps += 1
        next_r, next_c = get_next_move(file, r, c, elem[0], elem[1])
        if !is_in_bounds(file, next_r, next_c) {
            break
        }

        r, c = elem[0], elem[1]
        append(&stack, [2]int{next_r, next_c})
    }
    return steps + 1
}

get_next_move :: proc(file: ^[][]byte, prev_row, prev_col, row, col: int) -> (r, c: int) {
    switch file[row][col] {
        case '|': 
            if prev_row == row - 1 {
                return row + 1, col
            } else if prev_row == row + 1 {
                return row - 1, col
            }
        case '-':
            if prev_col == col - 1 {
                return row, col + 1
            } else if prev_col == col + 1 {
                return row, col - 1
            }
        case 'L':
            if prev_row == row - 1 {
                return row, col + 1
            } else if prev_col == col + 1 {
                return row - 1, col
            }
        case 'J':
            if prev_row == row - 1 {
                return row, col - 1
            } else if prev_col == col - 1 {
                return row - 1, col
            }
        case '7':
            if prev_row == row + 1 {
                return row, col - 1
            } else if prev_col == col - 1 {
                return row + 1, col
            }
        case 'F':
            if prev_row == row + 1 {
                return row, col + 1
            } else if prev_col == col + 1 {
                return row + 1, col
            }
        case 'S':
            return row, col
    }
    return -1, -1
}

// stack overflow
dive :: proc(file: ^[][]byte, prev_row, prev_col, row, col: int, curr: int) -> (curr_steps: int) {
    if !is_in_bounds(file, row, col) do return
    if file[row][col] == '.' do return

    c := curr
    c += 1

    switch file[row][col] {
        case '|': 
            if prev_row == row - 1 {
                curr_steps = dive(file, row, col, row + 1, col, c)
            } else if prev_row == row + 1 {
                curr_steps = dive(file, row, col, row - 1, col, c)
            }
        case '-':
            if prev_col == col - 1 {
                curr_steps = dive(file, row, col, row, col + 1, c)
            } else if prev_col == col + 1 {
                curr_steps = dive(file, row, col, row, col - 1, c)
            }
        case 'L':
            if prev_row == row - 1 {
                curr_steps = dive(file, row, col, row, col + 1, c)
            } else if prev_col == col + 1 {
                curr_steps = dive(file, row, col, row - 1, col, c)
            }
        case 'J':
            if prev_row == row - 1 {
                curr_steps = dive(file, row, col, row, col - 1, c)
            } else if prev_col == col - 1 {
                curr_steps = dive(file, row, col, row - 1, col, c)
            }
        case '7':
            if prev_row == row + 1 {
                curr_steps = dive(file, row, col, row, col - 1, c)
            } else if prev_col == col - 1 {
                curr_steps = dive(file, row, col, row + 1, col, c)
            }
        case 'F':
            if prev_row == row + 1 {
                curr_steps = dive(file, row, col, row, col + 1, c)
            } else if prev_col == col + 1 {
                curr_steps = dive(file, row, col, row + 1, col, c)
            }
        case 'S':
            return c
    }
    return curr_steps
}

is_in_bounds :: proc(file: ^[][]byte, row, col: int) -> bool {
    return row >= 0 && col >= 0 && row < len(file) && col < len(file[0])
}

@test
test_process :: proc(t: ^testing.T) {
    
    file := `.....
.S-7.
.|.|.
.L-J.
.....`
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 4
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_2 :: proc(t: ^testing.T) {
    
    file := `..F7.
.FJ|.
SJ.L7
|F--J
LJ...`
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 8
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

