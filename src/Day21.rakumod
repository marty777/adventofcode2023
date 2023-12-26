unit module Day21;
use util;

class Coord {
	has Int $.x is rw;
	has Int $.y is rw;

	multi method new($x,$y) { self.bless(x => $x, y => $y ); }
	multi method new($coord) { self.bless(x => $coord.x, y => $coord.y ); }
	method copy() { return Coord.new(self.x, self.y); }
	multi method add($x,$y) { self.x += $x; self.y += $y; }
	multi method add($coord) { self.x += $coord.x; self.y += $coord.y; }
	method inbounds($grid_dim, $max_grids) { 
		if (self.x < -($grid_dim * $max_grids) || self.x >= $grid_dim * ($max_grids + 1) || self.y <  -($grid_dim * $max_grids) || self.y >= $grid_dim * ($max_grids + 1) ) { 
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

	method modkey($dim) {
		return (self.x % $dim) ~ ',' ~ (self.y % $dim);
	}

	method key() {
		return self.x ~ ',' ~ self.y;
	}
}

class GardenGrid {
	has %.store;
	has Int $.height;
	has Int $.width;
	has Int $.min_x;
	has Int $.max_x;
	has Int $.min_y;
	has Int $.max_y;
	has Coord $.start;

	multi method new(@lines) {
		my $start;
		my %store;
		my $height = @lines.elems;
		my $width = @lines[0].chars;
		# first pass, find S
		loop (my $y = 0; $y < @lines.elems; $y++) {
			my @line = @lines[$y].split(""):skip-empty;
			loop (my $x = 0; $x < @line.elems; $x++) {
				if @line[$x] eq 'S' {
					$start = Coord.new($x, $y);
				}
			}
		}

		# second pass
		loop ($y = 0; $y < @lines.elems; $y++) {
			my @line = @lines[$y].split(""):skip-empty;
			loop (my $x = 0; $x < @line.elems; $x++) {
				if @line[$x] ne '#' {
					%store{$x ~ ',' ~ $y} = True;
				}
			}
		}
		self.bless(
					store => %store, 
					width => $width, 
					height => $height, 
					min_x => 0, 
					max_x => $width - 1, 
					min_y => 0, 
					max_y => $height - 1, 
					start => $start);
	}
}

# explore all grid points in range on the repeating grid and count the ones reachable in $target_steps
sub plots_reachable($grid, $target_steps) {
	my %reached;
	my @frontier;
	my @frontier_next;
	my $max_grids = ($target_steps div $grid.width);
	@frontier_next.push($grid.start);
	my $steps = 0;
	while @frontier_next.elems > 0 {
		@frontier = @frontier_next;
		@frontier_next = ();
		for @frontier -> $coord {
			if (%reached{$coord.key()}:exists) {
				next;
			}
			%reached{$coord.key()} = $steps;
			my $n = Coord.new($coord);
			$n.add(0,-1);
			my $s = Coord.new($coord);
			$s.add(0,1);
			my $e = Coord.new($coord);
			$e.add(1,0);
			my $w = Coord.new($coord);
			$w.add(-1,0);
		

			if ($grid.store{$n.modkey($grid.width)}:exists) && !(%reached{$n.key()}:exists) && $n.inbounds($grid.width, $max_grids) {
				@frontier_next.push($n);
			}
			if ($grid.store{$w.modkey($grid.width)}:exists) && !(%reached{$w.key()}:exists) && $w.inbounds($grid.width, $max_grids) {
				@frontier_next.push($w);
			}
			if ($grid.store{$s.modkey($grid.width)}:exists) && !(%reached{$s.key()}:exists) && $s.inbounds($grid.width, $max_grids) {
				@frontier_next.push($s);
			}
			if ($grid.store{$e.modkey($grid.width)}:exists) && !(%reached{$e.key()}:exists) && $e.inbounds($grid.width, $max_grids) {
				@frontier_next.push($e);
			}
		}
		$steps += 1;
	}

	my $target_count = 0;
	for %reached.keys() -> $key {
		if %reached{$key} % 2 == $target_steps % 2 && %reached{$key} <= $target_steps {
			$target_count += 1;
		}
	}

	return $target_count;
}

sub day21(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my $grid = GardenGrid.new(@lines);

	$part1 = plots_reachable($grid, 64);

	# In lieu of a decent matrix solver, we can just solve the quadratic 
	# equation by hand
	# 26501365 % 131 = 65. 
	# Determine plots reachable in 65 + 0 * 131, 65 + 1 * 131 and 65 + 2 * 131 steps
	my $f_0 = plots_reachable($grid, 65);
	my $f_1 = plots_reachable($grid, 196);
	my $f_2 = plots_reachable($grid, 327);

	# The number of reachable steps are given by a quadratic function 
	# f(n) = n^2 * i + n * j + k for some i,j,k. 
	# In this case n = (number of steps) div 131
	# Solving for i,j,k by hand known f(0), f(1), f(2):
	# f(0) = 0*i + 0*j + k = k
	my $k = $f_0;
	# f(1) = i + j + k
	# f(2) = 4*i + 2*j + k
	# f(2) - 2 * f(1) - k = 2 * i => i = (f(2) - 2 * f(1))/2
	my $i = ($f_2 - 2 * $f_1)/2;
	my $j = $f_1 - $k - $i;
	my $n = 26501365 div 131;
	$part2 = $n*$n*$i + $n*$j + $k;

	say "Part 1: $part1";
	say "Part 2: $part2";
}
