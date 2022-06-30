package main

import (
	"fmt"
	"os"
	"strconv"
)

var dict map[string]int

type Lexem struct {
	Tag
	Image string
}

type Tag int

const (
	ERROR  Tag = 1 << iota // Неправильная лексема
	NUMBER                 // Целое число
	VAR                    // Имя переменной
	PLUS                   // Знак +
	MINUS                  // Знак -
	MUL                    // Знак *
	DIV                    // Знак /
	LPAREN                 // Левая круглая скобка
	RPAREN                 // Правая круглая скобка
)

func lexer(expr string, lexems chan Lexem) {
	defer close(lexems)
	for i := 0; i < len(expr); i++ {
		if expr[i] == ' ' {
			continue
		} else if expr[i] == '+' {
			lexems <- Lexem{PLUS, "+"}
		} else if expr[i] == '-' {
			lexems <- Lexem{MINUS, "-"}
		} else if expr[i] == '*' {
			lexems <- Lexem{MUL, "*"}
		} else if expr[i] == '/' {
			lexems <- Lexem{DIV, "/"}
		} else if expr[i] == '(' {
			lexems <- Lexem{LPAREN, "("}
		} else if expr[i] == ')' {
			lexems <- Lexem{RPAREN, ")"}
		} else if '0' <= expr[i] && expr[i] <= '9' {
			j := i + 1
			for j < len(expr) && '0' <= expr[j] && expr[j] <= '9' {
				j++
			}
			lexems <- Lexem{NUMBER, expr[i:j]}
			i = j - 1
		} else if 'a' <= expr[i] && expr[i] <= 'z' || 'A' <= expr[i] && expr[i] <= 'Z' {
			j := i + 1
			for j < len(expr) && ('a' <= expr[j] && expr[j] <= 'z' || 'A' <= expr[j] && expr[j] <= 'Z' || '0' <= expr[j] && expr[j] <= '9') {
				j++
			}
			lexems <- Lexem{VAR, expr[i:j]}
			i = j - 1
		} else {
			lexems <- Lexem{ERROR, expr[i : i+1]}
		}
	}
}

type LexemeBuffer struct {
	pos    int
	lexems []Lexem
}

func (buff *LexemeBuffer) next() Lexem {
	buff.pos++
	return buff.lexems[buff.pos-1]
}

func (buff *LexemeBuffer) back() {
	buff.pos--
}

func (buff *LexemeBuffer) getPos() int {
	return buff.pos
}

func (buff *LexemeBuffer) expr() (int, bool) {
	if buff.pos >= len(buff.lexems) {
		return 0, true
	} else {
		return buff.plusminus()
	}
}

func (buff *LexemeBuffer) plusminus() (int, bool) {
	res, f := buff.multdiv()
	if !f {
		return 0, false
	}
	for buff.pos < len(buff.lexems) {
		lexeme := buff.next()
		switch lexeme.Tag {
		case PLUS:
			x, f := buff.multdiv()
			if !f {
				return 0, false
			}
			res += x
			break
		case MINUS:
			x, f := buff.multdiv()
			if !f {
				return 0, false
			}
			res -= x
			break
		default:
			buff.back()
			return res, true
		}
	}
	return res, true
}

func (buff *LexemeBuffer) multdiv() (int, bool) {
	res, f := buff.factor()
	if !f {
		return 0, false
	}
	for buff.pos < len(buff.lexems) {
		lexeme := buff.next()
		switch lexeme.Tag {
		case MUL:
			x, f := buff.factor()
			if !f {
				return 0, false
			}
			res *= x
			break
		case DIV:
			x, f := buff.factor()
			if !f {
				return 0, false
			}
			res /= x
			break
		default:
			buff.back()
			return res, true
		}
	}
	return res, true
}

func (buff *LexemeBuffer) factor() (int, bool) {
	if buff.pos == len(buff.lexems) {
		return 0, false
	}
	lexeme := buff.next()
	switch lexeme.Tag {
	case NUMBER:
		res, _ := strconv.Atoi(lexeme.Image)
		return res, true
	case VAR:
		if x, ok := dict[lexeme.Image]; ok {
			return x, true
		} else {
			var t int
			fmt.Scan(&t)
			dict[lexeme.Image] = t
			return t, true
		}
	case LPAREN:
		res, f := buff.expr()
		if !f {
			return 0, false
		}
		lexeme = buff.next()
		if lexeme.Tag != RPAREN {
			return 0, false
		}
		return res, true
	default:
		return 0, false
	}
}

func main() {
	example := os.Args[1]
	lexems := make(chan Lexem)
	go lexer(example, lexems)
	var lexeme_list []Lexem
	f := true
	for lexem := range lexems {
		lexeme_list = append(lexeme_list, lexem)
		if f && lexem.Tag == ERROR {
			fmt.Println("error")
			f = false
		}
	}
	if f && !(lexeme_list[len(lexeme_list)-1].Tag == RPAREN || lexeme_list[len(lexeme_list)-1].Tag == NUMBER || lexeme_list[len(lexeme_list)-1].Tag == VAR) {
		fmt.Println("error")
		f = false
	}
	if f {
		buff := LexemeBuffer{0, lexeme_list}
		dict = make(map[string]int)
		x, f := buff.expr()
		if buff.pos == len(buff.lexems) && f {
			fmt.Println(x)
		} else {
			fmt.Println("error")
		}
	}
}
