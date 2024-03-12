package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"github.com/gorilla/websocket"
	"log"
	"net/url"
	"os"
	"os/signal"
)

var addr = flag.String("addr", "localhost:8021", "http service address")

func main() {
	flag.Parse()
	log.SetFlags(0)
	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)
	u := url.URL{Scheme: "ws", Host: *addr, Path: "/"}
	log.Printf("connecting to %s", u.String())
	c, _, err := websocket.DefaultDialer.Dial(u.String(), nil)
	if err != nil {
		log.Fatal("dial:", err)
	}
	defer c.Close()
	for {
		var bt string
		fmt.Println("Enter 1 or 0: ")
		fmt.Scan(&bt)
		switch bt {
		case "q":
			return
		default:
			js, err := json.Marshal(bt)
			if err != nil {
				log.Println(err)
				break
			}
			err = c.WriteMessage(websocket.TextMessage, js)
			if err != nil {
				log.Println(err)
				break
			}
			_, mes, err := c.ReadMessage()
			log.Println(string(mes))
		}
	}
}
