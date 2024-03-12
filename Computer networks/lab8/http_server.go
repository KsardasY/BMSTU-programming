package main

import (
	"bytes"
	"errors"
	"fmt"
	"html/template"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
)

func getMethod(w http.ResponseWriter, r *http.Request) {
	content := "." + r.URL.Path
	fmt.Println(content)
	fmt.Println("log")
	if content[len(content)-2:] == "py" {
		params := r.URL.Query()
		fmt.Println(params)
		par := make([]string, 1)
		splited := strings.Split(content, "/")
		par[0] = "python/" + splited[len(splited)-1]
		for _, j := range params {
			par = append(par, j...)
		}
		fmt.Println(par)
		cmd1 := exec.Command("python", par...)
		cmd1.Stdout = w
		cmd1.Stderr = w
		err := cmd1.Run()
		if err != nil {
			log.Fatal(err)
		}
	} else {
		data, _ := ioutil.ReadFile(content)
		w.Write(data)
	}
}

func postHandle(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		http.ServeFile(w, r, "server_files/static/form.html")
	case "POST":
		//fmt.Println(r.URL.String())
		path := strings.Join(strings.Split(r.URL.String(), "/")[2:], "/")
		fmt.Println(path)
		err := r.ParseForm()
		if err != nil {
			return
		}
		params := make([]string, 1)
		params[0] = path
		for _, j := range r.Form {
			params = append(params, j...)
		}
		cmd1 := exec.Command("python", params...)
		tml := template.Must(template.ParseFiles("server_files/static/form.html"))
		b := make([]byte, 0)
		buf := bytes.NewBuffer(b)
		cmd1.Stdout = buf
		err = cmd1.Run()
		tml.Execute(w, buf.String())
	}
}

func main() {

	http.HandleFunc("/", getMethod)
	http.HandleFunc("/post/", postHandle)
	//r.HandleFunc("/{path}", getMethod)

	err := http.ListenAndServe(":8000", nil)
	if errors.Is(err, http.ErrServerClosed) {
		fmt.Printf("server closed\n")
	} else if err != nil {
		fmt.Printf("error starting server: %s\n", err)
		os.Exit(1)
	}
}
