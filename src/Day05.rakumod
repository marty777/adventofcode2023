unit module Day05;
use util;

sub day05(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	# Parse the file
	my @seeds = @lines[0].split(":")[1].words.map: {.Int()};
	my $index = 1;
	my @maps = ();
	while $index < @lines.elems {
		if @lines[$index].trim().chars == 0 {
			my @next_map;
			@maps.push(@next_map);
			$index += 2;
		}
		my @line_vals = @lines[$index].words.map: {.Int()};
		@maps[@maps.elems - 1].push(@line_vals);
		$index += 1;
	}
	# Part 1 - Run each seed integer through each map
	my @locations = ();
	for @seeds -> $seed {
		my $remapped = $seed;
		loop (my $i = 0; $i < @maps.elems; $i++) {
			loop (my $j = 0; $j < @maps[$i].elems; $j++) {
				if @maps[$i][$j][1] <= $remapped && @maps[$i][$j][1] + @maps[$i][$j][2] > $remapped {
					$remapped = @maps[$i][$j][0] + ($remapped) - @maps[$i][$j][1];
					last;
				}
			}
		}
		@locations.push($remapped);
	}
	$part1 = @locations.min;
	# Part 2
	# Due to the size of the ranges of seed values, direct mapping of values 
	# individually is impractical. Run each range of seed values through each 
	# map instead, splitting them where necessary on mapping boundaries.
	my @location_range_starts = ();	
	loop (my $seed_range_index = 0; $seed_range_index < @seeds.elems; $seed_range_index += 2) {
		# Ranges are specified as [first, last]
		my @start_range = (@seeds[$seed_range_index], @seeds[$seed_range_index] + @seeds[$seed_range_index + 1] - 1);
		my @ranges;
		my @next_ranges.push(@start_range);
		# For each map, remap each range, splitting as needed.
		loop (my $i = 0; $i < @maps.elems; $i++) {
			@ranges = @next_ranges;
			@next_ranges = ();
			for @ranges -> @range {
				# if the range falls entirely within a mapping range, remap it,
				# add it to next_ranges, and end.
				# if the range falls entirely outside a mapping range, continue
				# to the next mapping range.
				# if the range is partly inside the mapping range, split it, 
				# map the internal part and continue with the remainder on 
				# subsequent mapping ranges.
				my $done = False;
				loop (my $j = 0; $j < @maps[$i].elems; $j++) {
					my @map_range = (@maps[$i][$j][1], @maps[$i][$j][1] + @maps[$i][$j][2] - 1);
					# If the range is outside the mapping range
					if @range[1] < @map_range[0] || @range[0] > @map_range[1] {
						next;
					}
					# If the range is entirely inside the mapping range
					elsif @maps[$i][$j][1] <= @range[0] && @maps[$i][$j][1] + @maps[$i][$j][2] > @range[1] {
						@range[0] = @maps[$i][$j][0] + (@range[0]) - @maps[$i][$j][1];
						@range[1] = @maps[$i][$j][0] + (@range[1]) - @maps[$i][$j][1];
						@next_ranges.push(@range);
						$done = True;
						last;
					}
					# If an upper part of the range is inside the mapping range
					elsif @range[0] < @map_range[0] && @range[1] >= @map_range[0] && @range[1] <= @map_range[1] {
						my @lower_range = (@range[0], @map_range[0] - 1);
						my @upper_range = (@map_range[0],@range[1]);
						@range = @lower_range;
						@upper_range = (@maps[$i][$j][0] + @upper_range[0] - @maps[$i][$j][1], @maps[$i][$j][0] + @upper_range[1] - @maps[$i][$j][1]);
						@next_ranges.push(@upper_range);
					}
					# If a lower part of the range is inside the mapping range
					elsif @range[0] >= @map_range[0] && @range[0] <= @map_range[1] && @range[1] > @map_range[1] {
						my @lower_range = (@range[0], @map_range[1]);
						my @upper_range = (@map_range[1] + 1, @range[1]);
						@range = @upper_range;
						@lower_range = (@maps[$i][$j][0] + @lower_range[0] - @maps[$i][$j][1], @maps[$i][$j][0] + @lower_range[1] - @maps[$i][$j][1]);
						@next_ranges.push(@lower_range);
					}
				}
				# if some or all of the range wasn't fully remapped at the end 
				# of the list of mapping ranges, add it unmapped.
				if !$done {
					@next_ranges.push(@range);
				}
			}
		}
		# after the start range has finished all mappings, add the start of 
		# each range to a list of range starts.
		for @next_ranges -> @range {
			@location_range_starts.push(@range[0]);
		}
	}

	$part2 = @location_range_starts.min;

	say "Part 1: $part1";
	say "Part 2: $part2";
}
