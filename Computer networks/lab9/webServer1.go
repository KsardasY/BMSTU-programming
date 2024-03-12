package main

import (
	"flag"
	"fmt"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
	"strconv"
	"strings"
)

var addr = flag.String("addr", "localhost:8080", "http service address")
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func echo(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer c.Close()
	for {
		mt, message, err := c.ReadMessage()
		if err != nil {
			log.Println("read:", err)
			break
		}
		log.Printf("recv: %s", message)
		err = c.WriteMessage(mt, message)
		if err != nil {
			log.Println("write:", err)
			break
		}
	}
}

func findMinMax(message string) (error, int, int) {
	splited := strings.Split(message, " ")
	atoi, err := strconv.Atoi(splited[0])
	if err != nil {
		return err, 0, 0
	}
	min, max := atoi, atoi
	for _, j := range splited {
		atoi, err = strconv.Atoi(j)
		if err != nil {
			return err, 0, 0
		}
		if atoi > max {
			max = atoi
		}
		if atoi < min {
			min = atoi
		}
	}
	return nil, min, max
}

func main() {
	fmt.Println("server started on port 8080")
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/echo", echo)
	log.Fatal(http.ListenAndServe(*addr, nil))
}
