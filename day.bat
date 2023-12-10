echo Creating directories..
mkdir day%1\part1
md day%1\part2

odin run main.odin -file -- %1
