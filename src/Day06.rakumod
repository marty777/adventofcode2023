unit module Day06;
use util;

# Brute forcing the naive version of this solved part 2 before I had a chance
# to think about it, but the problem has a closed form.
# f(x) = -x^2 + x * $time - $distance
# The number of wins are the number of discrete x in [0,$time) where f(x) > 0
# f(x) is a quadratic function with x intercepts. The number of integer x 
# values where f(x) > 0 between these intercepts is the number of wins
# The solutions for 0 = f(x) = ax^2 + bx + c are:
# 	x = (-b +/- sqrt(b^2 - 4ac))/2a
# where:
# 	a = -1
# 	b = time
# 	c = -distance
# and b^2 - 4ac  = time^2 - 4*distance is the discriminant.
# Thus, with some algebraic simplification, the x intercepts of f(x) are: 
# 	low,high = (time -/+ sqrt(discriminant))/2
sub calculate($time, $distance) {
	my $sqrt_discriminant = sqrt($time * $time - 4 * $distance);
	# if the x intercepts are rational, f(high) = 0 and f(low) = 0 and are not 
	# wins, but each integer x between them has f(x) > 0. The number of 
	# discrete steps where f(x) > 0 is high - low - 1.
	# (time + sqrt(discriminant))/2 - (time - sqrt(discriminant))/2  - 1 
	#	= sqrt(discriminant) - 1
	if $sqrt_discriminant % 1.0 == 0.0 {
		return $sqrt_discriminant - 1;
	}
	# if the x intercepts are not rational, f(floor(high)) > 0 and 
	# f(ceil(low)) > 0. The number of discrete steps between and including 
	# them is floor(high) - ceil(low) + 1
	else {
		my $x_high = ($time + $sqrt_discriminant)/2;
		my $x_low = ($time - $sqrt_discriminant)/2;
		return ($x_high.floor - $x_low.ceiling) + 1;
	}
}

sub day06(@lines) is export {
	my $part1 = 1;
	my $part2 = 0;

	my @split1 = @lines[0].split(":");
	my @split2 = @lines[1].split(":");
	my @times = @split1[1].words.map: {.Int()};
	my @distances = @split2[1].words.map: {.Int()};

	my $part2_time = "";
	my $part2_distance = "";
	loop (my $i = 0; $i < @times.elems; $i++) {
		$part1 *= calculate(@times[$i], @distances[$i]);;
		$part2_time ~= Str(@times[$i]);
		$part2_distance ~= Str(@distances[$i]);
	}
	$part2 = calculate(Int($part2_time), Int($part2_distance));

	say "Part 1: $part1";
	say "Part 2: $part2";
}
