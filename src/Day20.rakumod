unit module Day20;
use util;

enum ModuleType <FlipFlop Conjuction Broadcast>;

class Pulse {
	has Bool $.state;
	has Str $.source;
	has Str $.dest;

	multi method new($state, $source, $dest) { self.bless(state => $state, source => $source, dest => $dest); }
}

class Module {
	has ModuleType $.type;
	has Str $.name;
	has @.inputs;
	has %.inputnames;
	has Bool $.state is rw;
	has @.outputs;

	multi method new($line) {
		my $type;
		my $name;
		my @split = $line.split(" -> "):skip-empty;
		if substr($line, 0,1) eq '%' {
			$type = FlipFlop;
		}
		elsif(substr($line, 0, 1) eq '&') {
			$type = Conjuction;
		}
		else {
			$type = Broadcast;
		}
		if $type == Broadcast {
			$name = @split[0];
		}
		else {
			$name = @split[0].substr(1);
		}
		my @outputs = @split[1].split(", ");
		self.bless(type => $type, name => $name, inputs => (), inputnames => %(), state => False, outputs => @outputs);
	}

	# run after all modules read
	method init(@modules) {
		for @modules -> $module {
			for $module.outputs -> $output {
				if $output eq self.name {
					self.inputs.push(False);
					self.inputnames{$module.name} = self.inputs.elems - 1;
				}
			}
		}
	}

	method reset() {
		loop (my $i = 0; $i < self.inputs.elems; $i++) {
			self.inputs[$i] = False;
		}
		self.state = False;
	}

	method string() {
		if self.type == Conjuction {
			return "&" ~ self.name;
		}
		elsif self.type == FlipFlop {
			return "%" ~ self.name;
		}
		else {
			return "BUTTON";
		}
	}

	method recieve($pulse) {
		my @outputs;
		if self.type == FlipFlop {
			if $pulse.state == False {
				self.state = !self.state;
				for self.outputs -> $output {
					@outputs.push(Pulse.new(self.state, self.name, $output));
				}				
			}
		}
		elsif self.type == Conjuction {
			if !(self.inputnames{$pulse.source}:exists) {
				say self.name ~": Does not have input " ~ $pulse.source;
			}
			else {
				self.inputs[self.inputnames{$pulse.source}] = $pulse.state;
				my $all_high = True;
				for self.inputs -> $input {
					if $input == False {
						$all_high = False;
						last;
					}
				}
				if $all_high {
					for self.outputs -> $output {
						@outputs.push(Pulse.new(False, self.name, $output));
					}
				}
				else {
					for self.outputs -> $output {
						@outputs.push(Pulse.new(True, self.name, $output));
					}
				}
			}
		}
		elsif self.type == Broadcast {
			for self.outputs -> $output {
				@outputs.push(Pulse.new($pulse.state, self.name, $output));
			}
		}
		return @outputs;
	}
}

sub analyse_rx(@modules, %modulenames) {
	my $rx = "rx";
	# find the parent to rx (assuming only one)
	# and the modules that signal the parent
	my $rx_parent = "";
	my @parent_signalers;
	for @modules -> $module {
		for $module.outputs -> $output {
			if $output eq $rx {
				$rx_parent = $module.name;
				@parent_signalers = $module.inputnames.keys;
				last;
			}
		}
	}
	# find the cycle lengths for each module that signals the parent of rx
	my @periods;
	for @parent_signalers -> $modulename {
		reset_modules(@modules);
		my $press_count = 1;
		while True {
			my $result = press_button(@modules, %modulenames, $modulename);
			if $result[2] == True {
				@periods.push($press_count);
				last;
			}
			$press_count += 1;
		}
	}
	# find the lcm of the cycle lengths
	my $lcm = 1;
	for @periods -> $period {
		$lcm = $lcm lcm $period;
	}
	return $lcm;
}

sub reset_modules(@modules) {
	for @modules -> $module {
		$module.reset();
	}
}

sub press_button(@modules, %modulenames, $monitor_module_name) {
	my $lowPulses = 0;
	my $highPulses = 0;

	my $monitor_module_high_pulse = False;

	my @frontier;
	my @frontier_next;
	@frontier_next.push(Pulse.new(False, "button", "broadcaster"));
	while @frontier_next.elems > 0 {	
		@frontier = @frontier_next;
		@frontier_next = ();
		for @frontier -> $pulse {
			if $pulse.source eq $monitor_module_name && $pulse.state == True {
				$monitor_module_high_pulse = True;
			}
			if $pulse.state {
				$highPulses += 1;
				
			}
			else {
				$lowPulses += 1;
			}
			if %modulenames{$pulse.dest}:exists {
			my @result_pulses = @modules[%modulenames{$pulse.dest}].recieve($pulse);
				for @result_pulses -> $result_pulse {
					@frontier_next.push($result_pulse);
				}
			}
			
		}
	}
	return [$lowPulses, $highPulses, $monitor_module_high_pulse];
}

sub day20(@lines) is export {
	my $part1 = 0;
	my $part2 = 0;

	my @modules;
	my @modules2;
	my %modulenames;
	for @lines -> $line {
		@modules.push(Module.new($line));
		@modules2.push(Module.new($line));
		%modulenames{@modules[@modules.elems - 1].name} = @modules.elems - 1;
	}
	
	for @modules -> $module {
		$module.init(@modules);
	}
	my $lowPulses = 0;
	my $highPulses = 0;
	loop (my $i = 0; $i < 1000; $i++) {
		my $result = press_button(@modules, %modulenames, "");
		$lowPulses += $result[0];
		$highPulses += $result[1];
	}
	$part1 = $lowPulses * $highPulses;
	say "Part 1: $part1";
	
	$part2 = analyse_rx(@modules, %modulenames);
	say "Part 2: $part2";
}
