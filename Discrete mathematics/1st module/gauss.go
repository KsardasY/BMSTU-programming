package main

import (
	"fmt"
	"math"
)

type Fraction struct {
	num, den int
}

func (f *Fraction) conversion() {
	if f.num == 0 {
		f.den = 1
	} else {
		x := int(math.Abs(float64(f.num)))
		y := int(math.Abs(float64(f.den)))
		g := gcd(x, y)
		f.num /= g
		f.den /= g
		if f.den < 0 {
			f.num = -f.num
			f.den = -f.den
		}
	}
}

func gcd(a, b int) int {
	if a < 0 {
		a = -a
	}
	for a != 0 {
		a, b = b%a, a
	}
	return b
}

func addition(a Fraction, b Fraction) Fraction {
	b.num = b.num*a.den + a.num*b.den
	b.den = b.den * a.den
	b.conversion()
	return b
}

func multiply(a Fraction, b Fraction) Fraction {
	a.num *= b.num
	a.den *= b.den
	a.conversion()
	return a
}

func reverse(a Fraction) Fraction {
	res := Fraction{a.den, a.num}
	res.conversion()
	return res
}

func negative(a Fraction) Fraction {
	res := Fraction{-a.num, a.den}
	res.conversion()
	return res
}

func down_kill(a, b []Fraction, j int) []Fraction {
	res := make([]Fraction, len(a))
	for i := 0; i <= j; i++ {
		res[i] = Fraction{0, 1}
	}
	c := negative(multiply(reverse(a[j]), b[j]))
	for i := j + 1; i < len(a); i++ {
		res[i] = addition(b[i], multiply(c, a[i]))
	}
	return res
}

func solution(matrix [][]Fraction) []Fraction {
	res := make([]Fraction, len(matrix))
	for i := 0; i < len(res); i++ {
		res[i] = Fraction{0, 1}
	}
	for i := 0; i < len(matrix)-1; i++ {
		j := i
		for j < len(matrix) && matrix[j][i].num == 0 {
			j++
		}
		if j == len(matrix) {
			res[0] = Fraction{0, 0}
			return res
		} else {
			matrix[j], matrix[i] = matrix[i], matrix[j]
			for j = i + 1; j < len(matrix); j++ {
				if matrix[j][i].num != 0 {
					matrix[j] = down_kill(matrix[i], matrix[j], i)
				}
			}
		}
	}
	for i := len(matrix) - 1; i > 0; i-- {
		if matrix[i][i].num == 0 {
			res[0] = Fraction{0, 0}
			return res
		}
		for j := i - 1; j >= 0; j-- {
			if matrix[j][i].num != 0 {
				c := negative(multiply(reverse(matrix[i][i]), matrix[j][i]))
				matrix[j][len(matrix)] = addition(matrix[j][len(matrix)], multiply(c, matrix[i][len(matrix)]))
				matrix[j][i] = Fraction{0, 1}
			}
		}
	}
	for i := 0; i < len(matrix); i++ {
		res[i] = multiply(matrix[i][len(matrix)], reverse(matrix[i][i]))
	}
	return res
}

func main() {
	var n, x int
	fmt.Scanf("%d ", &n)
	matrix := make([][]Fraction, n)
	for i := 0; i < n; i++ {
		matrix[i] = make([]Fraction, n+1)
	}
	for i := 0; i < n; i++ {
		for j := 0; j < n+1; j++ {
			fmt.Scan(&x)
			matrix[i][j] = Fraction{x, 1}
		}
	}
	res := solution(matrix)
	if res[0].den == 0 {
		fmt.Println("No solution")
	} else {
		for i := 0; i < n; i++ {
			fmt.Printf("%d/%d\n", res[i].num, res[i].den)
		}
		fmt.Println()
	}
}
