package main

import (
	"encoding/json"
	"fmt"
	"github.com/skorobogatov/input"
	"io/ioutil"
	"log"
	"net"
	"os"
	"strings"
)

type Request struct {
	Sender  string `json:"sender"`
	To      string `json:"to"`
	Command string `json:"command"`
	Data    string `json:"data"`
}

type Node struct {
	Address     Address
	Username    string
	Subscribers map[string]bool
	Subscribes  map[string]bool
}
type Address struct {
	IP   string
	Port string
}

func getNetwork() map[string]string {
	file, err := os.Open("network.json")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	byteValue, _ := ioutil.ReadAll(file)
	var Network = make(map[string]string)
	err = json.Unmarshal(byteValue, &Network)
	if err != nil {
		panic(err)
	}
	return Network
}
func (node *Node) AddToNetwork() {
	file, err := os.Open("network.json")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	byteValue, _ := ioutil.ReadAll(file)
	var Network = make(map[string]string)
	err = json.Unmarshal(byteValue, &Network)
	if err != nil {
		panic(err)
	}
	Network[node.Username] = node.Address.IP + node.Address.Port
	data2, _ := json.Marshal(Network)
	err = ioutil.WriteFile("network.json", data2, 0644)
	if err != nil {
		return
	}
}
func (node *Node) deleteFromNetwork() {
	file, err := os.Open("network.json")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	byteValue, _ := ioutil.ReadAll(file)
	var Network = make(map[string]string)
	err = json.Unmarshal(byteValue, &Network)
	if err != nil {
		panic(err)
	}
	delete(Network, node.Username)
	data2, _ := json.Marshal(Network)
	err = ioutil.WriteFile("network.json", data2, 0644)
	if err != nil {
		return
	}
}
func init() {
	if len(os.Args) != 3 {
		panic("usage go run ./clientserver.go <IP:Port> <name>")
	}
}
func main() {
	node := NewNode(os.Args[1], os.Args[2])
	node.AddToNetwork()
	node.Run(handleServer, handleClient)
}
func NewNode(address string, username string) *Node {
	split := strings.Split(address, ":")
	if len(split) != 2 {
		panic("wrong address!")
	}
	return &Node{
		Address: Address{
			split[0], ":" + split[1],
		},
		Username:    username,
		Subscribers: make(map[string]bool),
	}
}
func (node *Node) Run(handleServer func(*Node), handleClient func(*Node)) {
	go handleServer(node)
	handleClient(node)
}
func handleConnection(node *Node, conn net.Conn) {
	defer func(conn net.Conn) {
		err := conn.Close()
		if err != nil {
			return
		}
	}(conn)
	var (
		buffer  = make([]byte, 512)
		message string
		req     *Request
	)
	for {
		length, err := conn.Read(buffer)
		if err != nil {
			break
		}
		message += string(buffer[:length])
	}
	err := json.Unmarshal([]byte(message), &req)

	if err != nil {
		panic(err)
	}

	if req.Command == "subscribe" {
		node.Subscribers[req.Data] = true
	} else if req.Command == "unsubscribe" {
		delete(node.Subscribers, req.Data)
	} else {
		fmt.Printf("\nmesssage from %s :%s \n command =", req.Sender, req.Data)
	}
	//node.logger.Info("Connecting %s to send data...", pack.From)
}
func handleServer(node *Node) {
	listen, err := net.Listen("tcp", node.Address.IP+node.Address.Port)
	if err != nil {
		panic(err)
	}
	defer func(listen net.Listener) {
		err := listen.Close()
		if err != nil {
			panic(err)
		}
	}(listen)
	for {
		conn, err := listen.Accept()
		if err != nil {
			break
		}

		go handleConnection(node, conn)
	}

}
func handleClient(node *Node) {

	for {
		fmt.Printf("command = ")
		command := input.Gets()
		switch command {
		case "exit":
			node.deleteFromNetwork()
			os.Exit(0)
		case "sendMessage":
			fmt.Printf("input your message: ")
			msg := input.Gets()
			node.SendToSubscribers(msg)
		case "subscribe":
			fmt.Printf("name = ")
			node.ConnectByUsername(input.Gets())
		case "unsubscribe":
			fmt.Printf("name = ")
			node.Unsubscribe(input.Gets())
		default:
			fmt.Printf("wrong command\n")
		}
	}
}

func (node *Node) SendToSubscribers(msg string) {
	var newPack = &Request{
		Sender:  node.Address.IP + node.Address.Port,
		Data:    msg,
		Command: "send",
	}
	for subscriber := range node.Subscribers {
		//address = Network[subscriber].Address.IP + Network[subscriber].Address.Port
		newPack.To = getNetwork()[subscriber]
		node.Send(newPack)
	}

}
func (node *Node) Send(pack *Request) {
	conn, err := net.Dial("tcp", pack.To)
	if err != nil {
		delete(node.Subscribers, pack.To)
		log.Printf("\n %s disconnected\n", pack.To)
		return
	}
	defer func(conn net.Conn) {
		err := conn.Close()
		if err != nil {
			panic(err)
		}
	}(conn)
	jsonPack, _ := json.Marshal(pack)
	_, err = conn.Write(jsonPack)
	if err != nil {
		panic(err)
	}
}
func (node *Node) ConnectByUsername(name string) {
	_, ok := getNetwork()[name]
	if ok {
		node.subscribe(name) //sub.Subscribers[node.Username] = true
	} else {
		log.Println("this user doesn`t exist")
		return
	}
}

func (node *Node) subscribe(name string) {
	var newPack = &Request{
		Sender:  node.Address.IP + node.Address.Port,
		Command: "subscribe",
		Data:    node.Username,
		To:      getNetwork()[name],
	}

	node.Send(newPack)

}
func (node *Node) Unsubscribe(name string) {
	_, ok := getNetwork()[name]
	if ok {
		var newPack = &Request{
			Sender:  node.Address.IP + node.Address.Port,
			Command: "unsubscribe",
			Data:    node.Username,
			To:      getNetwork()[name],
		}

		node.Send(newPack)

	} else {
		log.Println("this user doesn`t exist")
	}
}
