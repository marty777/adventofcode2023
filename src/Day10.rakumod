unit module Day10;
use util;

# This implementation would benefit from a coordinate class rather than using
# arrays to store (x,y), but maybe another time...

class Pipe {
	has Bool $.n;
	has Bool $.e;
	has Bool $.s;
	has Bool $.w;
	has Int $.x;
	has Int $.y;

	multi method new($x, $y) {
		my $n = False;
		my $s = False;
		my $e = False;
		my $w = False;
		my $empty = True;
		return self.bless(n => $n, e => $e, s => $s, w => $w, x=>$x, y=>$y);
	}

	multi method new($char, $x,$y) {
		my $n = False;
		my $s = False;
		my $e = False;
		my $w = False;
		given $char {
			when '|' {$n = True; $s = True;}
			when '-' {$e = True; $w = True;}
			when 'L' {$n = True; $e = True;}
			when 'J' {$n = True; $w = True;}
			when '7' {$s = True; $w = True;}
			when 'F' {$s = True; $e = True;}
		}
		return self.bless(n => $n, e => $e, s => $s, w => $w, x=>$x, y=>$y);
	} 
	# For start node initialization
	multi method new($n, $s, $e, $w, $x, $y) {
		return self.bless(n => $n, e => $e, s => $s, w => $w, x=>$x, y=>$y);
	} 
	method is_empty() {
		return !(self.n || self.s || self.e || self.w);
	}
	method key() {
		return self.x ~ ',' ~ self.y;
	}
	method available_dirs() {
		if self.is_empty {
			return ();
		}
		my @dirs;
		if self.n {
			@dirs.push([0,-1]);
		}
		if self.s {
			@dirs.push([0,1]);
		}
		if self.e {
			@dirs.push([1,0]);
		}
		if self.w {
			@dirs.push([-1,0]);
		}
		return @dirs;
	}
}

class PipeGrid {
	has %.store;
	has Int $.width;
	has Int $.height;
	has Int $.start_x;
	has Int $.start_y;

	multi method new($width, $height) {
		my %store = %();
		return self.bless(store => %store, width=>$width, height=>$height, start_x => 0, start_y => 0);
	}
	
	multi method new(@lines) {
		my $grid_width = @lines[0].chars;
		my $grid_height = @lines.elems;
		my %store = %();
		my @start = (0,0);
		loop (my $y = 0; $y < $grid_height; $y++) {
			my @line = @lines[$y].split(""):skip-empty;
			loop (my $x = 0; $x < $grid_width; $x++) {
				if @line[$x] eq 'S' {
					@start = ($x, $y);
					next;
				}
				my $pipe = Pipe.new(@line[$x], $x, $y);
				%store{$pipe.key()} = $pipe;
			}
		}
		
		my $startn_coord = keystring(@start[0],@start[1] - 1);
		my $starts_coord = keystring(@start[0],@start[1] + 1);
		my $startw_coord = keystring(@start[0] - 1,@start[1]);
		my $starte_coord = keystring(@start[0] + 1,@start[1]);
		my $startn = False;
		my $starts = False;
		my $starte = False;
		my $startw = False;

		if %store{$startn_coord }:exists && %store{$startn_coord}.s {
			$startn = True;
		}
		if %store{$starts_coord }:exists && %store{$starts_coord}.n {
			$starts = True;
		}
		if %store{$starte_coord}:exists && %store{$starte_coord}.w {
			$starte= True;
		}
		if %store{$startw_coord }:exists && %store{$startw_coord}.e {
			$startw = True;
		}

		my $start_pipe = Pipe.new($startn, $starts, $starte, $startw, @start[0], @start[1]);
		%store{$start_pipe.key()} = $start_pipe;
		return self.bless(store => %store, width=>$grid_width, height=>$grid_height, start_x => @start[0], start_y => @start[1] );
	}
}

# I can't figure out using tuples or arrays as a key for a dictionary in Raku,
# so set dictionaries are indexed by string
sub keystring($x, $y) {
	return "$x,$y";
}

# given a direction, return the coodinates to the left and right of the 
# given position
sub leftright($dir, $x, $y) {
	given $dir {
		# North - west is left, east is right
		when [0,-1] {
			return [[$x-1, $y], [$x+1,$y]];
		}
		# South - east is left, west is right
		when [0,1] {
			return [[$x+1, $y], [$x-1,$y]];
		}
		# West, south is left, north is right
		when [-1,0] {
			return [[$x, $y+1], [$x,$y-1]];
		}
		# East, north is left, south is right
		when [1,0] {
			return [[$x, $y-1], [$x,$y+1]];
		}
	}
	return False;
}

# Given the grid and a set of nodes in the loop, expand the given set with a 
# flood fill to contain all contiguous nodes which are within the grid bounds 
# and are not in the loop set.
sub floodfill($pipegrid, %loop_set, %set) {
	my %filled_set;
	for %set.kv -> $key, $value {
		# add all neighbors which aren't in the loop set or outside the grid
		my @frontier;
		my @next_frontier;
		@next_frontier.push($value);
		while @next_frontier.elems > 0 {
			@frontier = @next_frontier;
			@next_frontier = ();
			loop (my $i = 0; $i < @frontier.elems; $i++) {
				my $node = @frontier[$i];
				my $node_key = keystring($node[0], $node[1]);
				if %filled_set{$node_key}:exists {
					next;
				}
				%filled_set{$node_key} = $node;
				my @neighbors = [[$node[0], $node[1] - 1], [$node[0], $node[1] + 1], [$node[0] + 1, $node[1]], [$node[0] - 1, $node[1]]];
				loop (my $j = 0; $j < @neighbors.elems; $j++) {
					my $neighbor = @neighbors[$j];
					my $neighbor_key = keystring($neighbor[0], $neighbor[1]);
					if !(%loop_set{$neighbor_key}:exists) 
						&& !(%filled_set{$neighbor_key}:exists) 
						&& $neighbor[0] >= 0 
						&& $neighbor[0] < $pipegrid.width 
						&& $neighbor[1] >= 0 
						&& $neighbor[1] < $pipegrid.height {
							@next_frontier.push($neighbor);
					}
				}
			}
		}
	}
	return %filled_set;
}

# Trace the loop in the pipegrid and return:
#	- the number of nodes in the loop // 2 (Which should be the part 1 solution
#	in all cases)
#	- The number of elements in the set of non-loop nodes to the left or right 
#	of the loop that doesn't have any members which touch the edges of the grid
#	(which is hopefully robust enough to be the part 2 solution)
#	- or False on error
sub follow_loop($pipegrid) {
	my @loop_nodes;
	my %loop_set;
	my %left_set;
	my %right_set;
	my $last_dir;
	my $start_node_key = keystring($pipegrid.start_x, $pipegrid.start_y);
	my $curr_node = [$pipegrid.start_x, $pipegrid.start_y];
	my $curr_node_key = keystring($curr_node[0], $curr_node[1]);
	my $at_start = True;
	while $curr_node_key ne $start_node_key || $at_start {
		@loop_nodes.push($curr_node);
		%loop_set{$curr_node_key} = True;
		my $dir;
		# If at the start, pick a direction to start traversing the loop			
		if $at_start {
			my @available_dirs = $pipegrid.store{$curr_node_key}.available_dirs();
			$dir = @available_dirs[0];
			$at_start = False;
			$last_dir = False;
		}
		else {
			my @available_dirs = $pipegrid.store{$curr_node_key}.available_dirs();
			if (@available_dirs[0][0] == -$last_dir[0] && @available_dirs[0][1] == -$last_dir[1]) {
				$dir = @available_dirs[1];
			}
			else {
				$dir = @available_dirs[0];
			}
		}
		# Add neighbors of the current node to the left and right of the 
		# incoming and outgoing direction to the left and right node sets
		if ($last_dir != False) {
			my $last_lr = leftright($last_dir, $curr_node[0], $curr_node[1]);
			if $last_lr == False {
				say "Something went wrong with the previous direction $last_dir at node $curr_node";
				return False;
			}
			%left_set{keystring($last_lr[0][0], $last_lr[0][1])} = [$last_lr[0][0], $last_lr[0][1]];
			%right_set{keystring($last_lr[1][0], $last_lr[1][1])} = [$last_lr[1][0], $last_lr[1][1]];
		}
		my $curr_lr = leftright($dir, $curr_node[0], $curr_node[1]);
		if $curr_lr == False {
				say "Something went wrong with the current direction $dir at node $curr_node";
			return False;
		}
		%left_set{keystring($curr_lr[0][0], $curr_lr[0][1])} = [$curr_lr[0][0], $curr_lr[0][1]];
		%right_set{keystring($curr_lr[1][0], $curr_lr[1][1])} = [$curr_lr[1][0], $curr_lr[1][1]];
		$curr_node = [$curr_node[0] + $dir[0], $curr_node[1] + $dir[1]];
		$curr_node_key = keystring($curr_node[0], $curr_node[1]);
		$last_dir = $dir;
	}

	# Remove nodes that are part of the loop from the left and right sets
	for @loop_nodes -> $node {
		my $key = keystring($node[0], $node[1]);
		if %left_set{$key}:exists {
			%left_set{$key}:delete;
		}
		if %right_set{$key}:exists {
			%right_set{$key}:delete;
		}
	}
	# Remove nodes outside the grid bounds from the left and right sets
	loop (my $y = -1; $y <= $pipegrid.height; $y++) {
		loop (my $x = -1; $x <= $pipegrid.width; $x++) {
			if ($x == -1 || $x == $pipegrid.width || $y == -1 || $y == $pipegrid.height) {
				my $key = keystring($x,$y);
				if %left_set{$key}:exists {
					%left_set{$key}:delete;
				}
				if %right_set{$key}:exists {
					%right_set{$key}:delete;
				}
			}
		}	
	}

	# At this point, the left and right sets are nearly complete, but there may
	# be nodes interior or exterior to the loop which do not directly neighbor
	# a loop node. Floodfill both sets to expand them.
	my %filled_set_left = floodfill($pipegrid, %loop_set, %left_set);
	my %filled_set_right = floodfill($pipegrid, %loop_set, %right_set);

	# if both sets are empty, the interior set must be empty
	if (%filled_set_left.elems == 0 && %filled_set_right.elems == 0) {
		return @loop_nodes.elems div 2, 0; 
	}
	# If one of the sets touches the outer edge of the grid and the other does 
	# not, it must be the exterior set
	my $left_set_has_exterior_members = False;
	my $right_set_has_exterior_members = False;
	for %filled_set_left.kv -> $key, $value {
		if $value[0] == 0 || $value[0] == $pipegrid.width - 1 || $value[1] == 0 || $value[1] == $pipegrid.height - 1 {
			$left_set_has_exterior_members = True;
			last;
		} 
	}
	for %filled_set_right.kv -> $key, $value {
		if $value[0] == 0 || $value[0] == $pipegrid.width - 1 || $value[1] == 0 || $value[1] == $pipegrid.height - 1 {
			$right_set_has_exterior_members = True;
			last;
		} 
	}
	# Hopefully this never happens
	if $left_set_has_exterior_members == $right_set_has_exterior_members {
		say "Unable to determine exterior set. Giving up";
		return False;
	}
	if $left_set_has_exterior_members  {
		return @loop_nodes.elems div 2, %filled_set_right.elems;
	}
	return @loop_nodes.elems div 2, %filled_set_left.elems;
}

sub day10(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;
	
	my $pipegrid = PipeGrid.new(@lines);
	
	my $result = follow_loop($pipegrid);
	if ($result != False) {
		$part1 = $result[0];
		$part2 = $result[1];
	}

	say "Part 1: $part1";
	say "Part 2: $part2";
}
