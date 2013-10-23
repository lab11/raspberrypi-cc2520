package main

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"net"
	"log"
	"time"
	"math/rand"
	"strconv"
)



const serverAddr = "localhost:14629"

type ClientIdentifier struct {
	Id string
}

type ClientPrefix struct {
	Prefix string
}

func senddata (tcpc net.Conn, quitChan chan int) {


	// Get our unique ID (should be mac address)
	var unique_id ClientIdentifier
	rand.Seed(time.Now().Unix())
	unique_id.Id = strconv.Itoa(rand.Int())

	// Get a JSON blob of the id
	idbuf, err := json.Marshal(unique_id)
	if err != nil { log.Fatal(err) }

	fmt.Printf("%s\n%s\n", unique_id.Id,  idbuf)

	// Send that blob
	_, err = tcpc.Write(idbuf)
	if err != nil {
		log.Fatal(err)
	}

	// Listen for the prefix
	pbuf := make([]byte, 4906)
	rlen, err := tcpc.Read(pbuf)
	if err != nil { log.Fatal(err) }

	// Decode the JSON blob containing the prefix
	var cprefix ClientPrefix
	err = json.Unmarshal(pbuf[0:rlen], &cprefix)
	if err != nil { log.Fatal(err) }

	fmt.Println("Got Prefix: ", cprefix.Prefix)

	var i uint64 = 300
	for {
		fmt.Println("Sending", i)

		b := make([]byte, 8)
		binary.LittleEndian.PutUint64(b, i)


		_, err := tcpc.Write(b)
		if err != nil {
			log.Fatal(err)
		}
		i++

		time.Sleep(time.Second * 4)
	}

	// "exit" when done
	quitChan <- 1
}

func main () {

	quitChan := make(chan int)

	c, err := net.Dial("tcp", serverAddr)
	if err != nil {
		log.Fatal(err)
	}

	go senddata(c, quitChan)

	// Wait for data to appear
	<- quitChan



}

