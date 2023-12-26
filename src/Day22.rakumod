unit module Day22;
use util;

class Coord {
	has Int $.x is rw;
	has Int $.y is rw;
	has Int $.z is rw;

	multi method new($x,$y,$z) { self.bless(x => $x, y => $y, z => $z ); }
	multi method new($coord) { self.bless(x => $coord.x, y => $coord.y, z => $coord.z ); }
	method copy() { return Coord.new(self.x, self.y, self.z); }
	multi method add($x,$y,$z) { self.x += $x; self.y += $y; self.z += $z }
	multi method add($coord) { self.x += $coord.x; self.y += $coord.y; self.z += $coord.z }
	method key() {
		return self.x ~ ',' ~ self.y ~ ',' ~self.z;
	}
	method equal($coord) {
		return self.x == $coord.x && self.y == $coord.y && self.z == $coord.z;
	}
}

class Brick {
	has Coord $.dim;
	has Coord $.initial;
	has Coord $.current is rw;
	has Coord $.axis;

	multi method new($line) {
		my @split = $line.split("~"):skip-empty;
		my @start = @split[0].split(",").map: {.Int()};
		my @end = @split[1].split(",").map: {.Int()};

		my $min_x = min(@start[0], @end[0]);
		my $min_y = min(@start[1], @end[1]);
		my $min_z = min(@start[2], @end[2]);

		my $max_x = max(@start[0], @end[0]);
		my $max_y = max(@start[1], @end[1]);
		my $max_z = max(@start[2], @end[2]);

		my $x_axis = $max_x != $min_x;
		my $y_axis = $max_y != $min_y;
		my $z_axis = $max_z != $min_z;

		self.bless(
					dim => Coord.new($max_x - $min_x + 1, $max_y - $min_y + 1, $max_z - $min_z + 1),
					initial => Coord.new($min_x, $min_y, $min_z),
					current => Coord.new($min_x, $min_y, $min_z),
					axis => Coord.new($x_axis, $y_axis, $z_axis) 
					);
	} 
	multi method new($dim, $current) {
		my $x_axis = $dim.x > 1;
		my $y_axis = $dim.y > 1;
		my $z_axis = $dim.z > 1;

		self.bless(
					dim => $dim.copy(),
					initial => $current.copy(),
					current => $current.copy(),
					axis => Coord.new($x_axis, $y_axis, $z_axis) 
					);
	}



	method reset() {
		self.current = self.initial.copy();
	}

	# return all coordinates at the greatest z level + 1
	method top() {
		my @coords;
		if self.axis.z == True {
			my $top = self.current.copy();
			$top.z += self.dim.z;
			@coords.push($top);
		}
		elsif self.axis.y == True {
			loop (my $y = 0; $y < self.dim.y; $y++) {
				my $top = self.current.copy();
				$top.y += $y;
				$top.z += 1;
				@coords.push($top);
			}
		}
		elsif self.axis.x == True {
			loop (my $x = 0; $x < self.dim.x; $x++) {
				my $top = self.current.copy();
				$top.x += $x;
				$top.z += 1;
				@coords.push($top);
			}
		}
		# a single brick
		else {
			my $top = self.current.copy();
			$top.z += 1;
			@coords.push($top);
		}
		if @coords.elems == 0 {
			say "ERROR: empty top";
		}
		return @coords;
	}

	# return all coordinates at the lowest z level
	method bottom() {
		my @coords;
		if self.axis.z == True {
			my $bottom = self.current.copy();
			@coords.push($bottom);
		}
		elsif self.axis.y == True {
			loop (my $y = 0; $y < self.dim.y; $y++) {
				my $bottom = self.current.copy();
				$bottom.y += $y;
				@coords.push($bottom);
			}
		}
		elsif self.axis.x == True {
			loop (my $x = 0; $x < self.dim.x; $x++) {
				my $bottom = self.current.copy();
				$bottom.x += $x;
				@coords.push($bottom);
			}
		}
		# a single cube
		else {
			my $bottom = self.current.copy();
			@coords.push($bottom);
		}
		if @coords.elems == 0 {
			say "ERROR: empty bottom";
		}
		return @coords;
	}

}

sub reset_bricks(@bricks) {
	for @bricks -> $brick {
		$brick.reset();
	}
}

sub coords_intersect(@coords1, @coords2) {
	for @coords1 -> $coord1 {
		for @coords2 -> $coord2 {
			if $coord1.equal($coord2) {
				return True;
			}
		}
	}
	for @coords2 -> $coord2 {
		for @coords1 -> $coord1 {
			if $coord1.equal($coord2) {
				return True;
			}
		}
	}
	return False;
}

# sort all bricks into buckets by maximum z coordinate
sub tops(@bricks) {
	my %tops;
	loop (my $i = 0; $i < @bricks.elems; $i++) {
		my $max_z = @bricks[$i].current.z + @bricks[$i].dim.z - 1;
		if !(%tops{$max_z}:exists) {
			my @tops_z;
			@tops_z.push($i);
			%tops{$max_z} = @tops_z;
		}
		else {
			%tops{$max_z}.push($i);
		}
	}
	return %tops;
}
# sort all bricks into buckets by minimum z coordinate
sub bottoms(@bricks) {
	my %bottoms;
	loop (my $i = 0; $i < @bricks.elems; $i++) {
		my $min_z = @bricks[$i].current.z;
		if !(%bottoms{$min_z}:exists) {
			my @bottoms_z;
			@bottoms_z.push($i);
			%bottoms{$min_z} = @bottoms_z;
		}
		else {
			%bottoms{$min_z}.push($i);
		}
	}
	return %bottoms;
}

# return the supporting bricks for the brick with the given index
sub supporting_bricks(@bricks, $index, %tops) {
	my @supporting_bricks;
	my $min_z = @bricks[$index].current.z;
	#my $max_z = $min_z + @bricks[$index].dim.z - 1;
	# on the ground
	if $min_z == 1 {
		return @supporting_bricks;
	}
	my @curr_bottom = @bricks[$index].bottom();
	#my @all = @bricks[$index].all(-1);
	if %tops{$min_z - 1}:exists {
		loop (my $j = 0; $j < %tops{$min_z - 1}.elems; $j++) {
			# I don't think this can happen, but to be safe					
			my $other_index = %tops{$min_z - 1}[$j];
			if $other_index == $index {
				next;
			}
			# test for intersection if dropped one space
			my @other_top = @bricks[$other_index].top();
			if coords_intersect(@other_top, @curr_bottom) {
				@supporting_bricks.push($other_index);
			}
		}
	}
	return @supporting_bricks;
}

# return all bricks supported by the indexed brick
sub supported_bricks(@bricks, $index, %tops, %bottoms) {
	my @supported_bricks;
	my $min_z = @bricks[$index].current.z;
	my $max_z = $min_z + @bricks[$index].dim.z - 1;
	# all current coords at the top of the brick, raised by 1 
	my @curr_top = @bricks[$index].top();
	if %bottoms{$max_z + 1}:exists {
		loop (my $j = 0; $j < %bottoms{$max_z + 1}.elems; $j++) {
			# I don't think this can happen, but to be safe					
			my $other_index = %bottoms{$max_z + 1}[$j];
			if $other_index == $index {
				next;
			}
			# test for intersection 
			my @other_bottom = @bricks[$other_index].bottom();
			if coords_intersect(@other_bottom, @curr_top) {
				@supported_bricks.push($other_index);
			}
		}
	}
	return @supported_bricks;
}

# update all bricks to the resting position
sub drop(@bricks) {
	my $updated_bricks = -1;
	while $updated_bricks != 0 {
		$updated_bricks = 0;
		# not a problem with keeping this updated. Does the same thing if it's rebuilt for each brick.
		my %tops = tops(@bricks);
		loop (my $i = 0; $i < @bricks.elems; $i++) {
			
			my $min_z = @bricks[$i].current.z;
			my $max_z = @bricks[$i].current.z + @bricks[$i].dim.z - 1;
			if $min_z == 1 {
				next;
			}
			my @supporting_bricks = supporting_bricks(@bricks, $i, %tops);
			if @supporting_bricks.elems == 0 {
				$updated_bricks += 1;
				@bricks[$i].current.z -= 1;
				# update top index
				my $top_index = -1;
				loop (my $j = 0; $j < %tops{$max_z}.elems; $j++) {
					if $i == %tops{$max_z}[$j] {
						$top_index = $j;
						last;
					}
				}
				if $top_index == -1 {
					say "Error updating top index for brick $i with last_max_z $max_z";
				}
				else {
					if %tops{$max_z}.elems == 1 {
						%tops{$max_z}:delete;
					}
					else {
						%tops{$max_z}.splice($top_index, 1);
					}
					if !(%tops{$max_z - 1}:exists) {
						my @tops_z;
						@tops_z.push($i);
						%tops{$max_z - 1} = @tops_z;
					}
					else {
						%tops{$max_z - 1}.push($i);
					}
				}

			}
		}
	}
}

# return a copy of all bricks in the dropped position
sub post_drop(@bricks) {
	my @dropped_bricks;
	for @bricks -> $brick {
		@dropped_bricks.push(Brick.new($brick.dim, $brick.current));
	}
	return @dropped_bricks;
}

sub drop2(@bricks, $index) {
	reset_bricks(@bricks);
	# remove the brick at the given index from the simulation
	# by putting it underground
	@bricks[$index].current.z = -@bricks[$index].dim.z - 1;
	my %fallen_bricks;
	my $updated_bricks = -1;
	while $updated_bricks != 0 {
		$updated_bricks = 0;
		# not a problem with keeping this updated. Does the same thing if it's rebuilt for each brick.
		my %tops = tops(@bricks);
		loop (my $i = 0; $i < @bricks.elems; $i++) {
			if $i == $index {
				next;
			}
			my $min_z = @bricks[$i].current.z;
			my $max_z = @bricks[$i].current.z + @bricks[$i].dim.z - 1;
			if $min_z == 1 {
				next;
			}
			my @supporting_bricks = supporting_bricks(@bricks, $i, %tops);
			if @supporting_bricks.elems == 0 {
				$updated_bricks += 1;
				%fallen_bricks{$i} = True;
				@bricks[$i].current.z -= 1;
				# update top index
				my $top_index = -1;
				loop (my $j = 0; $j < %tops{$max_z}.elems; $j++) {
					if $i == %tops{$max_z}[$j] {
						$top_index = $j;
						last;
					}
				}
				if $top_index == -1 {
					say "Error updating top index for brick $i with last_max_z $max_z";
				}
				else {
					if %tops{$max_z}.elems == 1 {
						%tops{$max_z}:delete;
					}
					else {
						%tops{$max_z}.splice($top_index, 1);
					}
					if !(%tops{$max_z - 1}:exists) {
						my @tops_z;
						@tops_z.push($i);
						%tops{$max_z - 1} = @tops_z;
					}
					else {
						%tops{$max_z - 1}.push($i);
					}
				}

			}
		}
	}
	return %fallen_bricks.keys.elems;
}

sub part1(@bricks) {
	# for each brick, determine every brick it supports.
	# if the supported brick is supported by at least one
	# other brick, it is safe to remove the current brick
	my $removal_count = 0;
	my %tops = tops(@bricks);
	my %bottoms = bottoms(@bricks);
	# pre-build a list of bricks supporting each brick
	my @supporting;
	loop (my $i = 0; $i < @bricks.elems; $i++) {
		@supporting.push(supporting_bricks(@bricks, $i, %tops));
	}
	loop ($i = 0; $i < @bricks.elems; $i++) {
		my @supported_bricks = supported_bricks(@bricks, $i, %tops, %bottoms);
		my $exclusively_supported_bricks = 0;
		loop (my $j = 0; $j < @supported_bricks.elems; $j++) {
			if @supporting[@supported_bricks[$j]] == 1 {
				$exclusively_supported_bricks += 1;
			}
		}
		if $exclusively_supported_bricks == 0 {
			$removal_count += 1;
		}		
	}

	return $removal_count;
}

sub day22(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my @bricks;
	for @lines -> $line {
		@bricks.push(Brick.new($line));
	}
	my @sorted_bricks = @bricks.sort: {$^b.current.z < $^a.current.z};
	drop(@sorted_bricks);
	
	$part1 = part1(@sorted_bricks);
	say "Part 1: $part1";
	
	my @resting_bricks = post_drop(@sorted_bricks);
	loop (my $i = 0; $i < @resting_bricks.elems; $i++) {
		my $dropped = drop2(@resting_bricks, $i);
		$part2 += $dropped;
	}
	say "Part 2: $part2";
}