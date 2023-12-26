unit module Day25;
use util;

# Return a connection string key with the components ordered alphabetically
sub conn_str($a,$b) {
	my @list;
	@list.push($a);
	@list.push($b);
	my @sorted = @list.sort();
	return @sorted[0] ~ "->" ~ @sorted[1];
}

# For all nodes reachable from the given key, count the occurences of each 
# connection and return the histogram
sub conn_count(%components, $key) {
	my %seen;
	my @frontier;
	my @frontier_next;
	@frontier_next.push([$key, 0, []]);
	while @frontier_next.elems > 0 {
		@frontier = @frontier_next;
		@frontier_next = ();
		for @frontier -> $item {
			my $component_key = $item[0];
			my $component_dist = $item[1];
			my $path = $item[2];
			%seen{$component_key} = $path;
			loop (my $i = 0; $i < %components{$component_key}.elems; $i++) {
				if %seen{%components{$component_key}[$i]}:exists {
					next;
				}
				my $next_path = $path.clone();
				$next_path.push(conn_str($component_key, %components{$component_key}[$i]));
				@frontier_next.push([%components{$component_key}[$i], $component_dist + 1, $next_path]);
			}
		}
	}
	my %connection_counts;
	for %seen.keys -> $key {
		my @path = %seen{$key};
		loop (my $i = 0; $i < @path[0].elems; $i++) {
			if %connection_counts{@path[0][$i]}:exists {
				%connection_counts{@path[0][$i]} += 1;
			}
			else {
				%connection_counts{@path[0][$i]} = 1;
			}
		}
	}
	return %connection_counts;
}

# Explore the graph with the given 3 connections broken and see if we can't reach
# every other component
sub test(%components, $break1, $break2, $break3) {
	my %reached;
	my $start = %components.keys[0];
	my @frontier;
	my @frontier_next;
	@frontier_next.push($start);
	while @frontier_next.elems > 0 {
		@frontier = @frontier_next;
		@frontier_next = ();
		for @frontier -> $key {
			if %reached{$key}:exists {
				next;
			}
			%reached{$key} = True;
			loop (my $i = 0; $i < %components{$key}.elems; $i++) {
				my $conn_str = conn_str($key, %components{$key}[$i]);
				# don't follow a broken link
				if $conn_str eq $break1 || $conn_str eq $break2 || $conn_str eq $break3 {
					next;
				}
				@frontier_next.push(%components{$key}[$i]);
			}
		}
	}
	if %reached.elems == %components.elems {
		return False;
	}
	else {
		return %reached.elems * (%components.elems - %reached.elems);
	}
}

sub day25(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my %components;
	for @lines -> $line {
		my @split1 = $line.split(": "):skip-empty;
		my $start = @split1[0];
		my @rest = @split1[1].words();
		if !(%components{$start}:exists) {
			%components{$start} = [];
		}
		for @rest -> $item {
			%components{$start}.push($item);
		}
		for @rest -> $item {
			if !(%components{$item}:exists) {
				%components{$item} = [];
			}
			%components{$item}.push($start);
		}
	}

	# Count occurences of each connections across optimal paths between all 
	# nodes.
	my %conn_counts;
	for %components.keys -> $key {
		my %component_connection_counts = conn_count(%components, $key);
		for %component_connection_counts.keys -> $key {
			if !(%conn_counts{$key}:exists) {
				%conn_counts{$key} = %component_connection_counts{$key};
			}
			else {
				%conn_counts{$key} += %component_connection_counts{$key};
			}
		}
	}

	# Order the set of connections by number of occurences
	my @keys_ordered;
	for %conn_counts.sort: *.value -> (:$key, :$value) {
		@keys_ordered.push($key);
	}
	my @keys_reversed = @keys_ordered.reverse;

	# With a list of all connections ordered by the number of times each 
	# appears in the shortest path between nodes, pick 3 starting with the 
	# three most common and working down until an answer is found.
	# The attempt_limit here is intended to speed things up a bit rather than
	# exhaustively trying every 3 keys, but may not work for every input and 
	# might need to be adjusted upwards if no solution is found.
	
	my $attempt_limit = 20; # limit attempts to the top 20 most common connections
	loop (my $i = 0; $i < $attempt_limit; $i++) {
		loop (my $j = $i+1; $j < $attempt_limit; $j++) {
			loop (my $k = $j+1; $k < $attempt_limit; $k++) {
				my $break1 = @keys_reversed[$i];
				my $break2 = @keys_reversed[$j];
				my $break3 = @keys_reversed[$k];
				my $result = test(%components, $break1, $break2, $break3);
				if $result === False {
					next;
				}
				$part1 = $result;
				last;
			}
		}
	}
	if $part1 == 0 {
		say "No solution found with current attempt limit $attempt_limit";
	}
	else {
		say "Part 1: $part1";	
	}
}
