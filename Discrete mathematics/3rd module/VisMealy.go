package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	var n, m, q int
	stdin := bufio.NewReader(os.Stdin)
	fmt.Fscan(stdin, &n, &m, &q)
	a := make([][]int, n, n)
	for i := 0; i < n; i++ {
		a[i] = make([]int, m, m)
	}
	b := make([][]string, n, n)
	for i := 0; i < n; i++ {
		b[i] = make([]string, m, m)
	}
	for i := 0; i < n; i++ {
		for j := 0; j < m; j++ {
			fmt.Fscan(stdin, &a[i][j])
		}
	}
	for i := 0; i < n; i++ {
		for j := 0; j < m; j++ {
			fmt.Fscan(stdin, &b[i][j])
		}
	}
	fmt.Printf("digraph {\n    rankdir = LR\n")
	for i := 0; i < n; i++ {
		for j := 0; j < m; j++ {
			fmt.Printf("    %d -> %d [label = \"%c(%v)\"]\n", i, a[i][j], 'a'+j, b[i][j])
		}
	}
	fmt.Println("}")
}
