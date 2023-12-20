unit module Day19;
use util;

enum WorkflowConditionType <GT LT FINAL>;
enum PartCategory <X M A S NoCategory>;

sub Category($cat) {
	given $cat {
		when 'x' { return X; }
		when 'm' { return M; }
		when 'a' { return A; }
		when 's' { return S; }
		default { return NoCategory; }
	}
}

class WorkflowCondition {
	has WorkflowConditionType $.type;
	has Int $.amount;
	has PartCategory $.category;
	has str $.nextWorkflow;

	multi method new($Workflowstr) {
		my $dest;
		my $type;
		my $category;
		my $amt;
		if $Workflowstr.index(":") === Nil {
			self.bless(type => FINAL, amount => 0, category => NoCategory, nextWorkflow => $Workflowstr);
		}
		else {
			my @parts = $Workflowstr.split(":"):skip-empty;
			$dest = @parts[1];
			if @parts[0].index(">") !=== Nil {
				$type = GT;
				my @parts2 = @parts[0].split(">"):skip-empty;
				$category = Category(@parts2[0]);
				$amt = Int(@parts2[1]);
				$dest = @parts[1];
			}
			elsif @parts[0].index("<") !=== Nil {
				$type = LT;
				my @parts2 = @parts[0].split("<"):skip-empty;
				$category = Category(@parts2[0]);
				$amt = Int(@parts2[1]);
				$dest = @parts[1];
			}
			else {
				say "Had trouble reading Workflow $Workflowstr";
			}
			self.bless(type=>$type, amount => $amt, category => $category, nextWorkflow => $dest );
		}
	}

	method decide($part) {
		if self.type == GT {
			if $part.val(self.category) > self.amount {
				return self.nextWorkflow;
			}
			return False;				
		}
		elsif self.type == LT {
			if $part.val(self.category) < self.amount {
				return self.nextWorkflow;
			}
			return False;
		}
		else {
			return self.nextWorkflow;
		}
	}

}

class Workflow {
	has 	str $.name;
	has 	@.conditions;
	
	multi method new($line) {
		my @parts = $line.split("\{"):skip-empty;
		my $name = @parts[0];
		my $conditionblock = @parts[1].substr(0..@parts[1].chars-2);
		my @condition_strs = $conditionblock.split(","):skip-empty;
		my @conditions;
		for @condition_strs -> $condition_str {
			@conditions.push(WorkflowCondition.new($condition_str));
		}
		self.bless(name => $name, conditions => @conditions);
	}

	method decide($part) {
		for self.conditions -> $condition {
			my $result = $condition.decide($part);
			if $result !=== False {
				return $result;
			}
		}
	}
}

class Part {
	has Int $.x;
	has Int $.m;
	has Int $.a;
	has Int $.s;

	method new($partstr) {
		my $x = Int($partstr.split("x=")[1].split(",")[0]);
		my $m = Int($partstr.split("m=")[1].split(",")[0]);
		my $a = Int($partstr.split("a=")[1].split(",")[0]);
		my $s = Int($partstr.split("s=")[1].split("}")[0]);
		self.bless(x => $x, m => $m, a => $a, s => $s)
	}

	method rating() { return self.x + self.m + self.a + self.s; }
	method val($cat) {
		given $cat {
			when X {return self.x;}
			when M {return self.m;}
			when A {return self.a;}
			when S {return self.s;}
		}
		return 0;
	}
}

# I suspect this would work with just min,max values, but I found this 
# conceptually easier to deal with and it works. Good enough.
class Range {
	has %.vals;
	multi method new() {
		my %vals;
		loop (my $i = 1; $i <= 4000; $i++) {
			%vals{$i} = True;
		} 
		self.bless(vals => %vals);
	}
	multi method new(Range $range) {
		my %vals;
		loop (my $i = 1; $i <= 4000; $i++) {
			if $range.vals{$i}:exists {
				%vals{$i} = True;
			}
		} 
		self.bless(vals => %vals);
	}
	method set(WorkflowConditionType $type, Bool $inverse, Int $amt) {
		given $type {
			when GT {
				# set not GT (i.e LTE)
				if $inverse {
					loop (my $i = $amt + 1; $i <= 4000; $i++ ) {
						if self.vals{$i}:exists {  self.vals{$i}:delete; }
					}
				}
				else {
					loop (my $i = $amt; $i >= 1; $i-- ) {
						if self.vals{$i}:exists {  self.vals{$i}:delete; }
					}
				}
			}
			when LT {
				# set not LT (i.e. GTE)
				if $inverse {
					loop (my $i = $amt - 1; $i >= 1; $i-- ) {
						if self.vals{$i}:exists {  self.vals{$i}:delete; }
					}
				}
				else {
					loop (my $i = $amt; $i <= 4000; $i++ )  {
						if self.vals{$i}:exists {  self.vals{$i}:delete; }
					}
				}
			}
			default { return; }
		}
	}
}

class RangeGroup {
	has Range $.x;
	has Range $.m;
	has Range $.a;
	has Range $.s;

	multi method new() {
		self.bless(x => Range.new(), m => Range.new(), a => Range.new(), s => Range.new());
	}
	multi method new(RangeGroup $rangegroup) {
		self.bless(x => Range.new($rangegroup.x), m => Range.new($rangegroup.m), a => Range.new($rangegroup.a), s => Range.new($rangegroup.s));
	}
	method set(WorkflowCondition $condition, Bool $inverse) {
		given $condition.category {
			when X { self.x.set($condition.type, $inverse, $condition.amount); }
			when M { self.m.set($condition.type, $inverse, $condition.amount); }
			when A { self.a.set($condition.type, $inverse, $condition.amount); }
			when S { self.s.set($condition.type, $inverse, $condition.amount); }
		}
	}

	method combinations() {
		return self.x.vals.elems * self.m.vals.elems * self.a.vals.elems * self.s.vals.elems;
	}

	method print() {
		say "x: " ~ self.x.vals.elems ~ "\tm:" ~ self.m.vals.elems ~ "\tm:" ~ self.a.vals.elems ~ "\ts:" ~ self.s.vals.elems ~ "\ttotal:" ~ self.combinations();
	}
}

sub bfs(@Workflows, %Workflownames) {
	my @accepted_ranges;
	my @frontier;
	my @frontier_next;
	@frontier_next.push(["in",RangeGroup.new()]);
	while @frontier_next.elems > 0 {
		@frontier = @frontier_next;
		@frontier_next = ();
		for @frontier -> $item {
			my $curr_Workflowname = $item[0];
			my $curr_rangegroup = RangeGroup.new($item[1]); 
			for @Workflows[%Workflownames{$curr_Workflowname}].conditions -> $condition {
				my $next_Workflowname = $condition.nextWorkflow;
				if $condition.type == FINAL {
					if $condition.nextWorkflow eq "A" && $curr_rangegroup.combinations() > 0 {
						@accepted_ranges.push($curr_rangegroup);
					}
					elsif $condition.nextWorkflow ne "R" && $curr_rangegroup.combinations() > 0 {
						@frontier_next.push([$condition.nextWorkflow, $curr_rangegroup]);
					}
				}
				else {
					my $next_rangegroup = RangeGroup.new($curr_rangegroup); # next_rangegroup is copied from $curr_rangegroup
					$next_rangegroup.set($condition, False); # $next_rangegroup is set to meet the condition
					$curr_rangegroup.set($condition, True); # curr_rangegroup is set to not meet the condition
					if $next_rangegroup.combinations() > 0 {
						if $condition.nextWorkflow eq "A" {
							@accepted_ranges.push($next_rangegroup);
						}
						elsif $condition.nextWorkflow ne "R" {
							@frontier_next.push([$condition.nextWorkflow, $next_rangegroup]);
						} 
					}
				}
			}
		}
	}

	my $sum = 0;
	for @accepted_ranges -> $rangegroup {
		$sum += $rangegroup.combinations();
	}
	return $sum;
}

sub day19(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my @Workflows;
	my %Workflownames;
	my @parts;
	my $on_parts = False;
	loop (my $i = 0; $i < @lines.elems; $i++) {
		if @lines[$i] eq "" {
			$i += 1;
			$on_parts = True;
		}
		if !$on_parts {
			my $Workflow = Workflow.new(@lines[$i]);
			@Workflows.push($Workflow);
			%Workflownames{$Workflow.name} = @Workflows.elems - 1;
		}
		else {
			my $part = Part(@lines[$i]);
			my $dest = @Workflows[%Workflownames{"in"}].decide($part);
			while $dest ne "A" && $dest ne "R" {
				$dest = @Workflows[%Workflownames{$dest}].decide($part);
			}
			if $dest eq "A" {
				$part1 += $part.rating();
			}
		}	
	}
	say "Part 1: $part1";

	$part2 = bfs(@Workflows, %Workflownames);
	say "Part 2: $part2";
}
