package main

import (
	"encoding/json"
	"flag"
	"log"
	"math/big"
	"net"
	"os"
)

import "proto"

// Client - состояние клиента.
type Client struct {
	logger log.Logger    // Объект для печати логов
	conn   *net.TCPConn  // Объект TCP-соединения
	enc    *json.Encoder // Объект для кодирования и отправки сообщений
	sum    *big.Rat      // Текущая сумма полученных от клиента дробей
	count  int64         // Количество полученных от клиента дробей
}

// NewClient - конструктор клиента, принимает в качестве параметра
// объект TCP-соединения.
func NewClient(conn *net.TCPConn) *Client {
	return &Client{
		logger: *log.New(os.Stdout, "RES", log.LstdFlags),
		conn:   conn,
		enc:    json.NewEncoder(conn),
		sum:    big.NewRat(0, 1),
		count:  0,
	}
}

// serve - метод, в котором реализован цикл взаимодействия с клиентом.
// Подразумевается, что метод serve будет вызаваться в отдельной go-программе.
func (client *Client) serve() {
	defer client.conn.Close()
	decoder := json.NewDecoder(client.conn)
	for {
		var req proto.Request
		if err := decoder.Decode(&req); err != nil {
			client.logger.Println("cannot decode message", "reason", err)
			break
		} else {
			client.logger.Println("received command", "command", req.Command)
			if client.handleRequest(&req) {
				client.logger.Println("shutting down connection")
				break
			}
		}
	}
}

// handleRequest - метод обработки запроса от клиента. Он возвращает true,
// если клиент передал команду "quit" и хочет завершить общение.
func (client *Client) handleRequest(req *proto.Request) bool {
	switch req.Command {
	case "quit":
		client.respond("ok", nil)
		return true
	case "calc":
		var vectorString string
		if err := json.Unmarshal(*req.Data, &vectorString); err != nil {
			client.logger.Println("addition failed", "reason", "Can't unmarshal")
			client.respond("failed", "Can't unmarshal")
		} else {
			res, code := proto.Calc(vectorString)
			switch code {
			case 1:
				client.respond("failed", "error: string can't interpreted as 2 vectors")
			case 2:
				client.respond("failed", "error: dementions of vectors don't match")
			default:
				client.respond("result", res)
			}
		}
	default:
		client.logger.Println("unknown command")
		client.respond("failed", "unknown command")
	}
	return false
}

// respond - вспомогательный метод для передачи ответа с указанным статусом
// и данными. Данные могут быть пустыми (data == nil).
func (client *Client) respond(status string, data interface{}) {
	var raw json.RawMessage
	raw, _ = json.Marshal(data)
	client.enc.Encode(&proto.Response{status, &raw})
}

func main() {
	// Работа с командной строкой, в которой может указываться необязательный ключ -addr.
	var addrStr string
	flag.StringVar(&addrStr, "addr", "127.0.0.1:6000", "specify ip address and port")
	flag.Parse()

	// Разбор адреса, строковое представление которого находится в переменной addrStr.
	if addr, err := net.ResolveTCPAddr("tcp", addrStr); err != nil {
		log.Fatalln("address resolution failed", "address", addrStr)
	} else {
		log.Println("resolved TCP address", "address", addr.String())

		// Инициация слушания сети на заданном адресе.
		if listener, err := net.ListenTCP("tcp", addr); err != nil {
			log.Fatalln("listening failed", "reason", err)
		} else {
			// Цикл приёма входящих соединений.
			for {
				if conn, err := listener.AcceptTCP(); err != nil {
					log.Fatalln("cannot accept connection", "reason", err)
				} else {
					log.Println("accepted connection", "address", conn.RemoteAddr().String())

					// Запуск go-программы для обслуживания клиентов.
					go NewClient(conn).serve()
				}
			}
		}
	}
}
