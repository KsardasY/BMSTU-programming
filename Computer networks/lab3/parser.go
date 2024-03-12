package main

import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"github.com/mmcdole/gofeed"
)

const (
	password string = "Je2dTYr6"
	login    string = "iu9networkslabs"
	host     string = "students.yss.su"
	dbname   string = "iu9networkslabs"
)

func main() {
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
