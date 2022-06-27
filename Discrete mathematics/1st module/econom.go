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
	fmt.Println(reverse_polish(in.Text()))
}

func reverse_polish(exprassion string) int {
	res := 0
	i := strings.Index(exprassion, ")")
	for i >= 0 {
		i -= 4
		exprassion = strings.Replace(exprassion, exprassion[i:i+5], strconv.Itoa(res), -1)
		i = strings.Index(exprassion, ")")
		res++
	}
	return res
}
