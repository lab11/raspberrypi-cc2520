package main

import (
	"encoding/json"
	"fmt"
	"net"
	"log"
	"sync"
	"github.com/lab11/go-tuntap/tuntap"
)

type ClientIdentifier struct {
	Id string
}

type ClientPrefix struct {
	Prefix string
}

const recvAddr = "localhost:14629"

var prefix_map map[string]string
var prefix_greatest string = "5"
var prefix_map_lock sync.Mutex

func getPrefix (id string) (prefix string) {
	prefix_map_lock.Lock()

	prefix, in := prefix_map[id]

	if !in {
		prefix_greatest += "0"
		prefix_map[id] = prefix_greatest
		prefix = prefix_greatest
	}

	prefix_map_lock.Unlock()
	return
}

func clientTCP (tcpc net.Conn, tcp_ch chan []byte, quit_ch chan int) {

	for {
		buf := make([]byte, 4096)
		rlen, err := tcpc.Read(buf)
		if err != nil {
			// Disconnect
			quit_ch <- 1
			break
		}

		tcp_ch <- buf[0:rlen]
	}
}

func clientTUN (tun_ch chan []byte) {
	var tun *tuntap.Interface
	var err error

	tun, err = tuntap.Open("tun0", tuntap.DevTun)
	if err != nil {
		log.Fatal(err)
	}

	tun.ReadPacket()
}

// Takes care of interacting with a client
func handleClient (tcpc net.Conn) {
	buf := make([]byte, 4096)

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

	tcp_ch := make(chan []byte)
	quit_tcp_ch := make(chan int)
	go clientTCP(tcpc, tcp_ch, quit_tcp_ch)

	tun_ch := make(chan []byte)
	go clientTUN(tun_ch)

	var newpkt []byte
	var tunpkt []byte
	var quit_tcp int
	for {
		select {
		case newpkt = <- tcp_ch:
			fmt.Println(newpkt)
		case quit_tcp = <- quit_tcp_ch:
			if quit_tcp == 1 {
				fmt.Println("Client disconnected")
				return
			}
		case tunpkt = <- tun_ch:
			fmt.Println(tunpkt)
		}
	}


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

	prefix_map = make(map[string]string)

	l, err := net.Listen("tcp", recvAddr)
	if err != nil {
		log.Fatal(err)
	}

	go acceptTcp(l, tcp_quit)

	// Wait on the accept tcp goroutine
	<- tcp_quit



}

