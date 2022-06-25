package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	in := bufio.NewScanner(os.Stdin)
	in.Scan()
	fmt.Println(polish(in.Text()))
}

func polish(expression string) int {
	var p, x, res int
	expression = strings.TrimSpace(expression)
	if expression[0] == '(' {
		expression = strings.TrimSpace(expression[1:])
	}
	i := 0
	if expression[0] == '+' {
		res = 0
		i++
		for i < len(expression) && expression[i] == ' ' {
			i++
		}
		if expression[i] == '(' {
			i++
			p = i
			i = end_of_brackets(expression, i)
			res += polish(expression[p:i]) + polish("+"+expression[i:])
			i++
		} else if '0' <= expression[i] && expression[i] <= '9' {
			x, _ = strconv.Atoi(string(expression[i]))
			i++
			res += x + polish("+"+expression[i:])
		} else {
			return 0
		}
	} else if expression[i] == '-' {
		res = 0
		i++
		for i < len(expression) && expression[i] == ' ' {
			i++
		}
		if expression[i] == '(' {
			i++
			p = i
			i = end_of_brackets(expression, i)
			res = polish(expression[p:i]) - polish("+"+expression[i:])
			i++
		} else if '0' <= expression[i] && expression[i] <= '9' {
			x, _ = strconv.Atoi(string(expression[i]))
			i++
			res = x - polish("+"+expression[i:])
		} else {
			return 0
		}
	} else if expression[i] == '*' {
		res = 1
		i++
		for i < len(expression) && expression[i] == ' ' {
			i++
		}
		if expression[i] == '(' {
			i++
			p = i
			i = end_of_brackets(expression, i)
			res *= polish(expression[p:i]) * polish("*"+expression[i:])
			i++
		} else if '0' <= expression[i] && expression[i] <= '9' {
			x, _ = strconv.Atoi(string(expression[i]))
			i++
			res *= x * polish("*"+expression[i:])
		} else {
			return 1
		}
	} else if '0' <= expression[i] && expression[i] <= '9' {
		x, _ = strconv.Atoi(string(expression[i]))
		return x
	} else {
		return res
	}
	return res
}

func end_of_brackets(expression string, i int) int {
	k := 1
	for i < len(expression) && k != 0 {
		if expression[i] == '(' {
			k++
		} else if expression[i] == ')' {
			k--
		}
		i++
	}
	return i
}
