use v6;
use lib "src";
use util;
use Day01;
use Day02;
use Day03;
use Day04;
use Day05;
use Day06;
use Day07;
use Day08;
use Day09;
use Day10;
use Day11;
use Day12;
use Day13;
use Day14;
use Day15;
use Day16;
use Day17;

# This will not generate usage on error in Windows, but anyway...
sub MAIN(	
		Int		$day, 		#= the puzzle day to run
		Str 	$file, 		#= the input file to run
		) {
	
	if not $file.IO.f {
		say "Could not find input file $file";
		return;
	}
	my @file_lines = readlines($file);
	if @file_lines === [False] {
		say "Could not read input file $file";
		return;
	}
	if @file_lines.elems == 0 {
		say "Input file $file is empty";
		return;
	}
	print_logo();
	say	"Running Day $day with input file $file\n";
	my $start = now;
	given $day {
		when 1 { day01(@file_lines) }
		when 2 { day02(@file_lines) }
		when 3 { day03(@file_lines) }
		when 4 { day04(@file_lines) }
		when 5 { day05(@file_lines) }
		when 6 { day06(@file_lines) }
		when 7 { day07(@file_lines) }
		when 8 { day08(@file_lines) }
		when 9 { day09(@file_lines) }
		when 10 { day10(@file_lines) }
		when 11 { day11(@file_lines) }
		when 12 { day12(@file_lines) }
		when 13 { day13(@file_lines) }
		when 14 { day14(@file_lines) }
		when 15 { day15(@file_lines) }
		when 16 { day16(@file_lines) }
		when 17 { day17(@file_lines) }
		default { say "There is no implementation for puzzle day $day" }
	}
	my $elapsed = (now - $start) * 1000;
	say "\nElapsed: $elapsed ms";
}
