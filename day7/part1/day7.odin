package day7

import lib "../../."
import "core:fmt"
import pq "core:container/priority_queue"
import "core:testing"
import "core:strconv"
import "core:strings"
import "../../../casey-cpu/profiler"

main :: proc() {
    lib.run(process)
}

one_pair: int   : 14
three_of_k: int : 42
full: int       : 56
four_of_k: int  : 70
five_of_k: int  : 84

less :: proc(a, b: [7]int) -> (res: bool) {
    if a[0] == b[0] {
        for i in 2..<7 {
            if a[i] != b[i] {
                return a[i] < b[i]
            }
        }
    }
    return a[0] < b[0]
}

process :: proc(file: ^[]byte) -> int {
    res: int
    
    curr_q: pq.Priority_Queue([7]int)
    pq.init(&curr_q, less, pq.default_swap_proc([7]int))

    set := make(map[byte]int, 5)
    defer delete(set)

    bid, score: int
    index := 2
    data: [7]int
    for i := 0; i < len(file); i += 1 {
        switch file[i] {

        case ' ':
            score = check_hand(&set)
            bid, i = lib.get_digits(file, i + 1)

        case '\n': 
            data[0] = score
            data[1] = bid
            pq.push(&curr_q, data)
            bid, score, index = 0, 0, 2
            clear(&set)

        case 'A': add_cards(&set, 62, &index, &data)
        case 'K': add_cards(&set, 61, &index, &data)
        case 'Q': add_cards(&set, 60, &index, &data)
        case 'J': add_cards(&set, 59, &index, &data)
        case 'T': add_cards(&set, 58, &index, &data)
        case '0'..='9': add_cards(&set, file[i], &index, &data)
        }
    }
    data[0] = score
    data[1] = bid
    pq.push(&curr_q, data)
    len := pq.len(curr_q)

    for i in 1..=len {
        popped := pq.pop(&curr_q)
        res += int(popped[1]) * i
    }
    return res
}

add_cards :: proc(set: ^map[byte]int, to_add: byte, index: ^int, data: ^[7]int) {
    set[to_add] += 1
    data[index^] = int(to_add)
    index^ += 1
}

check_hand :: proc(cards: ^map[byte]int) -> int {
    score := 0
    for k, v in cards {
        switch {
        case v == 2 && score == three_of_k: score = full
        case v == 3 && score == one_pair: score = full
        case v == 2: score += one_pair
        case v == 3: score += three_of_k
        case v == 4: score += four_of_k
        case v == 5: score += five_of_k
        }
    }
    return score
}

@test
test_process :: proc(t: ^testing.T) {
    file := `32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483`
    
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 6440
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_2 :: proc(t: ^testing.T) {
    file := `AAA4A 1
AAAA5 2
AAAA4 3
AAAJA 4`
    
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 26
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

//@test
//test_check_hand :: proc(t: ^testing.T) {
//    
//    maps := make(map[byte]int)
//    defer delete(maps)
//    maps[byte('A')] = 4
//
//    
//    fb := transmute([]u8)file
//    res := check_hand(&fb)
//
//    expected := 6440
//    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
//}

