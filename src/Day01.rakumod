unit module Day01;
use util;

sub digitscan($str, $part2) {
	my @is_digit = "0123456789".split("");
	my %replacements = %{
			'one' => '1',
			'two' => '2',
			'three' => '3',
			'four' => '4',
			'five' => '5',
			'six' => '6',
			'seven' => '7',
			'eight' => '8',
			'nine' => '9'
			};
	my @digits;
	loop (my $i = 0; $i < $str.chars; $i++) {
		if $part2 {
			for %replacements.kv -> $key, $value {
				if $i + $key.chars <= $str.chars && substr($str, $i,$key.chars) eq $key {
					@digits.push($value);
				}
			}
		}
		if substr($str, $i, 1) ~~ any @is_digit {
			@digits.push(substr($str, $i, 1) );
		}
	}
	return @digits;
}

sub day01(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;
	loop (my $i = 0; $i < @lines.elems; $i+= 1) {
		my @digits = digitscan(@lines[$i], False);
		my @digits2 = digitscan(@lines[$i], True);
		# assuming at least one digit in the string
		if @digits.elems > 1 {
			$part1 += Int(@digits[0] ~ @digits[@digits.elems - 1]);
		}
		else {
			$part1 += Int(@digits[0] ~ @digits[0]);
		}
		if @digits2.elems > 1 {
			$part2 += Int(@digits2[0] ~ @digits2[@digits2.elems - 1]);
		}
		else {
			$part2 += Int(@digits2[0] ~ @digits2[0]);
		}		
	}
	say "Part 1: " ~ $part1;
	say "Part 2: " ~ $part2;
}
