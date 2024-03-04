% Лабораторная работа № 2.1. Синтаксические деревья
% 4 марта 2024 г.
% Андрей Мельников, ИУ9-62Б

### Цель работы
Целью данной работы является изучение представления синтаксических деревьев в памяти компилятора и
приобретение навыков преобразования синтаксических деревьев.

### Индивидуальный вариант
Заменить все операторы switch стандартного (C-образного) вида на аналогичные по логике работы 
операторы switch без выражения.

### Реализация
**Демонстрационная программа**
```go
package main

import "fmt"

func t() {
	var a int
	a = 1
	switch a = 1; a {
	case 2:
		fmt.Println("bbb")
	case 1:
		fmt.Println("aaa")
	}

}
```

**Программа, осуществляющая преобразование синтаксического дерева:**
```go
package main

import (
	"fmt"
	"go/ast"
	"go/format"
	"go/parser"
	"go/token"
	"os"
)

func insert(file *ast.File) {
	ast.Inspect(file, func(node ast.Node) bool {
		if switchStmt, ok := node.(*ast.SwitchStmt); ok {
			name := switchStmt.Tag.(*ast.Ident).Name
			switchStmt.Tag = nil

			for i := 0; i < len(switchStmt.Body.List); i++ {
				globalList := switchStmt.Body.List[i]
				for j := 0; j < len(globalList.(*ast.CaseClause).List); j++ {
					switchStmt.Body.List[i].(*ast.CaseClause).List[j] = &ast.BasicLit{
						Kind:  token.STRING,
						Value: name + "==" + switchStmt.Body.List[i].
							(*ast.CaseClause).List[j].(*ast.BasicLit).Value,
					}
				}
			}
		}
		return true
	})
}

func main() {
	if len(os.Args) != 2 {
		return
	}

	fset := token.NewFileSet()

	if file, err := parser.ParseFile(fset, os.Args[1], nil, parser.ParseComments); err == nil {
		insert(file)

		if format.Node(os.Stdout, fset, file) != nil {
			fmt.Printf("Formatter error: %v\n", err)
		}
		ast.Fprint(os.Stdout, fset, file, nil)
	} else {
		fmt.Printf("Errors in %s\n", os.Args[1])
	}
}
```
### Тестирование
**Результат трансформации демонстрационной программы:**
```go
package main

import "fmt"

func t() {
        var a int
        a = 1
        switch a = 1; {
        case a==2:
                fmt.Println("bbb")
        case a==1:
                fmt.Println("aaa")
        }

}
```
### Вывод
В ходе данной лабораторной работы был получен опыт разработки на языке Golang, изучено представление синтаксических
деревьев в памяти компиллятора и приобретены навыки работы с ними.
