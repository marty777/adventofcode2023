unit module Day18;
use util;


class Coord {
	has Int $.x is rw;
	has Int $.y is rw;

	multi method new($x,$y) { self.bless(x => $x, y => $y ); }
	multi method addmul($coord, $scalar) { self.x += $coord.x * $scalar; self.y += $coord.y * $scalar; }
}

# @digs should contain a list of [dist, dir], where dir is one of 
# 'R','D','L',U'
sub shoelace(@digs) {
	my @vertices;
	my $pos = Coord.new(0,0);
	@vertices.push(Coord.new(0,0));
	my $perimeter = 0;
	for @digs -> @dig {
		my $next_vertex = Coord.new($pos.x, $pos.y);
		my $dist = @dig[1];
		my $dir;
		given @dig[0] {
			when 'R' { $dir = Coord.new(1,0); }
			when 'D' { $dir = Coord.new(0,1); }
			when 'L' { $dir = Coord.new(-1,0); }
			when 'U' { $dir = Coord.new(0,-1); }
		}
		$pos.addmul($dir, $dist);
		@vertices.push(Coord.new($pos.x, $pos.y));
		$perimeter += $dist;
	}
	my $twice_area = 0;
	loop (my $i = 0; $i < @vertices.elems - 1; $i++) {
		$twice_area += @vertices[$i].x * @vertices[$i+1].y - @vertices[$i].y * @vertices[$i+1].x;
		
	}
	$twice_area += @vertices[@vertices.elems - 1].x * @vertices[0].y - @vertices[@vertices.elems - 1].y * @vertices[0].x;
	# I still can't figure out the reason why I need to add 1, but it works
	return $twice_area/2 + $perimeter/2 + 1;
}

sub day18(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my @digs1;
	my @digs2;
	for @lines -> $line {
		my $words = $line.words;
		
		# Part 1 input parsing
		my @dig1 = [$words[0], Int($words[1]), $words[2]];
		@digs1.push(@dig1);

		# Part 2 input parsing
		my $hex = $words[2].substr(2..6);
		my $dist2 = "0x$hex".Int;
		my $dirchar = $words[2].substr(7,1);
		my $dir2;
		given $dirchar {
			when '0' { $dir2 = 'R'; }
			when '1' { $dir2 = 'D' }
			when '2' { $dir2 = 'L' }
			when '3' { $dir2 = 'U' }
		}
		my @dig2 = [$dir2, $dist2];
		@digs2.push(@dig2);
	}

	$part1 = shoelace(@digs1);
	$part2 = shoelace(@digs2);
	say "Part 1: $part1";
	say "Part 2: $part2";
}
