package day5

import "core:os"
import "core:fmt"
import "core:testing"
import "core:bytes"
import lib "../../."
import "core:math"
import "core:slice"

main :: proc() {
    lib.run(process)
}

Record :: struct {
    source: uint,
    destination: uint,
    range: uint,
    result: uint,
}

process :: proc(file: ^[]byte) -> int {
    res := uint(0b11111111111111111111111111111111)
    seeds: [20]uint

    len_seeds := 0
    arr: [50]Record
    curr_index := 0

    for i := 7; file[i] != 's'; i += 1 {
        switch file[i] {
        case '0'..='9':
            num: uint
            num, i = lib.get_digits_uint(file, i)
            seeds[len_seeds] = num
            len_seeds += 1
        }
        curr_index = i + 1
    }
    curr_index = lib.skip_after_newline(file, curr_index)

    for i in 0..<50 {
        arr[i] = Record{}
    }

    num_type := 0
    arr_index := 0
    for i := curr_index; i < len(file); i += 1 {
        switch file[i] {
            case 'a'..='z':
                i = lib.skip_after_newline(file, i)
                arr_index = 0
                loop(&seeds, arr)

            case '0'..='9':
                num: uint
                num, i = lib.get_digits_uint(file, i)
                add_to_record(&arr[arr_index], num, num_type)
                num_type += 1

            case '\n':
                arr_index += 1
                num_type = 0
        }
    }

    loop(&seeds, arr)
    for e in seeds {
        if e != 0 && e < res {
            res = e
        }
    }
    return int(res)
}

add_to_record :: proc(record: ^Record, num: uint, type: int) {
    if type == 0 {
        record.destination = num
    } else if type == 1 {
        record.source = num
    } else if type == 2 {
        record.range = num
    }
    record.result = 0
}

loop :: proc(seeds: ^[20]uint, arr: [50]Record) {
    loop: for elem in seeds {
        for r in arr {
            if elem != 0 && elem < r.source + r.range && elem >= r.source {
                if r.source == 0 && r.destination == 0 {
                    continue
                }
                elem = r.destination - r.source + elem
                continue loop
            }
        }
    }
}

@test
test_process :: proc(t: ^testing.T) {
    file := `seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4`
    
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 35
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}
