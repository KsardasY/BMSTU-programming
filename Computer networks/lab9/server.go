package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"github.com/gorilla/websocket"
	"html/template"
	"log"
	"net/http"
	"net/url"
	"os"
)

var addr1 = flag.String("addr", "localhost:8080", "http service address")

func postHandle(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		http.ServeFile(w, r, "form.html")
	case "POST":
		err := r.ParseForm()
		if err != nil {
			return
		}
		pkg, err := json.Marshal(r.Form)
		u := url.URL{Scheme: "ws", Host: *addr1, Path: "/echo"}
		log.Printf("connecting to %s", u.String())
		c, _, err := websocket.DefaultDialer.Dial(u.String(), nil)
		if err != nil {
			log.Fatal("dial:", err)
		}
		defer c.Close()
		err = c.WriteMessage(websocket.TextMessage, pkg)
		if err != nil {
			log.Println("write:", err)
			return
		}
		_, message, err := c.ReadMessage()
		if err != nil {
			log.Println("read:", err)
			return
		}
		tml := template.Must(template.ParseFiles("form.html"))
		tml.Execute(w, string(message))
	}
}

func syncHandle(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "form2.html")
}

func main() {
	fmt.Println("server started on 3333 port")
	http.HandleFunc("/part1", postHandle)
	http.HandleFunc("/part2", syncHandle)
	err := http.ListenAndServe(":3333", nil)
	if errors.Is(err, http.ErrServerClosed) {
		fmt.Printf("server closed\n")
	} else if err != nil {
		fmt.Printf("error starting server: %s\n", err)
		os.Exit(1)
	}
}
