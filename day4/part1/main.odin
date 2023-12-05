package day4

import "core:os"
import "core:fmt"
import "core:testing"
import "core:bytes"
import lib "../../."
import "core:math"

main :: proc() {
    lib.run(process)
}

process :: proc(file: ^[]byte) -> int {
    res: int = 0
    is_winning_n := true
    winning_nums: [10]int
    winning_nums_len := 0

    curr_won := 0
    for i := 8; i < len(file); i += 1 {

        switch file[i] {
        case 'C': i += 9
        case '|': is_winning_n = false

        case '0'..='9':
            num: int
            num, i = lib.get_digits(file, i)
            if is_winning_n {
                winning_nums[winning_nums_len] = num
                winning_nums_len += 1

            } else {
                for e in winning_nums {
                    if num == e {
                        curr_won += 1
                    }
                }
            }

        case '\n':
            res += get_result(curr_won)
            curr_won, winning_nums_len = 0, 0
            is_winning_n = true
        }
    }

    res += get_result(curr_won)
    return res
}

get_result :: proc(won: int) -> int {
    res := 0
    if won == 1 || won == 2 {
        res += won
    } else if won > 2 {
        fmt.println(won)
        res = 1
        for k in 2..=won {
            res <<= 1
        }
    }
    return res
}

@test
test_process :: proc(t: ^testing.T) {
    
    file := "Card   1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53 \nCard   2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 10
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_2 :: proc(t: ^testing.T) {
    
    file := "Card   2: 49 62 66 89 53 16 59 19 58 99 | 99 29 21 59 53 66  1 77 15 92 94\nCard   3: 37 77  5 90 41 15 46 67 38 53 | 47 27 41 90 77 53 65 50 69 72 37 91  9 31 67"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 24
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

