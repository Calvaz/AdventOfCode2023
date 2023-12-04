package main

import "core:os"
import "core:fmt"
import "core:testing"
import "core:bytes"
import "core:strings"
import "core:slice"

main :: proc() {
    file := os.read_entire_file("../input") or_else panic("error while reading the file")
    res := process(&file)
    fmt.println(res)
}

process :: proc(file: ^[]byte) -> int {
    res: int = 0
    lines := bytes.split(file^, []byte{'\n'})

    for i := 0; i < len(lines); i += 1 {
        for k := 0; k < len(lines[i]); k += 1 {
            
            char := lines[i][k]
            if char == '*' {
                ajs: [dynamic]int = make([dynamic]int, 0, 2)
                search_adjacent_numbers(&lines, i, k, &ajs)
                
                a := ajs[:]
                if len(a) > 1 {
                    fmt.println(a)
                    res += slice.reduce(a, 1, proc(x, y: int) -> int { return x * y })
                }
                clear(&ajs)
            }
        }
    }

    return res
}

search_adjacent_numbers :: proc(lines: ^[][]byte, row, col: int, ajs: ^[dynamic]int) {
    get_value(lines, row - 1, col - 1, ajs)
    get_value(lines, row - 1, col, ajs)
    get_value(lines, row - 1, col + 1, ajs)
    get_value(lines, row, col - 1, ajs)
    get_value(lines, row, col + 1, ajs)
    get_value(lines, row + 1, col - 1, ajs)
    get_value(lines, row + 1, col + 1, ajs)
    get_value(lines, row + 1, col, ajs)
}

get_value :: proc(lines: ^[][]byte, row, col: int, ajs: ^[dynamic]int) {
    if !is_in_bounds(lines, row, col) do return

    num := 0
    if is_digit(lines[row][col]) {
        if (col > 0 && !is_digit(lines[row][col - 1])) ||
            (col == 0 && is_digit(lines[row][col])) {
            num, _ = get_next_digits(&lines[row], col)
            for n in ajs {
                if n == num {
                    return
                }
            }
            append(ajs, num)
        } else {
            get_value(lines, row, col - 1, ajs)
        }
    }
}

is_digit :: proc(char: byte) -> bool {
    return char >= '0' && char <= '9'
}

peek :: proc(col: int, line: ^[]byte) -> byte {
    if col < len(line) - 1 {
        return line[col + 1]
    }
    return 0
}

get_next_digits :: proc(lines: ^[]byte, col: int) -> (int, int) {
    c := col
    n := int(lines[col] - '0')
    for is_digit(peek(c, lines)) {
        c += 1
        n = n * 10 + int(lines[c] - '0')
    }
    return n, col
}

is_in_bounds :: proc(m: ^[][]byte, row, col: int) -> bool {
    return row < len(m) && col < len(m[0]) && row >= 0 && col >= 0
}

