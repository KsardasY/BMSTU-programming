package main

import (
	"bytes"
	"flag"
	"github.com/gorilla/websocket"
	"golang.org/x/crypto/ssh"
	"log"
	"net/http"
	"strings"
	"time"
)

const (
	IP       = "151.248.113.144"
	PORT     = "443"
	LOGIN    = "test"
	PASSWORD = "SDHBCXdsedfs222"
)

var addr = flag.String("addr",
	"localhost:8010", //"151.248.113.144:8010"
	"http service address")

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func ls(conn *ssh.Client) []string {
	var stdOut, stdErr bytes.Buffer

	session, err := conn.NewSession()
	if err != nil {
		log.Fatal(err)
	}
	defer session.Close()

	session.Stdout = &stdOut
	session.Stderr = &stdErr

	session.Run("ls")
	return strings.Fields(stdOut.String())
}

func get(conn *ssh.Client, filename string) string {
	var stdOut, stdErr bytes.Buffer

	session, err := conn.NewSession()
	if err != nil {
		log.Fatal(err)
	}
	defer session.Close()

	session.Stdout = &stdOut
	session.Stderr = &stdErr

	session.Run("сat " + filename)
	return stdOut.String()
}

func task1(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer conn.Close()
	config := &ssh.ClientConfig{
		User: LOGIN,
		Auth: []ssh.AuthMethod{
			ssh.Password(PASSWORD)},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}
	c, err := ssh.Dial("tcp", IP+":"+PORT, config)
	if err != nil {
		log.Fatal("Failed to dial: ", err)
	}
	defer c.Close()
	f := true
	for {
		files := ls(c)
		find := false
		for _, file := range files {
			if file == "achtung.txt" {
				find = true
				break
			}
		}
		if find {
			if f {
				f = !f
				message := get(c, "achtung.txt")
				err := conn.WriteMessage(websocket.TextMessage, []byte(message))
				if err != nil {
					log.Println("write:", err)
					break
				}
			} else {
				continue
			}
		} else {
			if !f {
				f = !f
				err = conn.WriteMessage(websocket.TextMessage, []byte("norm"))
				if err != nil {
					log.Println("write:", err)
					break
				}
			}
		}
		time.Sleep(2 * time.Second)
	}
}

func main() {
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/task1", task1)
	log.Fatal(http.ListenAndServe(*addr, nil))
}
