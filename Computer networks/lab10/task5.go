package main

import (
	"flag"
	"fmt"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
	"os/exec"
	"strings"
	"time"
)

var addr = flag.String("addr", "localhost:8050", "http service address") //"151.248.113.144:8050"

const url = "yss.su"

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func check(url string) string {
	fmt.Printf("1")
	cmd := exec.Command("tracert", url)
	stdout, err := cmd.Output()
	if err != nil {
		log.Fatal("Failed to execute: ", err)
	}
	res := string(stdout)
	fmt.Println(res)
	if strings.TrimSpace(res)[:36] == "Unable to resolve target system name" {
		fmt.Printf("Ошибка трассировки. %s\n", err)
		return "YSS.SU is not available"
	}
	return res
}

func main() {
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/task5", task5)
	log.Fatal(http.ListenAndServe(*addr, nil))
}

func task5(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer c.Close()
	for {
		msg := check(url)
		fmt.Printf("4")
		err := c.WriteMessage(websocket.TextMessage, []byte(msg))
		if err != nil {
			log.Println("Error:", err)
			break
		}
		time.Sleep(time.Second * 5)
	}
}
