package main

import "fmt"

var arr = []int{
	718, 735, 744, 770, 729, 715, 723, 758, 762, 758,
	750,
}

func compare(i int, j int) bool { return arr[i] < arr[j] }

func change(i int, j int) { arr[i], arr[j] = arr[j], arr[i] }

func partition(left int, right int, less func(i, j int) bool, swap func(i, j int)) int {
	i := left
	for j := left; j < right; j++ {
		if less(j, right) {
			swap(i, j)
			i++
		}
	}
	swap(i, right)
	return i
}

func quicksortrec(left int, right int, less func(i, j int) bool, swap func(i, j int)) {
	if left < right {
		q := partition(left, right, less, swap)
		quicksortrec(left, q-1, less, swap)
		quicksortrec(q+1, right, less, swap)
	}
}

func qsort(n int, less func(i, j int) bool, swap func(i, j int)) { quicksortrec(0, n-1, less, swap) }

func main() {
	qsort(len(arr), compare, change)
	for i := 0; i < len(arr); i++ {
		fmt.Print(arr[i], " ")
	}
}
