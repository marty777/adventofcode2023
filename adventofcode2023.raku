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


constant $max_day = 8;

# This will not generate usage on error in Windows, but anyway...
sub MAIN(	
		Int		$day, 		#= the puzzle day to run
		Str 	$file, 		#= the input file to run
		) {
	
	if $day <= 0 or $day > $max_day {
		say "There is no implementation for puzzle day $day";
		return;
	}
	if not $file.IO.f {
		say "Could not find input file $file";
		return;
	}
	my @file_lines = readlines($file);
	if @file_lines == [False] {
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
		default { say "Day $day not available" }
	}
	my $elapsed = (now - $start) * 1000;
	say "\nElapsed: $elapsed ms";
}
