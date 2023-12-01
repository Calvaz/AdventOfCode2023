package main

import "core:os"
import "core:fmt"
import "core:testing"

one := "ne"
two := "wo"
three := "hree"
four := "our"
five := "ive"
six := "ix"
seven := "even"
eight := "ight"
nine := "ine"

main :: proc() {
    file := os.read_entire_file("../input") or_else panic("error while reading the file")
    process(&file)
}

process :: proc(file: ^[]byte) -> int {
    line := [2]u8{'a', 'a'}
    res := 0

    ix := 0
    for ix < len(file) {
        rune := file[ix]
        if is_digit(rune) {
            if line[0] == 'a' {
                line[0] = rune - '0'
            }
            line[1] = rune - '0'

        } else if is_char(rune) {
            token: string
            num: u8
            switch rune {
                case 'o': 
                    token = one
                    num = 1
                case 't':
                    next := peek(ix, file)
                    if next == 'h' {
                        token = three
                        num = 3
                    } else if next == 'w' {
                        token = two
                        num = 2
                    }
                case 'f':
                    next := peek(ix, file)
                    if next == 'i' {
                        token = five
                        num = 5
                    } else if next == 'o' {
                        token = four
                        num = 4
                    }
                case 's':
                    next := peek(ix, file)
                    if next == 'i' {
                        token = six
                        num = 6
                    } else if next == 'e' {
                        token = seven
                        num = 7
                    }
                case 'e': 
                    token = eight
                    num = 8
                case 'n': 
                    token = nine
                    num = 9
            }

            if guess_next_token(token, ix, file) {
                if line[0] == 'a' {
                    line[0] = num
                }
                line[1] = num
            }

        } else if rune == '\n' {
            res += int(line[0] * 10 + line[1])
            line[0] = 'a'
        }
        
        ix += 1
    }
    res += int(line[0] * 10 + line[1])
    fmt.println(res)
    return res
}

is_digit :: proc(char: u8) -> bool {
    return char >= '0' && char <= '9'
}

is_char :: proc(char: u8) -> bool {
    return char >= 'a' && char <= 'z'
}

peek :: proc(index: int, file: ^[]byte) -> u8 {
    if index == len(file) - 1 {
        return '\n'
    }
    return file[index + 1]
}

guess_next_token :: proc(next_string: string = "", index: int, file: ^[]byte) -> bool {
    if next_string == "" || index + len(next_string) >= len(file) {
        return false
    }

    file_index := index
    for k in 0..<len(next_string) {
        file_index += 1
        if next_string[k] != file[file_index] {
            return false
        }
    }
    return true
}

@test
parse_numbers :: proc(t: ^testing.T) {
    
    file := "onetwo\nthree4\n5sixseven8"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 104
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_numbers_with_random_stuff :: proc(t: ^testing.T) {
    
    file := "one55555two\nthree123172319841twoonego24\n5sixsevenasdbhbrbfebfefbqinqiweiqweq8"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 104
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_numbers_with_single_digits :: proc(t: ^testing.T) {
    
    file := "one\nthree\n58"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 102
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_all_text_numbers :: proc(t: ^testing.T) {
    
    file := "onetwo\nthreefour\nfivesix\nseveneight\nnineten"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 279
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_text_and_numbers :: proc(t: ^testing.T) {
    
    file := "onetwo\n34\nfivesix\n78\nnine"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 279
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_text_with_last_num :: proc(t: ^testing.T) {
    
    file := "onetwo\n34\nfivesix\n78\n9"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 279
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_text_with_last_double_num :: proc(t: ^testing.T) {
    
    file := "onetwo\n34\nfivesix\n78\n999999"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 279
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_text_with_last_letter :: proc(t: ^testing.T) {
    
    file := "onetwo\n34\nfivesix\n78\nasdaisbd93nine"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 279
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_text_with_one_letter :: proc(t: ^testing.T) {
    
    file := "one"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 11
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_text_with_one_number :: proc(t: ^testing.T) {
    
    file := "1"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 11
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_text_with_last_fake_digit :: proc(t: ^testing.T) {
    
    file := "onetwo\n34\nfivesix\n78\nnineajsdbaksdeigh9"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 279
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_text_with_last_fake_digit_2 :: proc(t: ^testing.T) {
    
    file := "onetwo\n34\nfivesix\n78\nnineajsdbaksdeighnineegh"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 279
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

@test
parse_text_with_last_one_number :: proc(t: ^testing.T) {
    
    file := "onetwo\n34\nasduiqu7dfnfjnf"
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 123
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %v, but instead got %v", expected, res))
}

