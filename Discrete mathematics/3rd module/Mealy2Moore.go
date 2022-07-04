package main

import (
	"fmt"
	"strconv"
)

func main() {
	var n, m, q int
	fmt.Scan(&m)
	a := make([]string, m)
	for i := 0; i < m; i++ {
		fmt.Scan(&a[i])
	}
	fmt.Scan(&q)
	b := make([]string, q)
	for i := 0; i < q; i++ {
		fmt.Scan(&b[i])
	}
	fmt.Scan(&n)
	arr := make([][]int, n)
	for i := 0; i < n; i++ {
		arr[i] = make([]int, m)
		for j := 0; j < m; j++ {
			fmt.Scan(&arr[i][j])
		}
	}
	s := make([][]string, n)
	for i := 0; i < n; i++ {
		s[i] = make([]string, m)
		for j := 0; j < m; j++ {
			fmt.Scan(&s[i][j])
		}
	}
	type tuple struct {
		f int
		s string
	}
	var (
		pts []tuple
	)
	nums := make(map[tuple]int)
	for i := 0; i < n; i++ {
		for j := 0; j < m; j++ {
			nm, _ := strconv.Atoi(s[i][j])
			_, f := nums[tuple{arr[i][j], b[nm]}]
			if !f {
				pts = append(pts, tuple{arr[i][j], b[nm]})
				nums[pts[len(nums)]] = len(nums)
			}
		}
	}
	fmt.Println("digraph {\n    rankdir = LR")
	for key, value := range pts {
		fmt.Print("    ", key, " [label = \"(", value.f, ",", value.s, ")\"]\n")
	}
	for key, value := range pts {
		for j := 0; j < m; j++ {
			nm, _ := strconv.Atoi(s[value.f][j])
			fmt.Printf("    %d -> %d [label = \"%s\"]\n", key, nums[tuple{arr[value.f][j], b[nm]}], a[j])
		}
	}
	fmt.Println("}")
}
