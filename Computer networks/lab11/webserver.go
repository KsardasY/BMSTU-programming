package main

import (
	"flag"
	"log"
	"net/http"
)

var addr1 = flag.String("addr", "localhost:8000", "http service address")

func main() {
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/dashboard", db)
	log.Fatal(http.ListenAndServe(*addr1, nil))
}

func db(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "form3.html")
}
