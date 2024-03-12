package main

import (
	"golang.org/x/crypto/ssh"
	"io"
	"log"
	"os"
)

const (
	IP       = "151.248.113.144"
	PORT     = "443"
	LOGIN    = "iu9lab"
	PASSWORD = "12345678990iu9iu9"
)

func main() {
	config := &ssh.ClientConfig{
		User: LOGIN,
		Auth: []ssh.AuthMethod{
			ssh.Password(PASSWORD)},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	conn, err := ssh.Dial("tcp", IP+":"+PORT, config)
	if err != nil {
		log.Fatal("Failed to dial: ", err)
	}
	defer conn.Close()

	session, err := conn.NewSession()
	if err != nil {
		log.Fatal("Failed to create new session: ", err)
	}
	defer session.Close()
	stdin, err := session.StdinPipe()
	if err != nil {
		log.Fatalf("Unable to setup stdin for session: %v", err)
	}
	go io.Copy(stdin, os.Stdin)
	session.Stdin = os.Stdin
	session.Stdout = os.Stdout
	session.Stderr = os.Stderr
	modes := ssh.TerminalModes{
		ssh.ECHO:          0,
		ssh.TTY_OP_ISPEED: 14400,
		ssh.TTY_OP_OSPEED: 14400,
	}
	if err := session.RequestPty("xterm", 40, 80, modes); err != nil {
		log.Fatal("Requst for fake terminal failed: ", err)
	}
	if err := session.Shell(); err != nil {
		log.Fatal("Failed to start shell: ", err)
	}
	if err := session.Wait(); err != nil {
		log.Fatal("Failed to return: ", err)
	}
}
