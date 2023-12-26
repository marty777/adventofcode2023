package main

import (
	"fmt"
	"flag"
	"time"
	"strings"
	"strconv"
	"os"
	"bufio"
	"errors"
	"math"
	"gonum.org/v1/gonum/mat"
)

type Hailstone struct {
	px int64
	py int64
	pz int64
	dx int64
	dy int64
	dz int64
}

// Based on the explanation here https://www.reddit.com/r/adventofcode/comments/18pnycy/comment/ketigrg/
// of a clever approach by https://www.reddit.com/user/RiemannIntegirl/
// The x,y and x,z solutions for the rock position can be calculated separately
// using only 4 pairs of hailstones to solve a system of linear equations with 
// 4 parameters
func part2(hailstones []Hailstone) (int64, error) {
	matrix_data_xy := make([]float64, 16)
	matrix_data_xz := make([]float64, 16)
	vector_data_xy := make([]float64, 4)
	vector_data_xz := make([]float64, 4)

	var matrix_index = 0
	var vector_index = 0
	for i := 0; i < 8; i+=2 {
		matrix_data_xy[matrix_index] = float64(hailstones[i+1].dy - hailstones[i].dy)
		matrix_data_xz[matrix_index] = float64(hailstones[i+1].dz - hailstones[i].dz)
		matrix_index += 1
		matrix_data_xy[matrix_index] = float64(hailstones[i].dx - hailstones[i+1].dx)
		matrix_data_xz[matrix_index] = float64(hailstones[i].dx - hailstones[i+1].dx)
		matrix_index += 1
		matrix_data_xy[matrix_index] = float64(hailstones[i+1].py - hailstones[i].py)
		matrix_data_xz[matrix_index] = float64(hailstones[i+1].pz - hailstones[i].pz)
		matrix_index += 1
		matrix_data_xy[matrix_index] = float64(hailstones[i+1].px - hailstones[i].px)
		matrix_data_xz[matrix_index] = float64(hailstones[i+1].px - hailstones[i].px)
		matrix_index += 1
		// py_i * dx_i - py_i+1 * dx_i+1 + px_i+1 * dy_i+1 - px_i * dy_i 
		vector_data_xy[vector_index] = 	float64 ((hailstones[i].py * hailstones[i].dx) - (hailstones[i+1].py * hailstones[i+1].dx) + 
										(hailstones[i+1].px * hailstones[i+1].dy) - (hailstones[i].px * hailstones[i].dy))
		vector_data_xz[vector_index] = 	float64((hailstones[i].pz * hailstones[i].dx) - (hailstones[i+1].pz * hailstones[i+1].dx) + 
										(hailstones[i+1].px * hailstones[i+1].dz) - (hailstones[i].px * hailstones[i].dz))
		vector_index += 1
	}
	M_xy := mat.NewDense(4,4, matrix_data_xy);
	M_xz := mat.NewDense(4,4, matrix_data_xz);
	v_xy := mat.NewDense(4,1, vector_data_xy);
	v_xz := mat.NewDense(4,1, vector_data_xz);

	var result_xy mat.Dense;
	var result_xz mat.Dense;
	
	err := result_xy.Solve(M_xy, v_xy);
	if err != nil {
		fmt.Println(err);
		return 0, err;
	}
	err = result_xz.Solve(M_xz, v_xz);
	if err != nil {
		fmt.Println(err);
		return 0, err;
	}

	result := int64(math.Round(result_xy.At(0,0)) + math.Round(result_xy.At(1,0)) + math.Round(result_xz.At(1,0)));

	return result, nil;
}

func parseInput(filepath string) ([]Hailstone, error) {
	hailstones := make([]Hailstone, 0);
	file, err := os.OpenFile(filepath, os.O_RDONLY, 0600)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)
	var line_num = 0;
	for scanner.Scan() {
		line_num += 1;
		line := strings.TrimSpace(scanner.Text())
		split := strings.Split(line, " @ ");
		if len(split) != 2 {
			return nil, errors.New(fmt.Sprintf("Could not parse line %d", line_num));
		}
		split_position := strings.Split(split[0], ", ");
		if len(split_position) != 3 {
			return nil, errors.New(fmt.Sprintf("Could not parse position vector line %d", line_num));
		}
		px, err := strconv.ParseInt(strings.TrimSpace(split_position[0]), 10, 64);
		if err != nil {
			return nil, errors.New(fmt.Sprintf("Could not parse integer %s on line %d", split_position[0], line_num));
		}
		py, err := strconv.ParseInt(strings.TrimSpace(split_position[1]), 10, 64);
		if err != nil {
			return nil, errors.New(fmt.Sprintf("Could not parse integer %s on line %d", split_position[1], line_num));
		}
		pz, err := strconv.ParseInt(strings.TrimSpace(split_position[2]), 10, 64);
		if err != nil {
			return nil, errors.New(fmt.Sprintf("Could not parse integer %s on line %d", split_position[2], line_num));
		}
		split_direction := strings.Split(split[1], ", ");
		if len(split_direction) != 3 {
			return nil, errors.New(fmt.Sprintf("Could not parse direction vector line %d", line_num));
		}
		dx, err := strconv.ParseInt(strings.TrimSpace(split_direction[0]), 10, 64);
		if err != nil {
			return nil, errors.New(fmt.Sprintf("Could not parse integer %s on line %d", split_direction[0], line_num));
		}
		dy, err := strconv.ParseInt(strings.TrimSpace(split_direction[1]), 10, 64);
		if err != nil {
			return nil, errors.New(fmt.Sprintf("Could not parse integer %s on line %d", split_direction[1], line_num));
		}
		dz, err := strconv.ParseInt(strings.TrimSpace(split_direction[2]), 10, 64);
		if err != nil {
			return nil, errors.New(fmt.Sprintf("Could not parse integer %s on line %d", split_direction[2], line_num));
		}
		hailstones = append(hailstones, Hailstone{px,py,pz,dx,dy,dz});
	}
	return hailstones, nil;
}

func getMillis() int64 {
    return time.Now().UnixNano() / int64(time.Millisecond)
}

func main() {
	//inputFilePtr := flag.String("p", "", "Path to input file for Advent of Code 2023 day 24");
	flag.Parse()
	if len(flag.Args()) != 1 {
		fmt.Println("Usage: ./day24 inputfile");
		return;
	}
	inputFilePath := flag.Args()[0];
	startTime := getMillis();
	hailstones, err := parseInput(inputFilePath)
	if err != nil {
		panic(fmt.Sprintf("Unable to parse input file %s : %s", inputFilePath, err));
	}
	if len(hailstones) < 8 {
		panic(fmt.Sprintf("Insufficient number of hailstones %d provided (minimum 8)", len(hailstones)));
	}

	part2, err := part2(hailstones);
	if err != nil {
		panic(err);
	}
	fmt.Printf("Part 2: %d\n", part2);

	endTime := getMillis();
	elapsed := endTime - startTime
	fmt.Printf("Elapsed time : %d ms\n", elapsed)
}