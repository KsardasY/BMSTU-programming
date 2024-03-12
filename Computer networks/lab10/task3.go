package main

import (
	"database/sql"
	"flag"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
	"time"
)

const (
	password string = "Je2dTYr6"
	login    string = "iu9networkslabs"
	host     string = "students.yss.su"
	dbname   string = "iu9networkslabs"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}
var addr = flag.String("addr", "localhost:8030", "http service address") //"151.248.113.144:8030"

type feed struct {
	title       string
	description string
}

func main() {
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/task3", task3)
	log.Fatal(http.ListenAndServe(*addr, nil))
}

func (feed *feed) toString() string {
	return feed.title + "<br>" + feed.description +
		"<br>"
}

func task3(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer c.Close()
	db, err := sql.Open("mysql", login+":"+password+"@tcp("+host+")/"+dbname+"?parseTime=true")
	if err != nil {
		panic(err)
	}
	defer db.Close()
	for {
		rows, error := db.Query("select * from iu9networkslabs.KsardasY")
		if err != nil {
			panic(error)
		}
		defer rows.Close()
		var news []feed
		for rows.Next() {
			n := feed{}
			err := rows.Scan(&n.title, &n.description)
			fmt.Println(n.title)
			if err != nil {
				fmt.Println(err)
				continue
			}
			news = append(news, n)
		}
		msg := ""
		if len(news) > 0 {
			msg += news[len(news)-1].toString()
		}
		err := c.WriteMessage(websocket.TextMessage, []byte(msg))
		if err != nil {
			log.Println("write:", err)
			break
		}
		time.Sleep(20 * time.Minute)
	}
}
