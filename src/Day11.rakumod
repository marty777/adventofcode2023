unit module Day11;
use util;


class Grid {
	has %.store;
	has Int $.width;
	has Int $.height;
	
	# Create the grid from the provided file lines, plus a multiple for 
	# expansion of empty rows and columns
	multi method new(@lines, $expansion) {
		my @start_grid = ();
		my $start_width = @lines[0].chars;
		my $start_height = @lines.elems;
		my %rows;
		my %cols;
		# Read all lines into an array
		loop (my $y = 0; $y < $start_height; $y++) {
			my @line = @lines[$y].split(""):skip-empty;
			loop (my $x = 0; $x < $start_width; $x++) {
				@start_grid.push(@line[$x]);
			}
		}
		# Find empty rows and columns		
		loop (my $y = 0; $y < $start_height; $y++) {
			my $empty = True;
			loop (my $x = 0; $x < $start_width; $x++) {
				if @start_grid[$x + $y*$start_width] eq '#' {
					$empty = False;
					last;
				}
			}
			if $empty {
				%rows{$y} = True;
			}
		}
		loop (my $x = 0; $x < $start_width; $x++) {
			my $empty = True;
			loop (my $y = 0; $y < $start_height; $y++) {
				if @start_grid[$x + $y*$start_width] eq '#' {
					$empty = False;
					last;
				}
			}
			if $empty {
				%cols{$x} = True;
			}
		}

		my %store = %();
		
		loop (my $y = 0; $y < $start_height; $y++) {
			loop (my $x = 0; $x < $start_width; $x++) {
				if @start_grid[$x + $y*$start_height] eq '#' {
					my $empty_rows = 0;
					my $empty_cols = 0;
					for %rows.keys -> $key {
						if $key < $y {
							$empty_rows += 1;
						}
					}
					for %cols.keys -> $key {
						if $key < $x {
							$empty_cols += 1;
						}
					}
					# expansion minus one because the original empty column is already included
					my $x1 = ($expansion - 1) * $empty_cols + $x;
					my $y1 = ($expansion - 1) * $empty_rows + $y;
					%store{"$x1,$y1"} = [$x1, $y1];
				}
			}
		}
		return self.bless(store => %store, width => ($start_width + %cols.keys.elems), height => ($start_height + %rows.keys.elems));
	}

	# Find the sum of manhattan distances between each pair of galaxies
	method between() {
		my @galaxies = self.store.values;
		my $path_sum = 0;
		loop (my $i = 0; $i < @galaxies.elems; $i++) {
			loop (my $j = $i + 1; $j < @galaxies.elems; $j++) {
				my $dist = abs(@galaxies[$i][0] - @galaxies[$j][0]) +  abs(@galaxies[$i][1] - @galaxies[$j][1]);
				$path_sum += $dist;
			}
		}
		return $path_sum;
	}
}


sub day11(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my $grid1 = Grid.new(@lines, 2);
	my $grid2 = Grid.new(@lines, 1_000_000);
	$part1 = $grid1.between();
	$part2 = $grid2.between();

	say "Part 1: $part1";
	say "Part 2: $part2";
}
