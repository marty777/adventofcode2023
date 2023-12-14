unit module Day14;
use util;

class RoundRock {
	has Int $.x is rw;
	has Int $.y is rw;

	multi method new($x, $y) {
		return self.bless(x => $x, y => $y);
	}
	method northLoad($grid_height) {
		return $grid_height - self.y;
	}
}

class RockGrid {
	has %.square_rocks;
	has Int $.width;
	has Int $.height;
	has	@.round_rocks;
	has	%.round_rocks_positions;

	multi method new(@lines) {
		my $grid_width = @lines[0].chars;
		my $grid_height = @lines.elems;
		my %square_rocks;
		my @round_rocks;
		my %round_rocks_positions;
		loop (my $y = 0; $y < $grid_height; $y++) {
			my @line = @lines[$y].split(""):skip-empty;
			loop (my $x = 0; $x < $grid_width; $x++) {
				if @line[$x] eq '#' {
					%square_rocks{"$x,$y"} = [$x,$y]
				}
				elsif @line[$x] eq 'O' {
					@round_rocks.push(RoundRock.new($x,$y));
					%round_rocks_positions{"$x,$y"} = @round_rocks.elems - 1;
				}
			}
		}
		return self.bless(square_rocks => %square_rocks, 
			width=>$grid_width, 
			height=>$grid_height, 
			round_rocks=>@round_rocks, 
			round_rocks_positions => %round_rocks_positions);
	}

	method print() {
		loop (my $y = 0; $y < self.height; $y++) {
			loop (my $x = 0; $x < self.width; $x++) {
				if self.square_rocks{"$x,$y"}:exists {
					print '#';
				}
				elsif self.round_rocks_positions{"$x,$y"}:exists {
					print 'O'
				}
				else {
					print '.'
				}
			}
			say " " ~ self.height - $y;
		}
	}

	method load() {
		my $total_load = 0;
		for self.round_rocks -> $rock {
			$total_load += $rock.northLoad(self.height);
		}
		return $total_load;
	}

	method tiltNorth() {
		loop (my $y = 0; $y < self.height; $y++) {
			loop (my $x = 0; $x < self.width; $x++) {
				# for each rounded rock, move it as far north as possible,
				# update the position and calculate the load
				if self.round_rocks_positions{"$x,$y"}:exists {
					my $round_rock_index = self.round_rocks_positions{"$x,$y"};
					my $y1 = $y - 1;
					while $y1 >= 0 {
						if self.square_rocks{"$x,$y1"}:exists {
							$y1 = $y1 + 1;
							last;
						}
						if self.round_rocks_positions{"$x,$y1"}:exists {
							$y1 = $y1 + 1;
							last;
						}
						$y1 -= 1;
					}
					if $y1 == -1 {
						$y1 = 0;
					}
					self.round_rocks[$round_rock_index].y = $y1;
					self.round_rocks_positions{"$x,$y"}:delete;
					self.round_rocks_positions{"$x,$y1"} = $round_rock_index;
					
				}
			}
		}
	}

	method tiltEast() {
		loop (my $x = self.width - 1; $x >= 0; $x--) {
			loop (my $y = 0; $y < self.height; $y++) {
				# for each rounded rock, move it as far east as possible,
				# update the position and calculate the load
				if self.round_rocks_positions{"$x,$y"}:exists {
					my $round_rock_index = self.round_rocks_positions{"$x,$y"};
					my $x1 = $x + 1;
					while $x1 < self.width {
						if self.square_rocks{"$x1,$y"}:exists {
							$x1 = $x1 - 1;
							last;
						}
						if self.round_rocks_positions{"$x1,$y"}:exists {
							$x1 = $x1 - 1;
							last;
						}
						$x1 += 1;
					}
					if $x1 == self.width {
						$x1 = self.width - 1;
					}
					self.round_rocks[$round_rock_index].x = $x1;
					self.round_rocks_positions{"$x,$y"}:delete;
					self.round_rocks_positions{"$x1,$y"} = $round_rock_index;
					
				}
			}
		}
	}
		
	method tiltSouth() {
		loop (my $y = self.height-1; $y >= 0; $y--) {
			loop (my $x = 0; $x < self.width; $x++) {
				# for each rounded rock, move it as far south as possible,
				# update the position and calculate the load
				if self.round_rocks_positions{"$x,$y"}:exists {
					my $round_rock_index = self.round_rocks_positions{"$x,$y"};
					my $y1 = $y + 1;
					while $y1 < self.height {
						if self.square_rocks{"$x,$y1"}:exists {
							$y1 = $y1 - 1;
							last;
						}
						if self.round_rocks_positions{"$x,$y1"}:exists {
							$y1 = $y1 - 1;
							last;
						}
						$y1 += 1;
					}
					if $y1 == self.height {
						$y1 = self.height-1;
					}
					self.round_rocks[$round_rock_index].y = $y1;
					self.round_rocks_positions{"$x,$y"}:delete;
					self.round_rocks_positions{"$x,$y1"} = $round_rock_index;
				}
			}
		}
	}

	method tiltWest() {
		loop (my $x = 0; $x < self.width; $x++) {
			loop (my $y = 0; $y < self.height; $y++) {
				# for each rounded rock, move it as far west as possible,
				# update the position and calculate the load
				if self.round_rocks_positions{"$x,$y"}:exists {
					my $round_rock_index = self.round_rocks_positions{"$x,$y"};
					my $x1 = $x - 1;
					while $x1 >= 0 {
						if self.square_rocks{"$x1,$y"}:exists {
							$x1 = $x1 + 1;
							last;
						}
						if self.round_rocks_positions{"$x1,$y"}:exists {
							$x1 = $x1 + 1;
							last;
						}
						$x1 -= 1;
					}
					if $x1 == -1 {
						$x1 = 0;
					}
					self.round_rocks[$round_rock_index].x = $x1;
					self.round_rocks_positions{"$x,$y"}:delete;
					self.round_rocks_positions{"$x1,$y"} = $round_rock_index;
				
				}
			}
		}
	}
}

sub day14(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my $rockgrid = RockGrid.new(@lines);

	$rockgrid.tiltNorth();
	$part1 = $rockgrid.load();

	$rockgrid.tiltWest();
	$rockgrid.tiltSouth();
	$rockgrid.tiltEast();

	my @loads;
	@loads.push($rockgrid.load());

	# Find a period to cycle loads and use it calculate the part 2 result.
	# The specific parameters used here were determined by observation of my
	# input and may not be applicable for others. But they're probably fine.
	my $cycle = 1;
	while $cycle < 170 {
		$rockgrid.tiltNorth();
		$rockgrid.tiltWest();
		$rockgrid.tiltSouth();
		$rockgrid.tiltEast();
		@loads.push($rockgrid.load());
		$cycle += 1;
	}
	my $start = 120; 	# by observation, things have settled down at this 
						# point in my input. 
	my $period = False;
	loop (my $window = 2; $window < 50; $window++) {
		my $cycle_found = True;
		loop (my $i = 0; $i < $window; $i++) {
			if @loads[$start + $i] != @loads[$start + $window + $i] {
				$cycle_found = False;
				last;
			}
		}
		if $cycle_found {
			say "Cycle found with size $window";
			$period = $window;
			last;
		}
	}
	if ($period === False) {
		say "Unable to find a period for part 2.";
		return;
	}

	# minus one because of 0-indexing
	$part2 = @loads[(((1000000000 - 1)- $start) % $period) + $start ];

	say "Part 1: $part1";
	say "Part 2: $part2";
}
