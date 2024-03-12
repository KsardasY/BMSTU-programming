package main

import (
	"flag"
	filedriver "github.com/goftp/file-driver"
	"github.com/goftp/server"
	"log"
)

const (
	path     string = "C:/Users/Lenovo/Downloads"
	username string = "KsardasY"  //
	password string = "YsadrasK"  //
	host     string = "localhost" //
	port     int    = 8000
)

func main() {
	var (
		rootDir  = flag.String("rootDir", path, "rootdir")
		userName = flag.String("userName", username, "Username")
		password = flag.String("password", password, "Password")
		port     = flag.Int("port", port, "Port")
		host     = flag.String("host", host, "Host")
	)
	flag.Parse()
	if *rootDir == "" {
		log.Fatalf("Incorrict path")
	}
	factory := &filedriver.FileDriverFactory{
		RootPath: *rootDir,
		Perm:     server.NewSimplePerm("user", "group"),
	}
	settings := &server.ServerOpts{
		Factory:  factory,
		Port:     *port,
		Hostname: *host,
		Auth:     &server.SimpleAuth{Name: *userName, Password: *password},
	}
	log.Printf("Server started on %v:%v", settings.Hostname, settings.Port)
	log.Printf("Username %v, Password %v", *userName, *password)
	serv := server.NewServer(settings)
	err := serv.ListenAndServe()
	if err != nil {
		log.Fatal("Server start error:", err)
	}
}
