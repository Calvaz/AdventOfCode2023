package main

import "core:os"
import "core:fmt"
import "core:testing"

main :: proc() {
    file := os.read_entire_file("../input") or_else panic("error while reading the file")
    res := process(&file)
    fmt.println(res)
}

process :: proc(file: ^[]byte) -> int {
    res: int = 0
    curr_game := 1

    curr: uint = 0
    cubes := [3]uint{}
    min := [3]uint{}

    for i := 8; i < len(file); i += 1 {
        char := file[i]

        switch char {
        case 'G':
            i += 7

        case '0'..='9': 
            ix := i
            curr = uint(char - '0')

            for is_digit(peek(ix, file)) {
                ix += 1
                curr = curr * 10 + uint(file[ix] - '0')
            }
            i = ix

        case 'r': 
            if curr > cubes[0] {
                cubes[0] = curr
            }
            i += 2
            curr = 0
        case 'g': 
            if curr > cubes[1] {
                cubes[1] = curr
            }
            i += 4
            curr = 0
        case 'b': 
            if curr > cubes[2] {
                cubes[2] = curr
            }
            i += 3
            curr = 0

        case '\n': 
            pow := cubes[0] * cubes[1] * cubes[2]
            res += int(pow)
            cubes = [3]uint{}
            curr_game += 1
        }
    }
    pow := cubes[0] * cubes[1] * cubes[2]
    res += int(pow)

    return res
}

peek :: proc(index: int, file: ^[]byte) -> byte {
    if index < len(file) {
        return file[index + 1]
    }
    return 255
}

is_digit :: proc(char: byte) -> bool {
    return char >= '0' && char <= '9'
}


