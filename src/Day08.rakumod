unit module Day08;
use util;

sub day08(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my %nodes;
	my @lrs = @lines[0].split(""):skip-empty;
	loop (my $i = 2; $i < @lines.elems; $i++) {
		my @split1 = @lines[$i].split(" = "):skip-empty;
		my $node = @lines[$i].substr(0,3);
		my $left = @lines[$i].substr(7,3);
		my $right = @lines[$i].substr(12,3);
		%nodes{$node} = ($left, $right);
	}
	my $node = 'AAA';
	my $finish = 'ZZZ';
	my $lr_index = 0;
	my $steps = 0;
	while $node ne $finish {
		if @lrs[$lr_index] eq 'L' {
			$node = %nodes{$node}[0];
		}
		else {
			$node = %nodes{$node}[1];
		}
		$lr_index = ($lr_index + 1) % @lrs.elems;
		$steps += 1;
	}
	$part1 = $steps;

	# Supposition (which turned out to be on the money) - all A -> Z nodes form
	# a cycle and we're doing a least common multiple calculation on them to 
	# determine the minimum period of the combined cycle

	# Get all nodes ending in A
	my @As;
	for %nodes.keys -> $key {
		my @key_chars = $key.split(""):skip-empty;
		if @key_chars[2] eq 'A' {
			@As.push($key);
		}
	}
	# For each A node, determine the period of it's cycle, assumed to be
	# the first Z node it reaches.
	my @periods;
	for @As -> $a {
		my $node = $a;
		my $steps = 0;
		$lr_index = 0;
		while True {
			my @node_chars = $node.split(""):skip-empty;
			if @node_chars[2] eq 'Z' {
				@periods.push($steps);
				last;
			}
			if @lrs[$lr_index] eq 'L' {
				$node = %nodes{$node}[0];
			}
			else {
				$node = %nodes{$node}[1];
			}
			$lr_index = ($lr_index + 1) % @lrs.elems;
			$steps += 1;
		}
	}
	# determine the combined LCM of all periods
	my $part2 = @periods[0];
	loop ($i = 1; $i < @periods.elems; $i++) {
		$part2 = $part2 lcm @periods[$i];
	}

	say "Part 1: $part1";
	say "Part 2: $part2";
}
