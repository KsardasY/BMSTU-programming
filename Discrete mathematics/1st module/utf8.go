package main

import (
	"fmt"
	"math"
)

func encode(utf32 []rune) []byte {
	var res []byte
	for _, c := range utf32 {
		if int(c) < int(math.Pow(2, 7)) {
			res = append(res, byte(c))
		} else if int(c) < int(math.Pow(2, 11)) {
			res = append(res, byte(128+64+c/64))
			res = append(res, byte(128+c%64))
		} else if int(c) < int(math.Pow(2, 16)) {
			res = append(res, byte(128+64+32+int(c)/int(math.Pow(2, 12))))
			res = append(res, byte(128+int(c)%int(math.Pow(2, 12))/64))
			res = append(res, byte(128+c%64))
		} else {
			res = append(res, byte(128+64+32+16+int(c)/int(math.Pow(2, 18))))
			res = append(res, byte(128+int(c)%int(math.Pow(2, 18))/int(math.Pow(2, 12))))
			res = append(res, byte(128+int(c)%int(math.Pow(2, 12))/64))
			res = append(res, byte(128+c%64))
		}
	}
	return res
}

func decode(utf8 []byte) []rune {
	var (
		res    []rune
		ord, i int
	)
	for _, c := range utf8 {
		if c < 128 {
			res = append(res, rune(c))
		} else if c < 192 {
			i--
			ord += (int(c) - 128) * int(math.Pow(64, float64(i)))
			if i == 0 {
				res = append(res, rune(ord))
			}
		} else if c < 224 {
			ord = 64 * (int(c) - 192)
			i = 1
		} else if c < 240 {
			ord = int(math.Pow(64, 2)) * (int(c) - 224)
			i = 2
		} else {
			ord = int(math.Pow(64, 3)) * (int(c) - 240)
			i = 3
		}
	}
	return res
}

func main() {
	s := "∏ηж$😀工寫_∏¥"
	fmt.Println([]rune(s))
	utf8 := encode([]rune(s))
	utf32 := decode(utf8)
	fmt.Println(utf32)
}
