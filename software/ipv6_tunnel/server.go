package main

import (
	"encoding/json"
	"fmt"
	"net"
	"log"
	"sync"
	"strconv"
	"strings"
	"os/exec"
	"github.com/lab11/go-tuntap/tuntap"
	"code.google.com/p/gcfg"
)




var prefix_map map[string]string
var prefix_greatest int = 5
var prefix_map_lock sync.Mutex

var tun_id_set map[int]bool
var tun_id_lock sync.Mutex
const TUN_ID_MIN = 0
const TUN_ID_MAX = 15

func getPrefix (id string) (prefix string) {
	prefix_map_lock.Lock()

	prefix, in := prefix_map[id]

	if !in {
		prefix_greatest += 1
		prefix_map[id] = strconv.Itoa(prefix_greatest) + "::"
		prefix = prefix_map[id]
	}

	prefix_map_lock.Unlock()
	return
}

// Returns tunX
func getTunName () (tunid string) {
	tun_id_lock.Lock()

	var tunidint int

	for i:=TUN_ID_MIN; i<=TUN_ID_MAX; i++ {
		if !tun_id_set[i] {
			tun_id_set[i] = true
			tunidint = i
			break
		}
	}

	tunid = "tun" + strconv.Itoa(tunidint)

	tun_id_lock.Unlock()
	return
}

func unsetTunName (tunid string) {
	tun_id_lock.Lock()

	var tunidint int
	var aa string
	aa = strings.TrimLeft(tunid, "tun")
	fmt.Println(aa)
	fmt.Println(tunid)

	//tunidint = strconv.Atoi(aa)

	tun_id_set[tunidint] = false

	tun_id_lock.Unlock()
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

func clientTUN (tun *tuntap.Interface, tun_ch chan []byte) {


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

	// Setup a tun interface
	tunname := getTunName()
	tun, err := tuntap.Open(tunname, tuntap.DevTun)
	if err != nil {
		log.Fatal(err)
	}

	// Set an IP address for the tun interface
	exec.Command("ifconfig", tunname, "inet6", prefix.Prefix + "2").Run()

	// Route all packets for that prefix to the tun interface
	exec.Command("route", "add", "-inet6", prefix.Prefix + "/64", prefix.Prefix + "2").Run()

	tcp_ch := make(chan []byte)
	quit_tcp_ch := make(chan int)
	go clientTCP(tcpc, tcp_ch, quit_tcp_ch)

	tun_ch := make(chan []byte)
	go clientTUN(tun, tun_ch)

	var newpkt []byte
	var tunpkt []byte
	var quit_tcp int
	for {
		select {
		case newpkt = <- tcp_ch:
			fmt.Println(newpkt)

			var tuntappkt tuntap.Packet
			tuntappkt.Packet = newpkt
			tun.WritePacket(&tuntappkt)

		case quit_tcp = <- quit_tcp_ch:
			if quit_tcp == 1 {
				fmt.Println("Client disconnected")
				tun.Close()
				unsetTunName(tunname)
				return
			}

		case tunpkt = <- tun_ch:
			fmt.Println(tunpkt)
			tcpc.Write(tunpkt)
		}
	}


}

func acceptTcp (tcpl net.Listener, client_quit chan int) {


	for {
		c, err := tcpl.Accept()
		if err != nil {
			log.Fatal(err)
		}
		go handleClient(c)
	}




}


func main () {
	client_quit := make(chan int)

	prefix_map = make(map[string]string)
	tun_id_set = make(map[int]bool)



	// Parse the config file
	var cfg ConfigIni
	err := gcfg.ReadFileInto(&cfg, "config.ini")
	if err != nil {
		log.Fatal(err)
	}




	l, err := net.Listen("tcp", cfg.Server.Localhost + ":" + cfg.Server.Listenport)
	if err != nil {
		log.Fatal(err)
	}

	go acceptTcp(l, client_quit)

	// Wait on the accept tcp goroutine
	// This keeps the application from exiting
	<- client_quit



}

