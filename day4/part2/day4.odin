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
    copy_cards: [223]int
    cards_len := 0

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
            for j in 1..=curr_won {
                for _ in 1..=copy_cards[cards_len] + 1 {
                    if cards_len + j >= len(copy_cards) {
                        continue
                    }
                    copy_cards[cards_len + j] += 1
                }
            }
            copy_cards[cards_len] += 1
            res += copy_cards[cards_len]
            cards_len += 1
            curr_won, winning_nums_len = 0, 0
            is_winning_n = true
        }
    }

    copy_cards[cards_len] += 1
    res += copy_cards[cards_len]
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
    file := `Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2:    13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:     1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4:    41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5:    87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6:    31 18 13 56 72 | 74 77 10 23 35 67 36 11`
    
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 30
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

