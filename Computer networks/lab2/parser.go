package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
)

func serveClient(response http.ResponseWriter, _ *http.Request) {
	req, err := http.Get("https://finance.rambler.ru/currencies/")
	if err != nil {
		log.Fatalln(err)
	}
	defer req.Body.Close()
	b, err := ioutil.ReadAll(req.Body)
	if err != nil {
		log.Fatalln(err)
	}
	htmlCode := string(b)
	w1 := `<div class="finance-currency-table__cell finance-currency-table__cell--code">`
	w2 := `<div class="finance-currency-table__cell finance-currency-table__cell--value">`
	i := strings.Index(htmlCode, w1)
	for i != -1 {
		htmlCode = strings.TrimSpace(htmlCode[i+len(w1):])
		str := htmlCode[:3] + " : "
		i = strings.Index(htmlCode, w2) + len(w2)
		htmlCode = strings.TrimSpace(htmlCode[i:])
		str += strings.TrimSpace(htmlCode[:strings.Index(htmlCode, "<")]) + " RUB"
		i = strings.Index(htmlCode, w1)
		fmt.Println(str)
		response.Write([]byte(str + "\n"))
	}
}

func main() {
	http.HandleFunc("/", serveClient)
	log.Println("starting listener")
	log.Fatalln("listener failed", "error", http.ListenAndServe("127.0.0.1:8000", nil))
}
