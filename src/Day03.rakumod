unit module Day03;
use util;

my $x_index = 0;
my $y_index = 1;
my $length_index = 2;
my $value_index = 3;
my $symbol_index = 2;

# returns a hash of all numbers in the file indexed by row, a hash of all
# symbols in the file indexed by row, and a list of all '*' symbols
sub fileScan(@lines) {
	my @digits = "0123456789".split("",:skip-empty);
	my @nonsymbols = "0123456789.".split("",:skip-empty);
	my %numbers_by_row;
	my %symbols_by_row;
	my @stars = ();
	loop (my $y = 0; $y < @lines.elems; $y++) {
		my @line = @lines[$y].split("",:skip-empty);
		loop (my $x = 0; $x < @line.elems; $x++) {
			if @line[$x] ~~ @digits.any {
				my $i = $x;
				my $number = 0;
				while $i < @line.elems && @line[$i] ~~ @digits.any {
					$number = $number*10 + Int(@line[$i]);
					$i++;
				} 
				if !%numbers_by_row{$y} { %numbers_by_row{$y} = [];}
				%numbers_by_row{$y}.push([$x,$y,$i-$x,$number]);
				$x = $i-1;
			}
			elsif !(@line[$x] ~~ @nonsymbols.any) {
				if !%symbols_by_row{$y} {%symbols_by_row{$y} = [];}
				my $symbol = [$x,$y,@line[$x]];
				%symbols_by_row{$y}.push($symbol);
				if $symbol[$symbol_index] eq '*' {
					@stars.push($symbol);
				}
			}
		}
	}
	return (%numbers_by_row, %symbols_by_row, @stars);
}

sub adjacent($number, $symbol) {
	if $symbol[$y_index] < $number[$y_index] - 1 || $symbol[$y_index] > $number[$y_index] + 1 { return False; }
	return ($symbol[$x_index] >= $number[$x_index]-1 && $symbol[$x_index] <= $number[$x_index] + $number[$length_index]);
}

sub day03(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	# get each number and symbol indexed by row number and the list of all '*' characters
	my (%numbers_by_row, %symbols_by_row, @stars) := fileScan(@lines);
	# Part 1 - find all numbers adjacent to at least one symbol and add their
	# value to the total
	loop (my $row = 0; $row < @lines.elems; $row++) {
		if %numbers_by_row{$row} {
			loop (my $i = 0; $i < %numbers_by_row{$row}.elems; $i++) {
				my $number = %numbers_by_row{$row}[$i];
				my $adjacent = False;
				loop (my $adjacent_row = $row-1; $adjacent_row <= $row+1; $adjacent_row++) {
					if !%symbols_by_row{$adjacent_row} { next; }
					loop (my $j = 0; $j < %symbols_by_row{$adjacent_row}.elems; $j++) {
						my $symbol = %symbols_by_row{$adjacent_row}[$j];
						if adjacent($number, $symbol) {
							$adjacent = True;
							last;
						}
					}
					if $adjacent {last;}	
				}
				if $adjacent {
					$part1 += $number[$value_index];
				}
			}
		}
	}
	# Part 2 - For each '*' symbol, find all adjacent numbers and if there are
	# exactly two add their product to the total.
	for @stars -> $star {
		my @adjacent_numbers;
		loop (my $adjacent_row = $star[$y_index] - 1; $adjacent_row <= $star[$y_index] + 1; $adjacent_row++) {
			if %numbers_by_row{$adjacent_row} {
				loop (my $j = 0; $j < %numbers_by_row{$adjacent_row}.elems; $j++) {
					my $number = %numbers_by_row{$adjacent_row}[$j];
					if adjacent($number, $star) {
						@adjacent_numbers.push($number);
					}
				}
			}
		}
		if @adjacent_numbers.elems == 2 {
			$part2 += @adjacent_numbers[0][$value_index] * @adjacent_numbers[1][$value_index];
		}
	}	
	say "Part 1: $part1";
	say "Part 2: $part2";
}
