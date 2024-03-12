package main

import (
	"github.com/gliderlabs/ssh"
	"golang.org/x/crypto/ssh/terminal"
	"log"
	"os/exec"
	"strings"
)

func defaultHandler(session ssh.Session) {
	term := terminal.NewTerminal(session, ">> ")
	for {
		line, err := term.ReadLine()
		if err != nil {
			log.Fatal("Failed to read line: ", err)
		}
		split := strings.Split(line, " ")
		cmd := exec.Command(split[0], split[1:]...)
		cmd.Stdout = session
		cmd.Stderr = session

		if err := cmd.Run(); err != nil {
			log.Fatal("Failed to run: ", err)
		}
	}
}

func main() {
	ssh.Handle(defaultHandler)
	log.Println("Starting ssh server on 8000 port")
	err := ssh.ListenAndServe(":8000", nil)
	if err != nil {
		log.Fatal(err)
	}
}
