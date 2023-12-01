package main

import "core:os"
import "core:fmt"

main :: proc() {
    file := os.read_entire_file("../input") or_else panic("error while reading the file")
    content := transmute(string)file

    line := [2]rune{'a', 'a'}
    res := 0

    for rune in content {

        if is_digit(rune) {
            if line[0] == 'a' {
                line[0] = rune
            }
            line[1] = rune
        }

        if rune == '\n' {
            res += int((line[0] - '0') * 10 + (line[1] - '0'))
            line[0] = 'a'
        }
    }
    res += int((line[0] - '0') * 10 + (line[1] - '0'))
    fmt.println(res)
}

is_digit :: proc(char: rune) -> bool {
    return char >= '0' && char <= '9'
}
