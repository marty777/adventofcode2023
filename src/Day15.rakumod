unit module Day15;
use util;

sub day15(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my %boxes;
	loop (my $box_index = 0; $box_index < 256; $box_index++) {
		my @box;
		%boxes{$box_index} = @box;
	}
	for @lines -> $line {
		my @elements = $line.split(","):skip-empty;
		for @elements -> $element {
			my $hash_amt = 0;
			my @ascii_chars = $element.split(""):skip-empty;
			for @ascii_chars -> $char {
				$hash_amt += ord($char);
				$hash_amt *= 17;
				$hash_amt = $hash_amt % 256;
			}
			$part1 += $hash_amt;

			my $box_hash = 0;
			my $label = '';
			my $remove = False;
			my $focal_length = 0;
			loop (my $i = 0; $i < @ascii_chars.elems; $i++) {
				if @ascii_chars[$i] eq '-' {
					$remove = True;
					last;
				}
				elsif @ascii_chars[$i] eq '=' {
					$remove = False;
					$focal_length = Int(@ascii_chars[$i+1]);
					last;
				}
				else {
					my $char = @ascii_chars[$i];
					$box_hash += ord($char);
					$box_hash *= 17;
					$box_hash = $box_hash % 256;
					$label ~= @ascii_chars[$i];
				}
			}
			if $remove {
				loop ($i = 0; $i < %boxes{$box_hash}.elems; $i++) {
					if %boxes{$box_hash}[$i][0] eq $label {
						%boxes{$box_hash}.splice($i,1);
						last;
					}
				}
			}
			else {
				my $found = False;
				loop ($i = 0; $i < %boxes{$box_hash}.elems; $i++) {
					
					if %boxes{$box_hash}[$i][0] eq $label {
						$found = True;
						%boxes{$box_hash}[$i][1] = $focal_length;
					}
				}
				if !$found {
					%boxes{$box_hash}.push([$label, $focal_length]);
				}
			}
		}
	}
	loop (my $i = 0; $i < 256; $i++ ) {
		loop (my $j = 0; $j < %boxes{$i}.elems; $j++) {
			if %boxes{$i}[$j].elems > 1 {
				$part2 += ($i + 1) * ($j + 1) * %boxes{$i}[$j][1];
			}
		}
	}

	say "Part 1: $part1";
	say "Part 2: $part2";
}
