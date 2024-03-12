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
						Value: name + "==" + switchStmt.Body.List[i].(*ast.CaseClause).List[j].(*ast.BasicLit).Value,
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
