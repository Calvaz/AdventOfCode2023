package lib

import "core:fmt"
import "core:os"

main :: proc() {
    args := os.args

    day := args[1]
    fmt.println("Creating odin files..")
    content := fmt.tprintf(`package day%v

import lib "../../."
import "core:fmt"
import "core:testing"
import "../../../casey-cpu/profiler"

main :: proc() {{
    lib.run(process)
}}

process :: proc(file: ^[]byte) -> (res: int) {{
    profiler.time_function(#procedure)
    
    return res
}}

@test
test_process :: proc(t: ^testing.T) {{
    
    file := ""
    fb := transmute([]u8)file
    res := process(&fb)

    expected := 1
    testing.expect(t, res == expected, fmt.tprintf("Expected res to equal %%v, but instead got %%v", expected, res))
}}`, day)

    ok := os.write_entire_file(fmt.tprintf("./day%v/part1/day%v.odin", day, day), transmute([]byte)content)
    if !ok {
        fmt.println("error while writing the file setup")
    }

    ok = os.write_entire_file(fmt.tprintf("./day%v/part2/day%v.odin", day, day), transmute([]byte)content)
    if !ok {
        fmt.println("error while writing the file setup")
    }
}

