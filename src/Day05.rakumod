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
			for @ranges -> @initial_range {
				# if the range falls entirely within a mapping range, remap it,
				# add it to next_ranges, and end.
				# if the range falls entirely outside a mapping range, continue
				# to the next mapping range.
				# if the range is partly inside the mapping range, split it, 
				# map the internal part and continue with the remainder on 
				# subsequent mapping ranges.
				# If the range encloses the mapping range, split it into lower,
				# middle and upper parts, map the middle part, and continue 
				# with the lower and upper parts on subsequent mapping ranges
				my $done = False;
				my @curr_ranges = ();
				my @next_curr_ranges = ();
				# Any not-yet-remapped ranges are pushed to @next_curr_ranges,
				# and any ranges or sub-ranges that are remapped are pushed to
				# @next_ranges to avoid performing two remappings in the same
				# map.
				@next_curr_ranges.push(@initial_range);
				loop (my $j = 0; $j < @maps[$i].elems; $j++) {
					@curr_ranges = @next_curr_ranges;
					@next_curr_ranges = ();
					my @map_range = (@maps[$i][$j][1], @maps[$i][$j][1] + @maps[$i][$j][2] - 1);
					for @curr_ranges -> @range {
						# If the range is outside the mapping range
						if @range[1] < @map_range[0] || @range[0] > @map_range[1] {
							@next_curr_ranges.push(@range);
						}
						# If the range is entirely inside the mapping range
						elsif @maps[$i][$j][1] <= @range[0] && @maps[$i][$j][1] + @maps[$i][$j][2] > @range[1] {
							@range[0] = @maps[$i][$j][0] + (@range[0]) - @maps[$i][$j][1];
							@range[1] = @maps[$i][$j][0] + (@range[1]) - @maps[$i][$j][1];
							@next_ranges.push(@range);
						}
						# If an upper part of the range is inside the mapping range
						elsif @range[0] < @map_range[0] && @range[1] >= @map_range[0] && @range[1] <= @map_range[1] {
							my @lower_range = (@range[0], @map_range[0] - 1);
							my @upper_range = (@map_range[0],@range[1]);
							@upper_range = (@maps[$i][$j][0] + @upper_range[0] - @maps[$i][$j][1], @maps[$i][$j][0] + @upper_range[1] - @maps[$i][$j][1]);
							@next_curr_ranges.push(@lower_range);
							@next_ranges.push(@upper_range);
						}
						# If a lower part of the range is inside the mapping range
						elsif @range[0] >= @map_range[0] && @range[0] <= @map_range[1] && @range[1] > @map_range[1] {
							my @lower_range = (@range[0], @map_range[1]);
							my @upper_range = (@map_range[1] + 1, @range[1]);
							@lower_range = (@maps[$i][$j][0] + @lower_range[0] - @maps[$i][$j][1], @maps[$i][$j][0] + @lower_range[1] - @maps[$i][$j][1]);
							@next_ranges.push(@lower_range);
							@next_curr_ranges.push(@upper_range);
						}
						# If the range encloses the map range
						elsif(@range[0] < @map_range[0] && @range[1] > @map_range[1]) {
							my @lower_range = (@range[0], @map_range[0] - 1);
							my @middle_range = (@map_range[0], @map_range[1]);
							my @upper_range = (@map_range[1]+1, @range[1]);
							@middle_range = (@maps[$i][$j][0] + @middle_range[0] - @maps[$i][$j][1], @maps[$i][$j][0] + @middle_range[1] - @maps[$i][$j][1]);
							@next_curr_ranges.push(@lower_range);
							@next_ranges.push(@middle_range);
							@next_curr_ranges.push(@upper_range);
						}
					}
				}
				for @next_curr_ranges -> @next_range {
					@next_ranges.push(@next_range);
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
