unit module Day23;
use util;

class Coord {
	has Int $.x is rw;
	has Int $.y is rw;

	multi method new($x,$y) { self.bless(x => $x, y => $y); }
	multi method new($coord) { self.bless(x => $coord.x, y => $coord.y ); }
	method copy() { return Coord.new(self.x, self.y); }
	multi method add($x,$y) { self.x += $x; self.y += $y; }
	multi method add($coord) { self.x += $coord.x; self.y += $coord.y; }
	method key() {
		return self.x ~ ',' ~ self.y;
	}
	method equal($coord) {
		return self.x == $coord.x && self.y == $coord.y;
	}
}

enum GridNodeType <STARTNODE ENDNODE SLOPE BRANCH>;

class GridNode {
	has GridNodeType $.type;
	has Coord $.pos;
	method new($type, $coord) { self.bless(type => $type, pos => $coord) ;}
}

class GridNodeConnection {
	has Int $.index;
	has Int $.dist;
	has @.path;
	multi method new($index, $dist) { 
		my @path;
		self.bless(index => $index, dist => $dist, path => @path); 
	}
	multi method new($index, $dist, @path) { 
		self.bless(index => $index, dist => $dist, path => @path); 
	}
}

class Grid {
	has %.store;
	has Int $.width;
	has Int $.height;
	has @.nodes;
	has %.nodepositions;
	has @.nodeconnections1;
	has @.nodeconnections2;
	
	multi method new(@lines) {
		my $height = @lines.elems;
		my $width = @lines[0].chars;

		my %store;
		my @nodes;
		my %nodepositions;
		my @nodeconnections1;
		my @nodeconnections2;

		@nodes.push(GridNode.new(STARTNODE, Coord.new(1,0)));
		@nodes.push(GridNode.new(ENDNODE, Coord.new($width-2,$height-1)));

		%nodepositions{@nodes[0].pos.key()} = 0;
		%nodepositions{@nodes[1].pos.key()} = 1;

		loop (my $y = 0; $y < $height; $y++) {
			my @line = @lines[$y].split(""):skip-empty;
			loop (my $x = 0; $x < $width; $x++) {
				if @line[$x] ne '#' {
					%store{"$x,$y"} = @line[$x];
				}
			}
		}

		# find all branching points and add them as nodes
		loop ($y = 1; $y < $height - 1; $y++) {
			loop (my $x = 1; $x < $width - 1; $x++) {
				if !(%store{"$x,$y"}:exists) {
					next;
				}
				my $neighbors = 0;
				if %store{($x+1) ~ "," ~ $y}:exists {
					$neighbors += 1;
				}
				if %store{($x-1) ~ "," ~ $y}:exists {
					$neighbors += 1;
				}
				if %store{$x ~ "," ~ ($y + 1)}:exists {
					$neighbors += 1;
				}
				if %store{$x ~ "," ~ ($y - 1)}:exists {
					$neighbors += 1;
				}
				if $neighbors > 2 {
					@nodes.push(GridNode.new(BRANCH, Coord.new($x,$y)));
					%nodepositions{@nodes[@nodes.elems - 1].pos.key()} = @nodes.elems - 1;
				}
			}
		}

		return self.bless(
			store => %store, 
			width => $width, 
			height => $height, 
			nodes => @nodes, 
			nodepositions => %nodepositions, 
			nodeconnections1 => @nodeconnections1,
			nodeconnections2 => @nodeconnections2);
	}

	# determine connections between nodes for part 1
	method init_connections1() {
		my %node_keys;
		my $end_coord = Coord.new(self.width-2, self.height - 1);
		loop (my $node_index = 0; $node_index < self.nodes.elems; $node_index++) {
			my $node = self.nodes[$node_index];
			my @connections;
			if $node.type == ENDNODE {
				self.nodeconnections1.push(@connections);
				next;
			}
			my $pos = $node.pos;
			
			my $start = $pos.copy();
			# BFS to find adjacent nodes and distances
			my @frontier;
			my @frontier_next;
			my %seen;
			my %seen_nodes;
			@frontier_next.push([$start, 0]);
			while @frontier_next.elems > 0 {
				@frontier = @frontier_next;
				@frontier_next = ();
				for @frontier -> $item {
					my $coord = $item[0];
					my $dist = $item[1];
					if %seen{$coord.key()}:exists && %seen{$coord.key()} <= $dist {
						next;
					}
					if $coord.equal($pos) && $dist > 0 {
						next;
					}
					%seen{$coord.key()} = $dist;
					if self.nodepositions{$coord.key()}:exists && !$coord.equal($start) {
						if !(%seen_nodes{$coord.key()}:exists) || %seen_nodes{$coord.key()} > $dist {
							%seen_nodes{$coord.key()} = $dist;
						}
						next;
					} 
					my $n = Coord.new($coord.x + 0, $coord.y - 1);
					my $s = Coord.new($coord.x + 0, $coord.y + 1);
					my $w = Coord.new($coord.x - 1, $coord.y + 0);
					my $e = Coord.new($coord.x + 1, $coord.y + 0);
					# don't go up-slope
					if (self.store{$n.key()}:exists) && self.store{$n.key()} ne 'v' {
						@frontier_next.push([$n, $dist + 1]);
					}
					if (self.store{$s.key()}:exists) && self.store{$s.key()} ne '^' {
						@frontier_next.push([$s, $dist + 1])
					}
					if (self.store{$w.key()}:exists) && self.store{$w.key()} ne '>' {
						@frontier_next.push([$w, $dist + 1])
					}
					if (self.store{$e.key()}:exists) && self.store{$e.key()} ne '<' {
						@frontier_next.push([$e, $dist + 1])
					}
				}
			}
			for %seen_nodes.keys -> $key {
				@connections.push(GridNodeConnection.new(self.nodepositions{$key}, %seen_nodes{$key}));
			}
			self.nodeconnections1.push(@connections);
		}
	}

	# determine connections between nodes for part 2
	method init_connections2() {
		my %node_keys;
		my $end_coord = Coord.new(self.width-2, self.height - 1);
		loop (my $node_index = 0; $node_index < self.nodes.elems; $node_index++) {
			my $node = self.nodes[$node_index];
			my @connections;
			if $node.type == ENDNODE {
				self.nodeconnections2.push(@connections);
				next;
			}
			my $pos = $node.pos;
			
			my $start = $pos.copy();
			# BFS to find adjacent nodes and distances
			my @frontier;
			my @frontier_next;
			my %seen;
			my %seen_nodes;
			@frontier_next.push([$start, 0]);
			while @frontier_next.elems > 0 {
				@frontier = @frontier_next;
				@frontier_next = ();
				for @frontier -> $item {
					my $coord = $item[0];
					my $dist = $item[1];
					if %seen{$coord.key()}:exists && %seen{$coord.key()} <= $dist {
						next;
					}
					if $coord.equal($pos) && $dist > 0 {
						next;
					}
					%seen{$coord.key()} = $dist;
					if self.nodepositions{$coord.key()}:exists && !$coord.equal($start) {
						if !(%seen_nodes{$coord.key()}:exists) || %seen_nodes{$coord.key()} > $dist {
							%seen_nodes{$coord.key()} = $dist;
						}
						next;
					} 
					my $n = Coord.new($coord.x + 0, $coord.y - 1);
					my $s = Coord.new($coord.x + 0, $coord.y + 1);
					my $w = Coord.new($coord.x - 1, $coord.y + 0);
					my $e = Coord.new($coord.x + 1, $coord.y + 0);
					if (self.store{$n.key()}:exists) {
						@frontier_next.push([$n, $dist + 1]);
					}
					if (self.store{$s.key()}:exists) {
						@frontier_next.push([$s, $dist + 1])
					}
					if (self.store{$w.key()}:exists) {
						@frontier_next.push([$w, $dist + 1])
					}
					if (self.store{$e.key()}:exists) {
						@frontier_next.push([$e, $dist + 1])
					}
				}
			}
			for %seen_nodes.keys -> $key {
				@connections.push(GridNodeConnection.new(self.nodepositions{$key}, %seen_nodes{$key}));
			}
			self.nodeconnections2.push(@connections);
		}
	}
}

sub part1($grid) {
	my $worst = -1;
	my %seen;
	my @frontier;
	my @frontier_next;
	@frontier_next.push([0,0]);
	while @frontier_next.elems > 0 {
		@frontier = @frontier_next;
		@frontier_next = ();
		for @frontier -> $item {
			my $node_index = $item[0];
			my $dist = $item[1];
			if (%seen{$node_index}:exists) && %seen{$node_index} > $dist {
				next;
			}
			%seen{$node_index} = $dist;
			if $grid.nodes[$node_index].type == ENDNODE {
				if $worst == -1 || $dist > $worst {
					$worst = $dist;
				}
				next;
			}
			loop (my $connection_index = 0; $connection_index < $grid.nodeconnections1[$node_index].elems; $connection_index++) {
				@frontier_next.push([$grid.nodeconnections1[$node_index][$connection_index].index, $dist + $grid.nodeconnections1[$node_index][$connection_index].dist]);	
			}
		}
	}
	return $worst;
}

# it'll finish eventually
sub part2_dfs($grid, @path, $dist) {
	my %visited;
	for @path -> $node {
		%visited{$node} = True;
	}
	
	my $node = @path[@path.elems - 1];
	if $node == 1 {
		return $dist;
	}
	# if adjacent to the end, don't take any other branches
	loop (my $i = 0; $i < $grid.nodeconnections2[$node].elems; $i++) {
		if $grid.nodeconnections2[$node][$i].index == 1 {
			my @next_path = @path.clone();
			@next_path.push(1);
			my $next_dist = $dist + $grid.nodeconnections2[$node][$i].dist;
			return part2_dfs($grid, @next_path, $next_dist);
		}
	}
	my $worst = -1;
	loop ($i = 0; $i < $grid.nodeconnections2[$node]; $i++) {
		my $connection = $grid.nodeconnections2[$node][$i];
		if %visited{$connection.index}:exists {
			next;
		}
		my @next_path = @path.clone();
		@next_path.push($connection.index);
		my $next_dist = $dist + $connection.dist;
		my $result = part2_dfs($grid, @next_path, $next_dist);
		if ($worst == -1 || $result > $worst) {
			$worst = $result;
		} 
	}
	return $worst;
}

sub day23(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my $grid = Grid.new(@lines);
	$grid.init_connections1();
	$grid.init_connections2();

	$part1 = part1($grid);
	say "Part 1: $part1";
	$part2 = part2_dfs($grid, [0], 0);
	say "Part 2: $part2";
}