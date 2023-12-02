unit module Day02;
use util;

sub day02(@lines) is export {
	my $max_red = 12;
	my $max_green = 13;
	my $max_blue = 14;

    my $part1 = 0;
    my $part2 = 0;
    
	for @lines -> $line {
		my @split = $line.split(":");
		my $id = Int(@split[0].words[1]);
		my @rounds = @split[1].split(';');
		my $impossible = False;
		my $greatest_red = 0;
		my $greatest_green = 0;
		my $greatest_blue = 0;
		for @rounds -> $round {
			my $reds = 0;
			my $blues = 0;
			my $greens = 0;
			my @picks = $round.split(',');
			for @picks -> $pick {
				my @words = $pick.words;
				given @words[1] {
					when 'red' {
						$reds = Int(@words[0]);
						if $reds > $greatest_red {
							$greatest_red = $reds;
						}
					}
					when 'green' {
						$greens = Int(@words[0]);
						if $greens > $greatest_green {
							$greatest_green = $greens;
						}
					}
					when 'blue' {
						$blues = Int(@words[0]);
						if $blues > $greatest_blue {
							$greatest_blue = $blues;
						}
					}
				}
				if $reds > $max_red || $blues > $max_blue || $greens > $max_green {
					$impossible = True;
					last;	
				}
				if $impossible {
					last;
				}
			}
		}
		if !$impossible {
			$part1 += $id;
		}
		$part2 += $greatest_red * $greatest_green * $greatest_blue;
    }
	say "Part 1: $part1";
	say "Part 1: $part2";
}

 
