package main

import (
	"context"
	firebase "firebase.google.com/go"
	"flag"
	"fmt"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/gorilla/websocket"
	"google.golang.org/api/option"
	"log"
	"math/big"
	"net/http"
	"strconv"
	"time"
)

type blockS struct {
	ChainId  string `json:"chainId"`
	Hash     string `json:"hash"`
	Value    string `json:"value"`
	Cost     string `json:"cost"`
	To       string `json:"to"`
	Gas      string `json:"gas"`
	GasPrice string `json:"gasPrice"`
}

var ctx = context.Background()

// configure database URL
var conf = &firebase.Config{
	DatabaseURL: "https://ksardasy-default-rtdb.europe-west1.firebasedatabase.app/",
}
var addr = flag.String("addr", "localhost:8013", "http service address")
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// fetch service account key
var opt = option.WithCredentialsFile("ksardasy-firebase-adminsdk-d86ye-3cd4006523.json")

func getBlocks() []blockS {
	blocks := make([]blockS, 0)
	client, err := ethclient.Dial("https://mainnet.infura.io/v3/fd72849937cf4aa8901cd0578700d562")
	if err != nil {
		log.Fatalln(err)
	}
	blockNumber := big.NewInt(15960495)
	block, err := client.BlockByNumber(context.Background(), blockNumber) //get block with this number
	if err != nil {
		log.Fatal(err)
	}
	for _, tx := range block.Transactions() {
		_block := blockS{}
		_block.ChainId = tx.ChainId().String()
		_block.Hash = tx.Hash().String()
		_block.Value = tx.Value().String()
		_block.Cost = tx.Cost().String()
		_block.To = tx.To().String()
		_block.Gas = strconv.FormatUint(tx.Gas(), 10)
		_block.GasPrice = tx.GasPrice().String()
		blocks = append(blocks, _block)
	}
	return blocks
}

func task1(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer conn.Close()
	for {
		blocks := getBlocks()
		res_message := ""
		for _, block := range blocks {
			msg := "<u>Hash:</u> " + block.Hash + "<br> <u>Cost:</u> " + block.Cost + "<br> <u>Gas:</u> " + block.Gas + "<br> <u>Price:</u> " + block.GasPrice + "<br> <u>ChainID: </u>" + block.ChainId + "<br>"
			res_message += msg
		}
		storeBlocks(blocks)
		err = conn.WriteMessage(websocket.TextMessage, []byte(res_message))
		if err != nil {
			log.Println("write:", err)
			break
		}
		time.Sleep(time.Second * 30)
	}
}
func storeBlocks(blocks []blockS) {
	app, err := firebase.NewApp(ctx, conf, opt)
	if err != nil {
		log.Fatalln("error in initializing firebase app: ", err)
	}

	client, err := app.Database(ctx)
	if err != nil {
		log.Fatalln("error in creating firebase DB client: ", err)
	}
	for i, block := range blocks {
		ref := client.NewRef("transactions/ " + fmt.Sprint(i))
		if err := ref.Set(context.TODO(), block); err != nil {
			log.Fatal(err)
		}
	}
}
func main() {
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/task3", task1)
	log.Fatal(http.ListenAndServe(*addr, nil))
}
