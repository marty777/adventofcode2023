unit module Day04;
use util;


sub day04(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my @cards = ();
	#part 1
	for @lines -> $line {
		my @split1 = $line.split(":");
		my @split2 = @split1[1].split("|",:skip-empty);
		# put the winning numbers in a hash for needlessly faster lookup
		my @winning_numbers_w = @split2[0].words;
		my %winning_numbers = ();
		for @winning_numbers_w -> $word {
			%winning_numbers{Int($word)} = True;
		}
		my @card_numbers = @split2[1].words.map: {.Int()};
		my $wins = 0;
		for @card_numbers -> $num {
			if %winning_numbers{$num}:exists {
				$wins += 1;
			}
		}
		if $wins > 0 {
			$part1 += 0x01 +< ($wins - 1);
		}
		@cards.push($wins);		
	}
	# part 2
	my @cardtotals;
	for @cards -> $card {
		@cardtotals.push(1);
	}
	loop (my $i = 0; $i < @cardtotals.elems; $i++) {
		loop (my $j = 1; $j <= @cards[$i]; $j++) {
			@cardtotals[$i + $j] += @cardtotals[$i];
		}
	}
	$part2 = @cardtotals.sum;
	
	say "Part 1: $part1";
	say "Part 2: $part2";
}
