unit module util;

sub print_logo() is export {
    my $color_support = color_support();
    my $terminal_width = terminal_width();
    my $ansiReset = "\e[0m";
    my $logo = "";
    my $logo_size = 0;
    my $split_indexes;
    my $color_codes = ("\e[32m", "\e[31m", "\e[32m", "\e[31m");
    if $terminal_width < 21 {
        $logo = "AOC2023\n";
        $split_indexes = ((0, 1, 2, 3, 7), ());
    }
    elsif $terminal_width < 80 {
        $logo = "ADVENTOFCODE2023\n";
        $split_indexes = ((0, 6, 8, 12, 16), ());
    }
    else {
        $logo = q:to/END/;
    ___     __              __       ________        __    ___  ___  ___  ____
   / _ |___/ /  _____ ___  / /____  / _/ ___/__  ___/ /__ |_  |/ _ \|_  ||_  /
  / __ / _  / |/ / -_) _ \/ __/ _ \/ _/ /__/ _ \/ _  / -_) __// // / __/_/_ < 
 /_/ |_\_,_/|___/\__/_//_/\__/\___/_/ \___/\___/\_,_/\__/____/\___/____/____/ 
END
        $split_indexes = ((0, 30, 40, 59, 79), (0, 31, 40, 58, 79), (0, 31, 39, 58, 79), (0, 30, 38, 57, 79));
    }
    my @logo_lines = $logo.lines;
    if $color_support {
        loop (my $i = 0; $i < @logo_lines.elems; $i++) {
            loop (my $j = 0; $j < $split_indexes[$i].elems - 1; $j++) {
                print($color_codes[$j] ~ substr(@logo_lines[$i], $split_indexes[$i][$j], $split_indexes[$i][$j+1] - $split_indexes[$i][$j]));
            }
            print($ansiReset ~ "\n");                
        }
        print("\n");
    }
    else {
        for @logo_lines -> $line {
            print($line ~ "\n");
        }
        print("\n");
    }
}

sub repeat_string($str, $num) {
    my $result = "";
    loop (my $i = 0; $i < $num; $i++) {
        $result ~= $str;
    }
    return $result;
}

# minimal attempt to determine if terminal supports ansi colors
sub color_support {
    if %*ENV{"TERM"}.contains("color") {
        return True
    }
    return False;
}

# attempt to determine terminal width for logo display. Fallback to a width of 80
sub terminal_width {
    my $proc = run 'tput', 'cols', :out;
    return Int($proc.out.slurp(:close));
    CATCH {
        return 80;
    }
}

sub readlines($path) is export {
	my @lines =  $path.IO.lines;
	CATCH {
		say "The file at path $path could not be read";
		return False;
	}
	return @lines;
}

class Coord2D is export {
	has Int $.x;
	has Int $.y;
	
	method key(--> Str) {
		return "$!x,$!y";
	}
}

class Grid2D is export {
	has %.store;
	has Int $.width;
	has Int $.height;
	
	multi method new($width, $height) {
		my %store = %();
		return self.bless(store => %store, width=>$width, height=>$height);
	}
	
	multi method new(@lines) {
		my $grid_width = @lines[0].chars;
		my $grid_height = @lines.elems;
		my %store = %();
		loop (my $y = 0; $y < $grid_height; $y++) {
			my $line = @lines[$y].split("");
			loop (my $x = 0; $x < $grid_width; $x++) {
				if @lines[$y].substr($x..$x).contains('#') {
					%store{"$x,$y"} = True;
				}
			}
		}
		return self.bless(store => %store, width=>$grid_width, height=>$grid_height);
	}
	
	method print() {
		loop (my $y = 0; $y < $.height; $y++) {
			loop (my $x = 0; $x < $.width; $x++) {
				if %!store{"$x,$y"}:exists {
					print '#';
				} 
				else {
					print '.';
				}
			}
			say ''; # probably a more elegant way to do this, but it works.
		}
	}
	
	method occupied($x, $y) {
		return %!store{"$x,$y"}:exists;
	}
}
