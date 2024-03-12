package main

import (
	"bytes"
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"github.com/jlaffaye/ftp"
	"github.com/mmcdole/gofeed"
	"github.com/skorobogatov/input"
	"io/ioutil"
	"log"
	"strconv"
	"strings"
	"time"
)

const (
	password  string = "Je2dTYr6"
	login     string = "iu9networkslabs"
	host      string = "students.yss.su"
	dbname    string = "iu9networkslabs"
	username  string = "KsardasY"
	upassword string = "YsadrasK"
)

func main() {
	c, err := ftp.Dial("localhost:8000", ftp.DialWithTimeout(5*time.Second))
	if err != nil {
		log.Fatalln("Server connection error", err)
	}
	err = c.Login(username, upassword)
	if err != nil {
		log.Fatalln(err)
	}
waitCommand:
	print("Enter command: ")
	command := input.Gets()
	switch command {
	case "add":
		data := bytes.NewBufferString("Hello World again")
		err = c.Stor(strconv.FormatInt(time.Now().Unix(), 10)+".txt", data)
		if err != nil {
			log.Println(err)
		}
	case "read":
		print("print name of file what you want to read: ")
		fileName := input.Gets()
		r, err := c.Retr(fileName)
		if err != nil {
			log.Println(err)
		}
		buf, err := ioutil.ReadAll(r)
		if err != nil {
			println(err.Error())
		}
		println(string(buf))
		err = r.Close()
		if err != nil {
			println(err.Error())
		}
	case "mkdir":
		print("print name of dir what you want to make: ")
		newDir := input.Gets()
		err = c.MakeDir(newDir)
		if err != nil {
			println(err)
		}
	case "rm":
		print("print name of file what you want to delete: ")
		rm := input.Gets()
		err = c.Delete(rm)
		if err != nil {
			println(err)
		}
	case "ls":
		names, err := c.List("")
		if err != nil {
			println(err)
		}
		for i := 0; i < len(names); i++ {
			println(names[i].Name)
		}
	case "news":
		db, err := sql.Open("mysql", login+":"+password+"@tcp("+host+")/"+dbname)
		if err != nil {
			panic(err)
		}
		defer db.Close()
		fp := gofeed.NewParser()
		feed, _ := fp.ParseURL("https://neftegaz.ru/export/yandex.php")
		k := 0
		var news []string
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
					news = append(news, item.Title, item.Description, "\n")
				}
			}
		}
		name := "Melnikov_Andrey_" + strconv.FormatInt(time.Now().Unix(), 10) + ".txt"
		data := bytes.NewBufferString(strings.Join(news, ""))
		err = c.Stor(name, data)
		if err != nil {
			panic(err)
		}
	case "q":
		goto end
	}
	goto waitCommand
end:
	if err := c.Quit(); err != nil {
		log.Fatalln(err)
	}
}
