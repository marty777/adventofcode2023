unit module Day17;
use util;

# correct, but wildly inefficient

class Coord {
	has Int $.x is rw;
	has Int $.y is rw;

	multi method new($x,$y) { self.bless(x => $x, y => $y ); }
	multi method new($coord) { self.bless(x => $coord.x, y => $coord.y ); }
	method copy() { return Coord.new(self.x, self.y); }
	multi method add($x,$y) { self.x += $x; self.y += $y; }
	multi method add($coord) { self.x += $coord.x; self.y += $coord.y; }
	method inbounds($width, $height) { 
		if (self.x < 0 || self.x >= $width || self.y < 0 || self.y >= $height) { 
			return False; 
		} 
		return True; 
	}
	method n() { return self.x == 0 && self.y == -1; }
	method e() { return self.x == 1 && self.y == 0; }
	method s() { return self.x == 0 && self.y == 1; }
	method w() { return self.x == -1 && self.y == 0; }
	method set_n() { self.x = 0; self.y = -1; }
	method set_e() { self.x = 1; self.y = 0; }
	method set_s() { self.x = 0; self.y = 1; }
	method set_w() { self.x = -1; self.y = 0; }
}
class State {
	has Coord 	$.pos is rw;
	has Coord 	$.dir is rw;
	has Int		$.loss is rw;
	has 		@.path is rw;
	multi method new($x,$y,$dir_x,$dir_y) {
		my @path;
		@path.push(Coord.new($x,$y));
		return self.bless(pos => Coord.new($x, $y), dir => Coord.new($dir_x, $dir_y), loss => 0, path=>@path);
	}
	multi method new($state) {
		return self.bless(pos => $state.pos.copy(), dir => $state.dir.copy(), loss => $state.loss, path=>$state.path.clone());
	}
	method forward(@grid) { 
		self.pos.add(self.dir);
		if !self.pos.inbounds(@grid[0].elems, @grid.elems) {
			return False;
		}
		self.path.push(Coord.new(self.pos));
		self.loss += @grid[self.pos.y][self.pos.x];
		return True;
	}
	method left(@grid) {
		my $next = State.new(self);
		if self.dir.n() {
			$next.dir.set_w(); 
		}
		elsif self.dir.e() {
			$next.dir.set_n(); 
		}
		elsif self.dir.s() {
			$next.dir.set_e(); 
		}
		elsif self.dir.w() {
			$next.dir.set_s(); 
		}
		my $ok = $next.forward(@grid);
		if !$ok {
			return False;
		}
		return $next;
	}
	method right(@grid) {
		my $next = State.new(self);
		if self.dir.n() {
			$next.dir.set_e(); 
		}
		elsif self.dir.e() {
			$next.dir.set_s(); 
		}
		elsif self.dir.s() {
			$next.dir.set_w(); 
		}
		elsif self.dir.w() {
			$next.dir.set_n(); 
		}
		my $ok = $next.forward(@grid);
		if !$ok {
			return False;
		}
		return $next;
	}
	# An attempt to match hashes faster, but Raku seems to coerce hash keys into strings in all cases. It's not helping the speed
	method key($moves, @grid) {
		my $height = @grid.elems;
		my $width = @grid.elems[0];
		my $key = (self.pos.x + $width * self.pos.y) * 8;
		$key += self.dir.x;
		$key *= 4;
		$key += self.dir.y;
		$key *= 20;
		$key += $moves;
		return $key;
	}
}

sub part1(@grid) {
	my $height = @grid.elems;
	my $width = @grid[0].elems;
	# Rather than starting from the start position, it's more convenient to start with the 
	# states of the only possible moves from the start position, moving east and moving south
	my $start_state_e = State.new(1,0,1,0);
	$start_state_e.loss = @grid[0][1];
	my $start_state_s = State.new(0,1,0,1);
	$start_state_s.loss = @grid[1][0];
	my %seen;
	my $best = -1;
	my @frontier;
	my @frontier_next;
	@frontier_next.push($start_state_e);
	@frontier_next.push($start_state_s);
	while @frontier_next.elems > 0 {
		@frontier = @frontier_next;
		@frontier_next = ();
		for @frontier -> $state {
			my $state_key = $state.key(1, @grid);
			# if the existing key is equal, it may be because it was added for this state
			if %seen{$state_key}:exists && %seen{$state_key} < $state.loss {
				next;
			}
			%seen{$state_key} = $state.loss;			
			# The crucible starts having moved 1 space, so continue for 2 more trying turns at each
			loop (my $forward = 0; $forward < 3; $forward++) {
				if $state.pos.x == $width - 1 && $state.pos.y == $height - 1 {
					if $best == -1 || $state.loss < $best {
						$best = $state.loss;
					}
					last;
				}
				my $left = $state.left(@grid);
				my $right = $state.right(@grid);
				if $left !=== False {
					my $left_key = $left.key(1, @grid);
					if !(%seen{$left_key}:exists) || %seen{$left_key} > $left.loss {					
						%seen{$left_key} = $left.loss;
						@frontier_next.push($left);
					}
				}
				if $right !=== False {
					my $right_key = $right.key(1, @grid);
					if !(%seen{$right_key}:exists) || %seen{$right_key} > $right.loss {
						%seen{$right_key} = $right.loss;					
						@frontier_next.push($right);
					}
				}
				my $forward_ok = $state.forward(@grid);
				if $forward_ok === False {
					last;
				}
				$state_key = $state.key($forward + 2, @grid);
				if %seen{$state_key}:exists && %seen{$state_key} <= $state.loss {
					last;
				} 
			}
		}
	}
	return $best;
}

sub part2(@grid) {
	my $height = @grid.elems;
	my $width = @grid[0].elems;
	# Rather than starting from the start position, it's more convenient to start with the 
	# states of the only possible moves from the start position, moving east and moving south
	my $start_state_e = State.new(1,0,1,0);
	$start_state_e.loss = @grid[0][1];
	my $start_state_s = State.new(0,1,0,1);
	$start_state_s.loss = @grid[1][0];
	my %seen := Hash[Int, Mu].new;
	my $best = -1;
	my @frontier;
	my @frontier_next;
	@frontier_next.push($start_state_e);
	@frontier_next.push($start_state_s);
	while @frontier_next.elems > 0 {
		@frontier = @frontier_next;
		@frontier_next = ();
		for @frontier -> $state {
			my $state_key = $state.key(1, @grid);
			if %seen{$state_key}:exists && %seen{$state_key} < $state.loss {
				next;
			}
			%seen{$state_key} = $state.loss;
			# The crucible starts having moved 1 space, so continue for 3 more, then try turns up to 9 spaces
			loop (my $forward = 0; $forward < 9; $forward++) {
				my $forward_ok = $state.forward(@grid);
				if $forward_ok === False {
					last;
				}
				$state_key = $state.key($forward + 2, @grid);
				if %seen{$state_key}:exists && %seen{$state_key} <= $state.loss {
					last;
				}
				%seen{$state_key} = $state.loss;
				if $forward >= 2 {
					if $state.pos.x == $width - 1 && $state.pos.y == $height - 1 {
						if $best == -1 || $state.loss < $best {
							$best = $state.loss;
						}
						last;
					}
					my $left = $state.left(@grid);
					my $right = $state.right(@grid);
					if $left !=== False {
						my $left_key = $left.key(1, @grid);
						if (!(%seen{$left_key}:exists) || %seen{$left_key} > $left.loss) {					
							%seen{$left_key} = $left.loss;
							@frontier_next.push($left);
						}
					}
					if $right !=== False {
						my $right_key = $right.key(1, @grid);
						if (!(%seen{$right_key}:exists) || %seen{$right_key} > $right.loss) {					
							%seen{$right_key} = $right.loss;
							@frontier_next.push($right);
						}
					}
				}
			}
		}
	}
	return $best;
}

sub day17(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my @grid;
	for @lines -> $line {
		my @chars = $line.split(""):skip-empty;
		@grid.push(@chars.map: {.Int()});
	}

	$part1 = part1(@grid);
	say "Part 1: $part1";

	$part2 = part2(@grid);
	say "Part 2: $part2";
}
