package main

import (
	"fmt"
	"math/rand"
	"strings"
)

type Node struct {
	key     string
	value   int
	balance int
	parent  *Node
	left    *Node
	right   *Node
}

func (nd *Node) MapEmpty() bool {
	if nd == nil {
		return true
	} else {
		return false
	}
}

func (nd *Node) Minimum() *Node {
	if nd == nil {
		return nd
	} else {
		x := nd
		for x.left != nil {
			x = x.left
		}
		return x
	}
}

func (nd *Node) Succ() *Node {
	if nd.right != nil {
		return nd.right.Minimum()
	} else {
		x := nd.parent
		for x != nil && nd == x.right {
			nd = x
			x = x.parent
		}
		return x
	}
}

func (nd *Node) search(key string) (int, bool) {
	x := nd
	for x != nil && x.key != key {
		if key < x.key {
			x = x.left
		} else {
			x = x.right
		}
	}
	if x == nil {
		return 0, false
	} else {
		return x.value, true
	}
}

func (nd *Node) Insert(key string, value int) *Node {
	y := Node{key, value, 0, nil, nil, nil}
	if nd == nil {
		*nd = y
	} else {
		x := nd
		for {
			if key < x.key {
				if x.left == nil {
					x.left = &y
					y.parent = x
					break
				}
				x = x.left
			} else {
				if x.right == nil {
					x.right = &y
					y.parent = x
					break
				}
				x = x.right
			}
		}
	}
	return nd
}

func (nd *Node) ReplaceNode(x, y *Node) {
	if x == nd {
		*nd = *y
		if y != nil {
			y.parent = nil
		}
	} else {
		p := x.parent
		if y != nil {
			y.parent = p
		}
		if p.left == x {
			p.left = y
		} else {
			p.right = y
		}
	}
}

func (nd *Node) RotateLeft(x *Node) {
	y := x.right
	nd.ReplaceNode(x, y)
	b := y.left
	if b != nil {
		b.parent = x
	}
	x.right = b
	x.parent = y
	y.left = x
	x.balance--
	if y.balance > 0 {
		x.balance -= y.balance
	}
	y.balance--
	if x.balance < 0 {
		y.balance += x.balance
	}
}

func (nd *Node) RotateRight(x *Node) {
	y := x.left
	nd.ReplaceNode(x, y)
	b := y.right
	if b != nil {
		b.parent = x
	}
	x.left = b
	x.parent = y
	y.right = x
	x.balance++
	if y.balance < 0 {
		x.balance -= y.balance
	}
	y.balance++
	if x.balance > 0 {
		y.balance += x.balance
	}
}

func (nd *Node) InsertAvl(key string, value int) *Node {
	a := nd.Insert(key, value)
	for {
		x := a.parent
		if x == nil {
			break
		}
		if a == x.left {
			x.balance--
			if x.balance == 0 {
				break
			}
			if x.balance == -2 {
				if a.balance == 1 {
					nd.RotateLeft(a)
				}
				nd.RotateRight(x)
				break
			}
		} else {
			x.balance++
			if x.balance == 0 {
				break
			}
			if x.balance == 2 {
				if a.balance == -1 {
					nd.RotateRight(a)
				}
				nd.RotateLeft(x)
				break
			}
		}
		a = x
	}
	return a
}

func (nd *Node) Assign(s string, x int) {
	*nd = *nd.InsertAvl(s, x)
}

func (nd *Node) Lookup(s string) (int, bool) {
	return nd.search(s)
}

type AssocArray interface {
	Assign(s string, x int)
	Lookup(s string) (x int, exists bool)
}

type SkipList struct {
	key   string
	value int
	next  []*SkipList
}

func InitSkipList(m int) (arr SkipList) {
	arr.next = make([]*SkipList, m)
	i := 0
	for i < m {
		arr.next[i] = nil
		i++
	}
	return
}

func (arr *SkipList) MapEmpty() bool {
	return arr.next[0] == nil
}

func (x *SkipList) Succ() *SkipList {
	return x.next[0]
}

func Skip(arr *SkipList, m int, k string, p []*SkipList) []*SkipList {
	x := arr
	i := m - 1
	for i >= 0 {
		for x.next[i] != nil && x.next[i].key < k {
			x = x.next[i]
		}
		p[i] = x
		i--
	}
	return p
}

func (arr *SkipList) MapSearch(m int, k string) bool {
	p := make([]*SkipList, m)
	Skip(arr, m, k, p)
	x := p[0].Succ()
	return x != nil && x.key == k
}

func (arr SkipList) Lookup(k string) (int, bool) {
	n := len(arr.next)
	narr := make([]*SkipList, n)
	Skip(&arr, n, k, narr)
	x := narr[0].Succ()
	if x == nil || x.key != k {
		return 0, false
	}
	return x.value, true
}

func (arr SkipList) Assign(k string, val int) {
	n := len(arr.next)
	narr := make([]*SkipList, n)
	Skip(&arr, n, k, narr)
	if narr[0].next[0] != nil && narr[0].next[0].key == k {
		panic(narr[0].next[0])
	}
	x := InitSkipList(n)
	r := rand.Int() * 2
	x.key = k
	x.value = val
	i := 0
	for i < n && (r%2 == 0) {
		x.next[i] = narr[i].next[i]
		narr[i].next[i] = &x
		i++
		r /= 2
	}
	for i < n {
		x.next[i] = nil
		i++
	}
}

func two_dict_analysis(termlist []string, dict1 AssocArray, dict2 AssocArray) {
	var res1, res2 []int
	k1 := 0
	k2 := 0
	for _, term := range termlist {
		if i, ok := dict1.Lookup(term); ok {
			res1 = append(res1, i)
		} else {
			k1++
			dict1.Assign(term, k1)
			res1 = append(res1, k1)
		}
		if i, ok := dict2.Lookup(term); ok {
			res2 = append(res2, i)
		} else {
			k2++
			dict2.Assign(term, k2)
			res2 = append(res2, k2)
		}
	}
	for _, elem := range res1 {
		fmt.Printf("%d ", elem)
	}
	fmt.Println()
	for _, elem := range res2 {
		fmt.Printf("%d ", elem)
	}
}

func lex(sentence string, array AssocArray) []int {
	var res []int
	k := 0
	for _, elem := range strings.Fields(sentence) {
		if i, ok := array.Lookup(elem); ok {
			res = append(res, i)
		} else {
			k++
			array.Assign(elem, k)
			res = append(res, k)
		}
	}
	return res
}

func main() {
	example := `You prolly think that you are better now, better now
				You only say that cause Im not around not around
				You know I never meant to let you down let you down
				Woulda gave you anything woulda gave you everything`
	term_list := strings.Fields(strings.ToLower(example))
	dict1 := new(Node)
	dict2 := InitSkipList(len(term_list))
	two_dict_analysis(term_list, dict1, dict2)
}
