unit module Day12;
use util;

sub expand_pattern(@pattern) {
	my @expanded_pattern;
	loop (my $i = 0; $i < 5; $i++) {
		loop (my $j = 0; $j < @pattern.elems; $j++) {
			@expanded_pattern.push(@pattern[$j]);
		}
		if $i < 4 {
			@expanded_pattern.push("?");
		}		
	}
	return @expanded_pattern;
}

sub expand_numbers(@numbers) {
	my @expanded_numbers;
	loop (my $i = 0; $i < 5; $i++) {
		loop (my $j = 0; $j < @numbers.elems; $j++) {
			@expanded_numbers.push(@numbers[$j]);
		}
	}
	return @expanded_numbers;
}

# Verify that the elements in the assigned positions so far are not 
# ruled out by the pattern.
sub test(@numbers, @assigned, @pattern) {
	my $curr_element = @assigned.elems - 1;
	my $curr_start = @assigned[$curr_element];
	my $curr_end = $curr_start + @numbers[$curr_element] - 1;
	if @assigned.elems == 1 {
		loop (my $i = 0; $i < $curr_start; $i++) {
			if @pattern[$i] eq "#" {
				return False;
			}
		}
		loop ($i = $curr_start; $i <= $curr_end; $i++) {
			if @pattern[$i] eq "." {
				return False;
			}
		}
		if $curr_end < @pattern.elems - 1 && @pattern[$curr_end + 1] eq "#" {
			return False;
		}
		return True;
	}
	elsif @assigned.elems == @numbers.elems {
		my $last_end = @assigned[$curr_element - 1] + @numbers[$curr_element - 1] - 1;
		loop (my $i = $last_end + 1; $i < $curr_start; $i++) {
			if @pattern[$i] eq "#" {
				return False;
			}
		}
		loop ($i = $curr_start; $i <= $curr_end; $i++) {
			if @pattern[$i] eq "." {

				return False;
			}
		}
		loop ($i = $curr_end + 1; $i < $@pattern.elems; $i++) {
			if @pattern[$i] eq "#" {
				
				return False;
			}
		}
		return True;
	}
	else {
		my $last_end = @assigned[$curr_element - 1] + @numbers[$curr_element - 1] - 1;
		loop (my $i = $last_end + 1; $i < $curr_start; $i++) {
			if @pattern[$i] eq "#" {
				return False;
			}
		}
		loop ($i = $curr_start; $i <= $curr_end; $i++) {
			if @pattern[$i] eq "." {
				return False;
			}
		}
		if $curr_end < @pattern.elems - 1 && @pattern[$curr_end + 1] eq "#" {
			return False;
		}
		return True;
	}
}

# Returns the number of possible arrangements matching the pattern given
# the current assignments
# Arguments are:
#	@numbers	
#		The lengths of each element to be placed in the arrangement
#	@assigned
#		The starting position indexes of each element already placed
#	@pattern
#		The pattern to match
#	%cache 
#		A map of previously seen sub-states and the number of 
#		arrangements indexed by a string key
sub recurse(@numbers, @assigned, @pattern, %cache) {
	if @assigned.elems == @numbers.elems {
		if test(@numbers,@assigned, @pattern ) {
			return 1;
		}
		return 0;
	}
	# Test if the current assignments are viable for our pattern
	# and if not, stop exploring this branch
	if (@assigned > 0) {
		if !test(@numbers, @assigned, @pattern) {
			return 0;
		}
	}
	my $curr_element_index = @assigned.elems;
	# The position of previous element, plus it's length plus one space to the left
	my $curr_element_minimum_index = 0;
	if ($curr_element_index > 0) {
		$curr_element_minimum_index = @assigned[$curr_element_index - 1] + @numbers[$curr_element_index - 1] + 1;
	}
	# Early exit if this state has been previously seen in the cache
	my $curr_key = @pattern.join("").substr($curr_element_minimum_index) ~ '|' ~ @numbers[$curr_element_index..(@numbers.elems - 1)].join(",");
	if %cache{$curr_key}:exists {
		return %cache{$curr_key};
	}
	
	# Minimum space required on the righ is each remaining element size, plus one space to left for each
	my $minimum_space_for_remaining_elements = 0;
	loop (my $i = $curr_element_index + 1; $i < @numbers.elems; $i++) {
		$minimum_space_for_remaining_elements += 1 + @numbers[$i];
	}
	my $curr_element_maximum_index = @pattern.elems - $minimum_space_for_remaining_elements - @numbers[$curr_element_index];
	my $result = 0;
	# Try all possible positions for this element and recurse further down the tree
	loop ($i = $curr_element_minimum_index; $i <= $curr_element_maximum_index; $i++) {
		my @next_assigned = @assigned.clone;
		@next_assigned.push($i);
		$result += recurse(@numbers, @next_assigned, @pattern, %cache);
	}
	%cache{$curr_key} = $result;
	return $result;
}

sub day12(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my %cache;

	for @lines -> $line {
		my @words = $line.words;
		my @pattern = @words[0].split(""):skip-empty;
		my @numbers = @words[1].split(","):skip-empty;
		
		$part1  += recurse(@numbers, [], @pattern, %cache);
		my @expanded_numbers = expand_numbers(@numbers);
		my @expanded_pattern = expand_pattern(@pattern);
		$part2 += recurse(@expanded_numbers, [], @expanded_pattern, %cache);
	}
	
	say "Part 1: $part1";
	say "Part 2: $part2";
}
