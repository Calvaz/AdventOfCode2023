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

Seed :: struct {
    start: uint,
    range: uint,
}

process :: proc(file: ^[]byte) -> int {
    res := uint(0b11111111111111111111111111111111)
    seeds: [20]Seed

    len_seeds := 0
    curr_index := 0

    is_start := true
    for i := 7; file[i] != 's'; i += 1 {
        switch file[i] {
        case '0'..='9':
            num: uint
            num, i = lib.get_digits_uint(file, i)
            add_seed(&seeds, &len_seeds, num, is_start)
            is_start = !is_start
        }
        curr_index = i + 1
    }
    curr_index = lib.skip_after_newline(file, curr_index) + 1

    num_type := 0
    arr_index := 0
    maps: [7][50]Record
    maps_index := 0

    init_record_list(&maps[maps_index])
    for i := curr_index; i < len(file); i += 1 {
        switch file[i] {
            case 'a'..='z':
                i = lib.skip_after_newline(file, i)
                arr_index = 0
                maps_index += 1
                init_record_list(&maps[maps_index])

            case '0'..='9':
                num: uint
                num, i = lib.get_digits_uint(file, i)
                add_to_record(&maps[maps_index][arr_index], num, num_type)
                num_type += 1

            case '\n':
                arr_index += 1
                num_type = 0
        }
    }

    for s in seeds {
        if s.start == 0 && s.range == 0 {
            continue
        }

        for num in s.start..<s.start + s.range {
            res = min(res, loop_curr_result(num, &maps))
        }
    }

    return int(res)
}

init_record_list :: proc(arr: ^[50]Record) {
    for i in 0..<50 {
        arr[i] = Record{}
    }
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

add_seed :: proc(seeds: ^[20]Seed, index: ^int, num: uint, is_start: bool) {
    if is_start {
        seeds[index^].start = num
    } else {
        seeds[index^].range = num
        index^ += 1
    }
}

loop_curr_result :: proc(seed: uint, arr: ^[7][50]Record) -> uint {
    s := seed
    loop: for m in arr {
        for record in m {
            if record.source == 0 && record.destination == 0 {
                continue
            }

            if s < record.source + record.range && s >= record.source {
                s = record.destination - record.source + s
                continue loop
            }
        }
    }
    return s
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

    expected := 46
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

