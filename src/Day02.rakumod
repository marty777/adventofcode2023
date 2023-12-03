unit module Day02;
use util;

sub day02(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;
	my %max = %{'red' => 12, 'green' => 13, 'blue' => 14};
	for @lines -> $line {
		my @split = $line.split(":");
		my $id = Int(@split[0].words[1]);
		my @rounds = @split[1].split(';');
		my $impossible = False;
		my %greatests = %{'red' => 0, 'green' => 0, 'blue' => 0};
		for @rounds -> $round {
			my %tiles = %{'red' => 0, 'green' => 0, 'blue' => 0};
			my @picks = $round.split(',');
			for @picks -> $pick {
				my @words = $pick.words;
				%tiles{@words[1]} = Int(@words[0]);
				for %greatests.keys -> $key {
					if %tiles{$key} > %greatests{$key} {
						%greatests{$key} = %tiles{$key};
					}
				}
				for %max.keys -> $key {
					if %tiles{$key} > %max{$key} {
						$impossible = True;
					}
				}
			}
		}
		if !$impossible {
			$part1 += $id;
		}
		$part2 += %greatests{'red'} * %greatests{'green'} * %greatests{'blue'};
	}
	say "Part 1: $part1";
	say "Part 2: $part2";
}
