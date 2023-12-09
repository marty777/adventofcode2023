unit module Day09;
use util;

sub next(@history) {
	my @layers;
	@layers[0] = @history;
	my $layer_index = 0;
	while True {
		my @next_layer;
		loop (my $i = 1; $i < @layers[$layer_index].elems; $i++) {
			@next_layer.push(@layers[$layer_index][$i] - @layers[$layer_index][$i-1] );
		}
		my $layer_zeros = True;
		for @next_layer -> $val {
			if $val != 0 {
				$layer_zeros = False;
				last;
			}
		}
		@layers.push(@next_layer);
		$layer_index++;
		if $layer_zeros {
			last;
		}	
	}
	my $last = 0;
	loop (my $i = @layers.elems - 2; $i >= 0; $i--) {
		@layers[$i].push(@layers[$i][@layers[$i].elems - 1] + $last);
		$last = @layers[$i][@layers[$i].elems - 1];
	}
	return @layers[0][@layers[0].elems - 1];
}

sub previous(@history) {
	my @layers;
	@layers[0] = @history;
	my $layer_index = 0;
	while True {
		my @next_layer;
		loop (my $i = 1; $i < @layers[$layer_index].elems; $i++) {
			@next_layer.push(@layers[$layer_index][$i] - @layers[$layer_index][$i-1] );
		}
		my $layer_zeros = True;
		for @next_layer -> $val {
			if $val != 0 {
				$layer_zeros = False;
				last;
			}
		}
		@layers.push(@next_layer);
		$layer_index++;
		if $layer_zeros {
			last;
		}	
	}
	my $last = 0;
	loop (my $i = @layers.elems - 2; $i >= 0; $i--) {
		@layers[$i].unshift(@layers[$i][0] - $last);
		$last = @layers[$i][0];
	}
	return @layers[0][0];
}

sub day09(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;
	for @lines -> $line {
		my @history = $line.words.map: {.Int()};
		$part1 += next(@history);
		$part2 += previous(@history);
	}
	say "Part 1: $part1";
	say "Part 2: $part2";
}
