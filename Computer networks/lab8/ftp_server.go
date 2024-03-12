package main

import (
	filedriver "github.com/goftp/file-driver"
	"github.com/goftp/server"
)

func main() {
	factory := &filedriver.FileDriverFactory{
		RootPath: "server_files",
		Perm:     server.NewSimplePerm("root", "root"),
	}
	auth := &server.SimpleAuth{
		Name:     "admin",
		Password: "123456",
	}
	opts := &server.ServerOpts{
		Factory:  factory,
		Port:     2001,
		Hostname: "127.0.0.1",
		Auth:     auth,
	}
	newServer := server.NewServer(opts)
	err := newServer.ListenAndServe()
	if err != nil {
		return
	}
}
