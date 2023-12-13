unit module Day13;
use util;

class ReflectionGrid {
	has @.store;
	has Int $.width;
	has Int $.height;

	multi method new(@lines) {
		my $grid_width = @lines[0].chars;
		my $grid_height = @lines.elems;
		my @store;
		loop (my $y = 0; $y < $grid_height; $y++) {
			my @line = @lines[$y].split(""):skip-empty;
			loop (my $x = 0; $x < $grid_width; $x++) {
				@store[$x + $y*$grid_width] = @line[$x] eq '#';
			}
		}
		
		return self.bless(store => @store, width=>$grid_width, height=>$grid_height);
	}

	multi method new(@store, $width, $height) {
		return self.bless(store => @store.clone, width=>$width, height=>$height);
	}

	method val($x,$y) {
		return self.store[$x + $y * self.width];
	}

	# Returns False if no horizontal reflection found, or else the 
	# [value, column] for the first horizontal reflection plane found that 
	# isn't at $last_y
	method horizontal_reflection($last_y) {
		loop (my $y = 0; $y < self.height - 1; $y++) {
			my $dim = $y + 1;
			if $dim > self.height - 1 - $y {
				$dim = self.height - 1 - $y;
			}
			my $match = True;
			loop (my $i = 1; $i <= $dim; $i++) {
				my $top = $y - $i + 1;
				my $bottom = $y + $i;
				loop (my $x = 0; $x < self.width; $x++) {
					
					if self.val($x, $top) != self.val($x, $bottom) {
						$match = False;
						last;
					}
				}
				if !($match) {
					last;
				}
			}
			if $match && $y != $last_y {
				return [($y + 1) * 100, $y];
			}
		}
		return False;
	}

	# Returns False if no vertical reflection found, or else 
	# the [value, column] for the first vertical reflection
	# plane found that isn't at $last_x
	method vertical_reflection($last_x) {
		loop (my $x = 0; $x < self.width - 1; $x++) {
			my $dim = $x + 1;
			if $dim > self.width - 1 - $x {
				$dim = self.width - 1 - $x;
			}
			my $match = True;
			loop (my $i = 1; $i <= $dim; $i++) {
				my $left = $x - $i + 1;
				my $right = $x + $i;
				loop (my $y = 0; $y < self.height; $y++) {
					
					if self.val($left, $y) != self.val($right, $y) {
						$match = False;
						last;
					}
				}
				if !($match) {
					last;
				}
			}
			if $match && $x != $last_x {
				return [$x + 1, $x];
			}
		}
		return False;
	}

	method desmudge() {
		my $horizontal = self.horizontal_reflection(-1);
		my $vertical = self.vertical_reflection(-1);
		my $original_x = -1;
		my $original_y = -1;
		if ($horizontal !== False) {
			$original_y = $horizontal[1];
		}
		else {
			$original_x = $vertical[1];
		}
		loop (my $y = 0; $y < self.height; $y++) {
			loop (my $x = 0; $x < self.width; $x++) {
				my $copy = ReflectionGrid.new(self.store, self.width, self.height);
				$copy.store[$x + $y*self.width] = !($copy.store[$x + $y*self.width]);
				my $horizontal1 = $copy.horizontal_reflection($original_y);
				my $vertical1 = $copy.vertical_reflection($original_x);
				if $horizontal1 === False && $vertical1 === False {
					next;
				}
				if $horizontal1 !== False {
					return $horizontal1[0];
				}
				else {
					return $vertical1[0];
				}
			}
		}
		# We shouldn't hit this
		say "No new reflection found";
		return 0;
	}
}

sub day13(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my $start_index = 0;
	my $curr_index = 0;

	for @lines -> $line {
		if ($line.chars == 0) {
			my $reflection_grid = ReflectionGrid.new(@lines[$start_index..$curr_index - 1]);
			$start_index = $curr_index + 1;
			my $horizontal = $reflection_grid.horizontal_reflection(-1);
			my $vertical = $reflection_grid.vertical_reflection(-1);
			if ($horizontal !== False) {
				$part1 += $horizontal[0];
			}
			else {
				$part1 += $vertical[0];
			}
			$part2 += $reflection_grid.desmudge();
			
		}
		# For the final block
		elsif($curr_index == @lines.elems - 1) {
			my $reflection_grid = ReflectionGrid.new(@lines[$start_index..$curr_index]);
			$start_index = $curr_index + 1;
			my $horizontal = $reflection_grid.horizontal_reflection(-1);
			my $vertical = $reflection_grid.vertical_reflection(-1);			
			if ($horizontal !== False) {
				$part1 += $horizontal[0];
			}
			else {
				$part1 += $vertical[0];
			}
			$part2 += $reflection_grid.desmudge();

		}
		$curr_index++;
	}
	say "Part 1: $part1";
	say "Part 2: $part2";
}
