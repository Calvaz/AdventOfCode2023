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
            cubes[0] += curr
            i += 2
            curr = 0
        case 'g': 
            cubes[1] += curr
            i += 4
            curr = 0
        case 'b': 
            cubes[2] += curr
            i += 3
            curr = 0

        case ';':
            ix := i
            if !is_game_possible(cubes[0], cubes[1], cubes[2]) {
                next := peek(ix, file)
                for next != '\n' && next != 255 {
                    ix += 1
                    next = peek(ix, file)
                }
                i = ix
                continue
            }
            cubes = [3]uint{}
            curr = 0

        case '\n': 
            if is_game_possible(cubes[0], cubes[1], cubes[2]) {
                res += curr_game
            }
            cubes = [3]uint{}
            curr_game += 1
        }

    }

    if is_game_possible(cubes[0], cubes[1], cubes[2]) {
        res += curr_game
    }
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

is_game_possible :: proc(red, green, blue: uint) -> bool {
    return red <= 12 && green <= 13 && blue <= 14
}

@test
test_is_game_possible :: proc(t: ^testing.T) {
    
    file := "Game 1: 10 red, 1 green, 3 blue; 1 red, 1 green, 1 blue\nGame 2: 1 red, 10 blue, 2 blue, 1 blue, 1 blue"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 3
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_is_game_not_possible :: proc(t: ^testing.T) {
    
    file := "Game 1: 10 red, 1 green, 3 blue; 1 red, 1 green, 1 blue\nGame 2: 1 red, 10 blue, 2 blue, 1 blue, 2 blue"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 1
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

