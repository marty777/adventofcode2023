unit module Day24;
use util;

class Coord {
	has Num $.x is rw;
	has Num $.y is rw;
	has Num $.z is rw;

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
	method normalize() {
		my $len = self.len();
		self.x /= $len;
		self.y /= $len;
		self.z /= $len;
	}
	method normalized() {
		my $len = self.len();
		return Coord.new(self.x/$len, self.y/$len, self.x/$len);
	}
	method len() {return sqrt(self.len2())}
	method len2() {return (self.x * self.x) + (self.y * self.y) + (self.z * self.z);}
}


class HailStone {
	has Coord $.pos;
	has Coord $.vel;

	multi method new($line) {
		my @split = $line.split(" @ "):skip-empty;
		my @pos = @split[0].split(", ").map: {.Num()};
		my @vel = @split[1].split(", ").map: {.Num()};
		my $pos_coord = Coord.new(@pos[0], @pos[1], @pos[2]);
		my $vel_coord = Coord.new(@vel[0], @vel[1], @vel[2]);
		
		self.bless(pos => $pos_coord, vel => $vel_coord);
	}

}

# not 13470
sub part1(@hail) {
	my $dim_min = 200000000000000;
	my $dim_max = 400000000000000;
	my $intersections = 0;
	loop (my $i = 0; $i < @hail.elems; $i++) {
		loop (my $j = $i + 1; $j < @hail.elems; $j++) {
			
			# y = m*x + b
			# m = dy/dx
			# b = y - m * x
			my $i_m = @hail[$i].vel.y/@hail[$i].vel.x;
			my $j_m = @hail[$j].vel.y/@hail[$j].vel.x;
			my $i_b = @hail[$i].pos.y - ($i_m * @hail[$i].pos.x);
			my $j_b = @hail[$j].pos.y - ($j_m * @hail[$j].pos.x);
			# if parallel
			if $i_m == $j_m {
				next;
			}
			my $x = (($j_b - $i_b)/($i_m - $j_m));
			my $y = $i_m * $x + $i_b;
			# if the intersection is within the given bounds
			if $x >= $dim_min && $x <= $dim_max && $y >= $dim_min && $y <= $dim_max {
				
				my $i_future = True;
				my $j_future = True;
				if ($x > @hail[$i].pos.x && @hail[$i].vel.x < 0) || ($x < @hail[$i].pos.x && @hail[$i].vel.x > 0) {
					$i_future = False;
				}
				if ($x > @hail[$j].pos.x && @hail[$j].vel.x < 0) || ($x < @hail[$j].pos.x && @hail[$j].vel.x > 0) {
					$j_future = False;
				}
				if !$i_future || !$j_future {
					next;
				}
				$intersections++;
			}
		}
	}
	return $intersections;
}

sub day24(@lines) is export {
	my $part1 = 0;
	my @hail;
	for @lines -> $line {
		@hail.push(HailStone.new($line));
	}
	$part1 = part1(@hail);
	say "Part 1: $part1";
	say "Part 2: see Go solution in directory Day24/";
}
