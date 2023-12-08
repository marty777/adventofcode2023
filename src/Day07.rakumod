unit module Day07;
use util;

# There has to be a way to do this succinctly in Raku, but I'm a noob
sub indexInCharArray(@array,$char) {
	loop (my $i = 0; $i < @array.elems; $i++) {
		if @array[$i] eq $char {
			return $i;
		}
	}
	die "Unable to find character $char in array @array";
}

# Return relative order of @hand1 and @hand2.
sub compare(@hand1, @hand2, @card_order) {
	my $hand1_type = @card_order[0] eq 'J' ?? prime_order2(@hand1) !! prime_order(@hand1);
	my $hand2_type = @card_order[0] eq 'J' ?? prime_order2(@hand2) !! prime_order(@hand2);
	if $hand1_type > $hand2_type {
		return Order::More;
	}
	elsif $hand1_type < $hand2_type {
		return Order::Less;
	}
	else {
		loop (my $i = 0; $i < 5; $i++ ) {
			if @hand1[$i] eq @hand2[$i] {
				next;
			}
			my $hand1_index = indexInCharArray(@card_order, @hand1[$i]);
			my $hand2_index = indexInCharArray(@card_order, @hand2[$i]);
			if $hand1_index > $hand2_index {
				return Order::More;
			}
			else {
				return Order::Less;
			}
		}
		return Order::Same;
	}
}

sub prime_order(@hand) {
	# Get counts of card labels
	my %buckets;
	for @hand -> $card {
		if %buckets{$card}:exists {
			%buckets{$card} += 1;
		}
		else {
			%buckets{$card} = 1;
		}
	}
	return hand_type(%buckets.values);
}

sub prime_order2(@hand) {
	my %buckets;
	my $jokers = 0;
	# Get count of all non-joker card labels in hand plus a separate count for 
	# jokers
	for @hand -> $card {
		if $card eq 'J' {
			$jokers += 1;
			next;
		}
		if %buckets{$card}:exists { %buckets{$card} += 1; }
		else { %buckets{$card} = 1; }
	}
	# if 5 jokers we have 5 of a kind
	if $jokers == 5 { return 6; }
	# otherwise, add any jokers to the highest card count
	my @counts= %buckets.values.sort();
	@counts[@counts.elems - 1] += $jokers;
	return hand_type(@counts);
}

# Hand types ordered as integers 0-6
sub hand_type(@counts) {
	# 5 of a kind
	if @counts.grep(5).elems > 0 {
		return 6;
	}
	# 4 of a kind
	if @counts.grep(4).elems > 0 {
		return 5;
	}
	# Full house
	if @counts.grep(3).elems > 0 && @counts.grep(2).elems  > 0 {
		return 4;
	}
	# 3 of a kind
	if @counts.grep(3).elems > 0 {
		return 3;
	}
	# 2 pair
	if @counts.grep(2).elems > 1 {
		return 2;
	}
	# 1 pair
	if @counts.grep(2).elems > 0 {
		return 1;
	}
	# High card
	return 0;
}

sub day07(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my @card_order1 = "23456789TJQKA".split("");
	my @card_order2 = "J23456789TQKA".split("");
	my @pairs = ();
	for @lines -> $line {
		my @hand = $line.words[0].split(""):skip-empty;
		my $bid = Int($line.words[1]);
		@pairs.push((@hand, $bid));
	}
	my @sorted1 =  @pairs.sort:{ compare($^a[0], $^b[0], @card_order1)};
	my @sorted2 =  @pairs.sort:{ compare($^a[0], $^b[0], @card_order2)};
	loop (my $i = 0; $i < @pairs.elems; $i++) {
		$part1 += ($i + 1) * @sorted1[$i][1];
		$part2 += ($i + 1) * @sorted2[$i][1];
	}
	
	say "Part 1: $part1";
	say "Part 2: $part2";
}
