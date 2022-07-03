package main

import (
	"bufio"
	"fmt"
	"os"
)

var x int

func dfs(begin int, arr []int, a [][]int, p []int, m int) {
	arr[begin] = x
	p[x] = begin
	x++
	for i := 0; i < m; i++ {
		if arr[a[begin][i]] == -1 {
			dfs(a[begin][i], arr, a, p, m)
		}
	}
}

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
	p := make([]int, n)
	arr := make([]int, n)
	for i := 0; i < n; i++ {
		arr[i] = -1
	}
	x = 0
	dfs(q, arr, a, p, m)
	fmt.Printf("%d %d %d\n", n, m, 0)
	for i := 0; i < n; i++ {
		for j := 0; j < m; j++ {
			fmt.Printf("%d ", arr[a[p[i]][j]])
		}
		fmt.Println()
	}

	for i := 0; i < n; i++ {
		for j := 0; j < m; j++ {
			fmt.Printf("%s", b[p[i]][j]+" ")
		}
		fmt.Println()
	}
}
