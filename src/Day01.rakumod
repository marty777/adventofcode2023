unit module Day01;
use util;

sub digitscan($str, $part2) {
	my %replacements = %{
			'one' 	=> '1',
			'two' 	=> '2',
			'three'	=> '3',
			'four'	=> '4',
			'five'	=> '5',
			'six'	=> '6',
			'seven'	=> '7',
			'eight'	=> '8',
			'nine'	=> '9'
			};
	my @digits;
	# find first digit appearance in string
	my $found = False;
	loop (my $i = 0; $i < $str.chars && !$found; $i++) {
		if $part2 {
			for %replacements.kv -> $key, $value {
				if $i + $key.chars <= $str.chars && substr($str, $i, $key.chars) eq $key {
					@digits.push($value);
					$found = True;
					last;
				}
			}
		}
		if !$found && substr($str, $i, 1) ~~ any %replacements.values {
			@digits.push(substr($str, $i, 1) );
			last;
		}
	}
	# find last digit appearance in string
	$found = False;
	loop ($i = $str.chars - 1; $i >= 0 && !$found; $i--) {
		if $part2 {
			for %replacements.kv -> $key, $value {
				if $i + $key.chars <= $str.chars && substr($str, $i, $key.chars) eq $key {
					@digits.push($value);
					$found = True;
					last;
				}
			}
		}
		if !$found && substr($str, $i, 1) ~~ any %replacements.values {
			@digits.push(substr($str, $i, 1) );
			last;
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
		if @digits.elems > 0 { $part1 += Int(@digits[0] ~ @digits[@digits.elems - 1]) };
		if @digits2.elems > 0 { $part2 += Int(@digits2[0] ~ @digits2[@digits2.elems - 1]) };		
	}
	say "Part 1: " ~ $part1;
	say "Part 2: " ~ $part2;
}
