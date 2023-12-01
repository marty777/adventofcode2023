use v6;
use lib "src";
use util;

constant $max_day = -1;

# This will not generate usage on error in Windows, but anyway...
sub MAIN(	
		Int		$day, 		#= the puzzle day to run
		Str 	$file, 	#= the input file to run
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
		#when 1 { day01(@file_lines) }
        default { say "Day $day not available" }
	}
    my $elapsed = (now - $start) * 1000;
    say "\nElapsed: $elapsed ms";
}
