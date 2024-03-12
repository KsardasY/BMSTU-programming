package main

import (
	"context"
	firebase "firebase.google.com/go"
	"flag"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/gorilla/websocket"
	"google.golang.org/api/option"
	"log"
	"math/big"
	"net/http"
	"strconv"
	"time"
)

var ctx = context.Background()

// configure database URL
var conf = &firebase.Config{
	DatabaseURL: "https://ksardasy-default-rtdb.europe-west1.firebasedatabase.app/",
}
var addr = flag.String("addr", "localhost:8011", "http service address")
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// fetch service account key
var opt = option.WithCredentialsFile("ksardasy-firebase-adminsdk-d86ye-3cd4006523.json")

type block2 struct {
	Number       string `json:"number"`
	Time         string `json:"time"`
	Difficulty   string `json:"difficulty"`
	Hash         string `json:"hash"`
	Transactions string `json:"transactions"`
}

func getLast() block2 {
	client, err := ethclient.Dial("https://mainnet.infura.io/v3/fd72849937cf4aa8901cd0578700d562")
	if err != nil {
		log.Fatalln(err)
	}
	blockNumber := big.NewInt(15960495)
	block, err := client.BlockByNumber(context.Background(), blockNumber) //get block with this number
	if err != nil {
		log.Fatal(err)
	}
	// all info about block
	_block := block2{}
	_block.Number = block.Number().String()
	_block.Time = strconv.FormatUint(block.Time(), 10)
	_block.Difficulty = block.Difficulty().String()
	_block.Hash = block.Hash().Hex()
	_block.Transactions = strconv.Itoa(len(block.Transactions()))
	return _block
}
func storeBlock(block block2) {
	app, err := firebase.NewApp(ctx, conf, opt)
	if err != nil {
		log.Fatalln("error in initializing firebase app: ", err)
	}
	client, err := app.Database(ctx)
	if err != nil {
		log.Fatalln("error in creating firebase DB client: ", err)
	}
	ref := client.NewRef("data_from_last_block/ ")
	if err := ref.Set(context.TODO(), block); err != nil {
		log.Fatal(err)
	}
}
func main() {
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/task1", task3)
	log.Fatal(http.ListenAndServe(*addr, nil))
}

func task3(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer conn.Close()
	for {
		block := getLast()
		storeBlock(block)
		message := "<u>Time:</u> " + block.Time + "<br> <u>Hash:</u> " + block.Hash + "<br> <u>Number:</u> " + block.Number + "<br> <u>Difficulty:</u> " + block.Difficulty + "<br> <u>Transactions: </u>" + block.Transactions
		err = conn.WriteMessage(websocket.TextMessage, []byte(message))
		if err != nil {
			log.Println("write:", err)
			break
		}
		time.Sleep(time.Second * 30)
	}
}
