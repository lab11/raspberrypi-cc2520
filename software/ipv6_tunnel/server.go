package main

import (
	"encoding/json"
	"fmt"
	"net"
	"log"
)

type ClientIdentifier struct {
	Id string
}

type ClientPrefix struct {
	Prefix string
}

const recvAddr = "localhost:14629"

func getPrefix (id string) (prefix string) {
	prefix = "a"
	return
}

// Takes care of interacting with a client
func handleClient (tcpc net.Conn) {
	buf := make([]byte, 200)

	var newclient ClientIdentifier

	for {
		// Read in a message
		// This should be a JSON blob
		rlen, err := tcpc.Read(buf)
		if err != nil {
			log.Fatal(err)
		}

		// Parse the JSON blob into a ClientIdentifer
		err = json.Unmarshal(buf[0:rlen], &newclient)
		if err != nil {
			continue
		}

		fmt.Println(newclient)
		break
	}

	// Get the unique prefix for this client
	var prefix ClientPrefix
	prefix.Prefix = getPrefix(newclient.Id)
	fmt.Println("Going to assign prefix: ", prefix.Prefix)

	// Send the client the prefix
	pbuf, err := json.Marshal(prefix)
	if err != nil {
		log.Fatal(err)
	}
	tcpc.Write(pbuf)


}

func acceptTcp (tcpl net.Listener, tcp_quit chan int) {


	for {
		c, err := tcpl.Accept()
		if err != nil {
			log.Fatal(err)
		}
		go handleClient(c)
	}




}


func main () {
	tcp_quit := make(chan int)

	l, err := net.Listen("tcp", recvAddr)
	if err != nil {
		log.Fatal(err)
	}

	go acceptTcp(l, tcp_quit)

	// Wait on the accept tcp goroutine
	<- tcp_quit



}

