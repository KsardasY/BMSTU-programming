package main

func add(a, b []int32, p int) []int32 {
	x := int32(p)
	c := int32(0)
	var (
		res []int32
		s   int32
	)
	if len(a) < len(b) {
		a, b = b, a
	}
	for i := 0; i < len(b); i++ {
		s = a[i] + b[i] + c
		res = append(res, s%x)
		c = s / x
	}
	for i := len(b); i < len(a); i++ {
		res = append(res, (a[i]+c)%x)
		c = (a[i] + c) / x
	}
	if c != 0 {
		res = append(res, c)
	}
	return res
}

func main() {
	a := []int32{1, 1, 1, 1}
	b := []int32{0, 0, 1, 0, 1, 1, 1}
	for _, v := range add(a, b, 2) {
		print(v, " ")
	}
}
