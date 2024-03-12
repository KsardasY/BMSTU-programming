package proto

import (
	"encoding/json"
	"strconv"
)

// Request -- запрос клиента к серверу.
type Request struct {
	// Поле Command может принимать три значения:
	// * "quit" - прощание с сервером (после этого сервер рвёт соединение);
	// * "add" - передача новой дроби на сервер;
	// * "avg" - просьба посчитать среднее арифметическое всех переданных дробей.
	Command string `json:"command"`

	// Если Command == "add", в поле Data должна лежать дробь
	// в виде структуры Fraction.
	// В противном случае, поле Data пустое.
	Data *json.RawMessage `json:"data"`
}

// Response -- ответ сервера клиенту.
type Response struct {
	// Поле Status может принимать три значения:
	// * "ok" - успешное выполнение команды "quit" или "add";
	// * "failed" - в процессе выполнения команды произошла ошибка;
	// * "result" - среднее арифметическое дробей вычислено.
	Status string `json:"status"`

	// Если Status == "failed", то в поле Data находится сообщение об ошибке.
	// Если Status == "result", в поле Data должна лежать дробь
	// в виде структуры Fraction.
	// В противном случае, поле Data пустое.
	Data *json.RawMessage `json:"data"`
}

func isWhitespace(c uint8) bool {
	return c == ' ' || c == '\n' || c == '\t'
}

func isDigit(s uint8) bool {
	return '0' <= s && s <= '9'
}

func Calc(s string) (int, int) {
	i := 0
	k := 0
	var firstVector, secondVector []int
	for i < len(s) && k != 2 {
		for i < len(s) && isWhitespace(s[i]) {
			i++
		}
		if s[i] == '(' {
			i++
			for i < len(s) && s[i] != ')' {
				for i < len(s) && isWhitespace(s[i]) {
					i++
				}
				if isDigit(s[i]) || s[i] == '-' {
					j := i + 1
					for j < len(s) && isDigit(s[j]) {
						j++
					}
					if i == j-1 && s[i] == ' ' {
						return 0, 1
					}
					d, _ := strconv.Atoi(s[i:j])
					if k == 0 {
						firstVector = append(firstVector, d)
					} else {
						secondVector = append(secondVector, d)
					}
					i = j
				} else if s[i] == ',' {
					i++
				} else if s[i] != ')' {
					return 0, 1
				}
			}
			k++
			i++
		} else {
			return 0, 1
		}
	}
	if len(firstVector) != len(secondVector) {
		return 0, 2
	}
	res := 0
	i = 0
	for i < len(firstVector) {
		res += firstVector[i] * secondVector[i]
		i++
	}
	return res, 0
}
