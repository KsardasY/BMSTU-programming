package main

import (
	"database/sql"
	"flag"
	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/websocket"
	"github.com/mmcdole/gofeed"
	"log"
	"net/http"
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

var address = flag.String("addr", "localhost:8031", "http service address") //"151.248.113.144:8031"

func clear() {
	db, _ := sql.Open("mysql", login+":"+password+"@tcp("+host+")/"+dbname+"?parseTime=true")
	db.Query("TRUNCATE iu9networkslabs.KsardasY")
}

func save() {
	db, err := sql.Open("mysql", login+":"+password+"@tcp("+host+")/"+dbname)
	if err != nil {
		panic(err)
	}
	defer db.Close()
	fp := gofeed.NewParser()
	feed, _ := fp.ParseURL("https://neftegaz.ru/export/yandex.php")
	k := 0
	for _, item := range feed.Items {
		if exist, err := db.Query("SELECT COUNT(*) FROM iu9networkslabs.KsardasY WHERE title = ? AND description = ?",
			item.Title, item.Description); err != nil {
			panic(err)
		} else {
			defer exist.Close()
			for exist.Next() {
				if err := exist.Scan(&k); err != nil {
					panic(err)
				}
			}
			if k == 0 {
				_, err := db.Exec("INSERT INTO iu9networkslabs.KsardasY (title, description) VALUES (?, ?)",
					item.Title, item.Description)
				if err != nil {
					panic(err)
				}
			}
		}
	}
}

func main() {
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/task3", task3_1)
	log.Fatal(http.ListenAndServe(*address, nil))
}

func task3_1(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer c.Close()
	for {
		mt, message, err := c.ReadMessage()
		if err != nil {
			log.Println("read:", err)
			break
		}
		log.Printf("recv: %s", message)
		msg := string(message)
		switch msg {
		case "save":
			save()
		case "clear":
			clear()
		}
		err = c.WriteMessage(mt, message)
		if err != nil {
			log.Println("write:", err)
			break
		}
	}
}
