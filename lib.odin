package lib

import "core:os"
import "core:fmt"
import "../casey-cpu/profiler"

run :: proc(fn: proc(^[]byte) -> int) {
    profiler.start_profile()
    file := os.read_entire_file("../input") or_else panic("error while reading the file")
    res := fn(&file)
    profiler.end_profile()
    fmt.println(res)
}

peek :: proc(col: int, line: ^[]byte) -> byte {
    if col < len(line) - 1 {
        return line[col + 1]
    }
    return 0
}

is_digit :: proc(char: byte) -> bool {
    return char >= '0' && char <= '9'
}

is_alphanumeric :: proc(char: byte) -> bool {
    return char >= '0' && char <= '9' && char <= 'z' && char >= 'a' && char <= 'Z' && char >= 'A'
}

get_digits :: proc(line: ^[]byte, col: int) -> (int, int) {
    n := int(line[col] - '0')
    c := col
    for is_digit(peek(c, line)) {
        c += 1
        n = n * 10 + int(line[c] - '0')
    }
    return n, c
}

get_digits_uint :: proc(line: ^[]byte, col: int) -> (uint, int) {
    n := uint(line[col] - '0')
    c := col
    for is_digit(peek(c, line)) {
        c += 1
        n = n * 10 + uint(line[c] - '0')
    }
    return n, c
}

skip_after_newline :: proc(file: ^[]byte, index: int) -> int {
    i := index
    for peek(i, file) != '\n' {
        i += 1
    }
    i += 1
    return i
}

