package lib

import "core:os"
import "core:fmt"

run :: proc(fn: proc(^[]byte) -> int) {
    file := os.read_entire_file("../input") or_else panic("error while reading the file")
    res := fn(&file)
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

get_digits :: proc(line: ^[]byte, col: int) -> (int, int) {
    n := int(line[col] - '0')
    c := col
    for is_digit(peek(c, line)) {
        c += 1
        n = n * 10 + int(line[c] - '0')
    }
    return n, c
}

