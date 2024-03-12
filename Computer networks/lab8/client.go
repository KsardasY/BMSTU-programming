package main

import (
	"bufio"
	"bytes"
	"fmt"
	"github.com/jlaffaye/ftp"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"time"
)

const ftp_host = "127.0.0.1"
const port = "2001"
const login = "admin"
const password = "123456"

var currentCommands = map[string]string{
	"uploadFile":          "загрузка файла",
	"downloadFile":        "скачивание файла",
	"deleteFile":          "удаление файла",
	"createDirectory":     "создание директории",
	"getContentDirectory": "получение содержимого директории",
	"exit":                "завершение работы",
	"help":                "список доступных команд",
}

func main() {
	log.Println("Подключение к серверу " + ftp_host + ":" + port)
	c, err := ftp.Dial(ftp_host+":"+port, ftp.DialWithTimeout(5*time.Second))
	if err != nil {
		log.Fatal(err)
	}
	log.Println("Подключение успешно")
	log.Println("Вход в систему")
	err = c.Login(login, password)
	if err != nil {
		log.Fatal(err)
	}
	log.Println("Вход одобрен")
	var exit = true
	var scanner = bufio.NewScanner(os.Stdin)
	for exit {
		var line string
		var comm string
		var args []string
		fmt.Print("$ ")
		scanner.Scan()
		line = scanner.Text()
		splitted := strings.Split(line, " ")
		if len(splitted) == 0 {
			log.Println("null split")
			continue
		}
		comm = splitted[0]
		if len(splitted) > 1 {
			args = append(args, splitted[1:]...)
		}
		exit = switchCommands(comm, args, c)
	}
	if err := c.Quit(); err != nil {
		log.Fatal(err)
	}
}

func switchCommands(comm string, args []string, c *ftp.ServerConn) bool {
	switch comm {
	case "uploadFile":
		if len(args) == 1 {
			uploadFile(args[0], c)
		} else {
			log.Println("Неправильное количество аргументов")
		}
	case "downloadFile":
		if len(args) == 1 {
			downloadFile(args[0], c)
		} else {
			log.Println("Неправильное количество аргументов")
		}
	case "deleteFile":
		if len(args) == 1 {
			deleteFile(args[0], c)
		} else {
			log.Println("Неправильное количество аргументов")
		}
	case "createDirectory":
		if len(args) == 1 {
			createDirectory(args[0], c)
		} else {
			log.Println("Неправильное количество аргументов")
		}
	case "getContentDirectory":
		if len(args) == 1 {
			getContentDirectory(args[0], c)
		} else {
			log.Println("Неправильное количество аргументов")
		}
	case "exit":
		return false
	case "help":
		fmt.Println("Вам доступны следующие команды:")
		for command, value := range currentCommands {
			fmt.Println(" " + command + " - " + value)
		}
	default:
		println("Команды: " + comm + " не существует." +
			"Введите 'help' для получения актуальных команд")
	}
	return true
}

func uploadFile(fileName string, c *ftp.ServerConn) {
	log.Println("Загрузка файла " + fileName)
	file, err := os.ReadFile(fileName)
	if err != nil {
		log.Println(err)
	}
	data := bytes.NewBuffer(file)
	err = c.Stor(fileName, data)
	if err != nil {
		log.Println(err)
	}
	log.Println("Файл " + fileName + " успешно скачан")
}

func downloadFile(fileName string, c *ftp.ServerConn) {
	log.Println("Скачивание файла: " + fileName)
	file, err := c.Retr(fileName)
	if err != nil {
		log.Println(err)
	}
	defer func(file *ftp.Response) {
		err := file.Close()
		if err != nil {
		}
	}(file)
	buf, err := ioutil.ReadAll(file)
	err = os.WriteFile("test.txt", buf, 0666)
	if err != nil {
		log.Println(err)
	}
	log.Println("Файл" + fileName + " успешно скачан")
}

func deleteFile(fileName string, c *ftp.ServerConn) {
	log.Println("Удаление файла " + fileName)
	err := c.Delete(fileName)
	if err != nil {
		log.Println(err)
	}
	log.Println("Файл " + fileName + " успешно удалён")
}

func createDirectory(dirName string, c *ftp.ServerConn) {
	log.Println("Создание директории " + dirName)
	err := c.MakeDir(dirName)
	if err != nil {
		log.Println(err)
	}
	log.Println("Директория " + dirName + " успешно создана")
}

func getContentDirectory(dirName string, c *ftp.ServerConn) {
	log.Println("Получение содержимого директории " + dirName)
	w := c.Walk(dirName)
	for w.Next() {
		println(w.Path())
	}
	log.Println("Содержимое директории " + dirName + " успешно получено")
}
