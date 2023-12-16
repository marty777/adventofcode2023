unit module Day16;
use util;

class ReflectorGrid {
	has %.store;
	has Int $.width;
	has Int $.height;

	multi method new(@lines) {
		my $grid_width = @lines[0].chars;
		my $grid_height = @lines.elems;
		my %store;
		loop (my $y = 0; $y < $grid_height; $y++) {
			my $line = @lines[$y].split(""):skip-empty;
			loop (my $x = 0; $x < $grid_width; $x++) {
				if $line[$x] ne '.' {
					%store{"$x,$y"} = $line[$x];
				}
			}
		}
		return self.bless(store => %store, width=>$grid_width, height=>$grid_height);
	}

	# start_pos_x and $start_pos_y must be on the exterior edge of the grid, excluding the corners
	method trace($start_pos_x, $start_pos_y) {
		my $start_dir = [0,0];
		if $start_pos_x < 0 {
			$start_dir = [1,0];
		}
		elsif $start_pos_x >= self.width {
			$start_dir = [-1, 0];
		}
		elsif $start_pos_y < 0 {
			$start_dir = [0, 1];
		}
		elsif $start_pos_y >= self.height {
			$start_dir = [0, -1];
		}
		my $start_beam = [$start_pos_x,$start_pos_y,$start_dir[0],$start_dir[1]];
		# A hash of energized grid positions
		my %energized;
		my @frontier;
		my @frontier_next;
		# A hash of previously seen beam states to avoid infinite loops
		my %seen;
		@frontier_next.push($start_beam);
		while @frontier_next.elems > 0 {
			@frontier = @frontier_next;
			@frontier_next = ();
			for @frontier -> $beam {
				my $position_key = $beam[0] ~ ',' ~ $beam[1];
				%energized{$position_key} = True;
				my $next_beam_position = [$beam[0] + $beam[2], $beam[1] + $beam[3]];
				my $next_beam_direction = [$beam[2], $beam[3]];
				my $next_beam_position_key = $next_beam_position[0] ~ ',' ~ $next_beam_position[1];
				my $next_beam_seen_key = $next_beam_position[0] ~ ',' ~ $next_beam_position[1] ~ ',' ~ $next_beam_direction[0] ~ ',' ~ $next_beam_direction[1];
				if %seen{$next_beam_seen_key}:exists {
					next;
				}
				%seen{$next_beam_seen_key} = True;
				if (self.store{$next_beam_position_key}:exists) {
					if self.store{$next_beam_position_key} eq '-' && ($next_beam_direction eqv [0,-1] || $next_beam_direction eqv [0,1]) {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], -1, 0]);
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], 1, 0]);
					}
					elsif self.store{$next_beam_position_key} eq '|' && ($next_beam_direction eqv [-1,0] || $next_beam_direction eqv [1,0]) {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], 0, -1]);
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], 0, 1]);
					}
					elsif self.store{$next_beam_position_key} eq '\\' && ($next_beam_direction eqv [-1,0]) {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], 0, -1]);
					} 
					elsif self.store{$next_beam_position_key} eq '\\' && ($next_beam_direction eqv [1,0]) {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], 0, 1]);
					}
					elsif self.store{$next_beam_position_key} eq '\\' && ($next_beam_direction eqv [0,-1]) {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], -1,0]);
					}
					elsif self.store{$next_beam_position_key} eq '\\' && ($next_beam_direction eqv [0,1]) {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], 1,0]);
					} 
					elsif self.store{$next_beam_position_key} eq '/' && ($next_beam_direction eqv [-1,0]) {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], 0, 1]);
					}
					elsif self.store{$next_beam_position_key} eq '/' && ($next_beam_direction eqv [1,0]) {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], 0, -1]);
					}
					elsif self.store{$next_beam_position_key} eq '/' && ($next_beam_direction eqv [0,-1]) {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], 1, 0]);
					}
					elsif self.store{$next_beam_position_key} eq '/' && ($next_beam_direction eqv [0,1]) {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], -1, 0]);
					}
					else {
						@frontier_next.push([$next_beam_position[0], $next_beam_position[1], $next_beam_direction[0], $next_beam_direction[1]]);
					}
				}
				elsif($next_beam_position[0] >= 0 && $next_beam_position[0] < self.width && $next_beam_position[1] >= 0 && $next_beam_position[1] < self.height) {
					@frontier_next.push([$next_beam_position[0], $next_beam_position[1], $next_beam_direction[0],$next_beam_direction[1]]);
				}
			}
		}
		# The start position is outside the bounds of the grid and is omitted from the energized count
		%energized.elems - 1 ;
	}
	
}

sub day16(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my $grid = ReflectorGrid.new(@lines);
	# Trace a beam entering the grid from the top-left, heading right
	$part1 = $grid.trace(-1,0);

	loop (my $y = 0; $y < $grid.height; $y++) {
		my $from_left = $grid.trace(-1,$y);
		if $from_left > $part2 {
			$part2 = $from_left;
		}
		my $from_right = $grid.trace($grid.width,$y);
		if $from_right > $part2 {
			$part2 = $from_right;
		}
	}
	loop (my $x = 0; $x < $grid.width; $x++) {
		# left
		my $from_top = $grid.trace($x,-1);
		if $from_top > $part2 {
			$part2 = $from_top;
		}
		my $from_bottom = $grid.trace($x,$grid.height);
		if $from_bottom > $part2 {
			$part2 = $from_bottom;
		}
	}

	say "Part 1: $part1";
	say "Part 2: $part2";
}
