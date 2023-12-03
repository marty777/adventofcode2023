unit module Day03;
use util;

# returns all numbers in the file as [x,y,length,number]
sub numberScan(@lines) {
	my @digits = "0123456789".split("",:skip-empty);
	my @numbers = ();
	loop (my $y = 0; $y < @lines.elems; $y++) {
		my @line = @lines[$y].split("",:skip-empty);
		loop (my $x = 0; $x < @line.elems; $x++) {
			if @line[$x] ~~ @digits.any {
				my $i = $x;
				my $number = 0;
				while $i < @line.elems && @line[$i] ~~ @digits.any {
					$number = $$number*10 + Int(@line[$i]);
					$i++;
				} 
				@numbers.push([$x,$y,$i-$x,$number]);
				$x = $i;
			}
		}
	}
	return @numbers;
}

# returns all symbols as an array of [x,y,symbol]
sub symbolScan(@lines) {
	my @nonsymbols = "0123456789.".split("",:skip-empty);
	my @symbols = ();
	loop (my $y = 0; $y < @lines.elems; $y++) {
			my @line = @lines[$y].split("",:skip-empty);
			loop (my $x = 0; $x < @line.elems; $x++) {
				if !(@line[$x] ~~ @nonsymbols.any) {
					@symbols.push([$x,$y,@line[$x]]);
				}
			}
	}
	return @symbols;
}

sub adjacent($number, $symbol) {
	if $symbol[1] < $number[1] - 1 || $symbol[1] > $number[1] + 1 { return False; }
	return ($symbol[0] >= $number[0]-1 && $symbol[0] <= $number[0] + $number[2]);
}

sub day03(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my @numbers = numberScan(@lines);
	my @symbols = symbolScan(@lines);

	for @numbers -> $number {
		my $adjacent = False;
		for @symbols -> $symbol {
			if adjacent($number, $symbol) {
				$adjacent = True;
				last;
			}
		}
		if $adjacent { $part1 += $number[3]; }
	}
	for @symbols -> $symbol {
		if $symbol[2] ne '*' { next; }
		my @adjacent_numbers = ();
		for @numbers -> $number {
			if adjacent($number, $symbol) {
				@adjacent_numbers.push($number[3]);
			} 
		}
		if @adjacent_numbers.elems == 2 {
			$part2 += @adjacent_numbers[0] * @adjacent_numbers[1];
		}
	}
	
	say "Part 1: $part1";
	say "Part 2: $part2";
}

