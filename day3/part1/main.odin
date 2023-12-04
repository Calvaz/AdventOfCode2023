package main

import "core:os"
import "core:fmt"
import "core:testing"
import "core:bytes"

main :: proc() {
    file := os.read_entire_file("../input") or_else panic("error while reading the file")
    res := process(&file)
    fmt.println(res)
}

process :: proc(file: ^[]byte) -> int {
    res: int = 0
    lines := bytes.split(file^, []byte{'\n'})

    for i := 0; i < len(lines); i += 1 {
        for k := 0; k < len(lines[i]); k += 1 {
            
            char := lines[i][k]
            if is_digit(char) {
                ix := k
                curr := int(char - '0')

                for is_digit(peek(ix, &lines[i])) {
                    ix += 1
                    curr = curr * 10 + int(lines[i][ix] - '0')
                }

                s := is_symbol_adjacent(i, k, &lines, curr) 
                if s {
                    res += curr
                }
                k = ix
            }
        }
    }

    return res
}

is_digit :: proc(char: byte) -> bool {
    return char >= '0' && char <= '9'
}

peek :: proc(col: int, line: ^[]byte) -> byte {
    if col < len(line) - 1 {
        return line[col + 1]
    }
    return 0
}

is_symbol_adjacent :: proc(row: int, col: int, m: ^[][]byte, curr_num: int) -> bool {
    cyphers: int
    if curr_num >= 10000 {
        cyphers = 5
    } else if curr_num >= 1000 {
        cyphers = 4
    } else if curr_num >= 100 {
        cyphers = 3
    } else if curr_num >= 10 {
        cyphers = 2
    } else if curr_num >= 1 {
        cyphers = 1
    }

    // behind number
    if (row > 0 && col > 0 && is_symbol(m[row - 1][col - 1])) ||
    (col > 0 && is_symbol(m[row][col - 1])) ||
    (row < len(m) - 1 && col > 0 && is_symbol(m[row + 1][col - 1])) ||
    (col < len(m[0]) - cyphers && is_symbol(m[row][col + cyphers])) {
        return true
    }

    // top-bottom and after number
    for i in 0..=cyphers {
        if is_next_symbol(row, col + i, m) {
            return true
        }
    }

    return false
}

is_symbol :: proc(char: byte) -> bool {
    is_sym := !is_digit(char) && char != '.' && char != '\r'
    return is_sym
}

is_next_symbol :: proc(row: int, col: int, m: ^[][]byte) -> bool {
    if col < len(m[0]) && 
        ((row > 0 && is_symbol(m[row - 1][col]) || 
        (row < len(m) - 1 && is_symbol(m[row + 1][col])))) {
            return true
        }
    return false
}

@test
test_process :: proc(t: ^testing.T) {
    
    file := "....123.123#....+..#4..5\n33...-..123#....+...4..-"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 382
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_three_levels :: proc(t: ^testing.T) {
    
    file := "....123.123#....+..#4..5\n33...-..123#....+...4..-\n.................3......"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 385
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_multiline :: proc(t: ^testing.T) {
    
    file := `-...#.............$.....P\n
.1.2.-...4#.5.#6..7..8..9\n
......3.....-.......;....`
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 45
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_top_left :: proc(t: ^testing.T) {
    
    file := "-....\n.153.\n....."
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 153
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_top_right :: proc(t: ^testing.T) {
    
    file := "12...\n.153.\n....-"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 153
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_bot_left :: proc(t: ^testing.T) {
    
    file := "12...\n.153.\n-...."
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 153
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_bot_right :: proc(t: ^testing.T) {
    
    file := "12...\n.153.\n....-"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 153
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_number_top_right_bot_left :: proc(t: ^testing.T) {
    
    file := "12...\n..$..\n...12"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 24
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_number_bot_right_top_left :: proc(t: ^testing.T) {
    
    file := "1..12\n1.$.1\n12..1"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 24
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_number_center :: proc(t: ^testing.T) {
    
    file := "1.2.1\n12-12\n1.2.1"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 28
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_number_left_no_symbol :: proc(t: ^testing.T) {
    
    file := "$-.12"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 0
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_number_right_no_symbol :: proc(t: ^testing.T) {
    
    file := "12.--"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 0
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_number_top_bot_no_symbol :: proc(t: ^testing.T) {
    
    file := "$-.12\n...12\n12345"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 0
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_number_whole_line :: proc(t: ^testing.T) {
    
    file := "12345"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 0
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_number_close_no_space :: proc(t: ^testing.T) {
    
    file := "12-45"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 57
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_number_close_no_space_2 :: proc(t: ^testing.T) {
    
    file := "12314$12-45%%3"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 12374
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_number_close_no_space_3 :: proc(t: ^testing.T) {
    
    file := "111$111$-%111.\n0....1.....111"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 333
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_cyphers :: proc(t: ^testing.T) {
    
    file := "aaaaaann.123.-.2\naeebb=#$.....-.."
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 0
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_cyphers_2 :: proc(t: ^testing.T) {
    
    file := ".1234-\n......\n1*...."
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 1235
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_cyphers_3 :: proc(t: ^testing.T) {
    
    file := ".1234.\n.....*\n1....."
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 1234
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_process_letters :: proc(t: ^testing.T) {
    
    file := "aaaaaa...1..b-.2"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 0
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_is_symbol :: proc(t: ^testing.T) {
    res := is_symbol('%')
    expected := true
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('=')
    expected = true
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('*')
    expected = true
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('$')
    expected = true
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('/')
    expected = true
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('#')
    expected = true
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('@')
    expected = true
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('&')
    expected = true
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('+')
    expected = true
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('-')
    expected = true
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('.')
    expected = false
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('0')
    expected = false
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))

    res = is_symbol('9')
    expected = false
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
test_is_digit :: proc(t: ^testing.T) {
    res := is_digit(byte(0))
    expected := false
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

