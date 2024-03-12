package main

import (
	"encoding/json"
	"flag"
	"github.com/gorilla/websocket"
	"io/ioutil"
	"log"
	"net/http"
)

var addr = flag.String("addr", "localhost:8021", "http service address")
var upgrader = websocket.Upgrader{} // use default options

type rspns struct {
	check       bool
	value       string
	message     string
	requestTime string
}

func echo(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer conn.Close()
	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			log.Println("read:", err)
			break
		}
		var b string
		err = json.Unmarshal(message, &b)
		res, err := http.Get("http://iocontrol.ru/api/sendData/IOTDacha/LampBitovka/" + b)
		if err != nil {
			log.Fatalln(err)
		}
		body, err := ioutil.ReadAll(res.Body)
		if err != nil {
			log.Fatalln(err)
		}

		var (
			data rspns
			s    string
		)
		err = json.Unmarshal(body, &data)
		if data.check {
			s = data.requestTime
		} else {
			s = "Bad Request"
		}
		js, err := json.Marshal(s)
		if err != nil {
			log.Println(err)
			break
		}
		err = conn.WriteMessage(websocket.TextMessage, js)
		if err != nil {
			log.Println("write", err)
			break
		}
	}
}

func main() {
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/", echo)
	log.Fatal(http.ListenAndServe(*addr, nil))
}
