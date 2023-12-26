# adventofcode2023
[Advent of Code 2023](https://adventofcode.com/2023) in Raku (except for Day 24 part 2)

## Usage

	adventofcode2023.raku <day> <file>

		<day>	the puzzle day to run
		<file>	the input file to run

## Example

	$ rakudo adventofcode2023.raku 1 data/day1/input.txt

## Day 24 part 2

The solution for day 24 part 2 is implemented in Go because I'm more comfortable with the linear algebra library.

	$ cd Day24/
	$ go run day24.go input.txt

	or

	$ cd Day24/
	$ go build
	$ ./day24 input.txt

Thanks to **Eric Wastl** for putting together a challenging month of puzzles!

![alt text](https://github.com/marty777/adventofcode2023/blob/main/complete.png "All done")
