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

var prefixes *PrefixManager

var tun_id_set map[int]bool
var tun_id_lock sync.Mutex
const TUN_ID_MIN = 0
const TUN_ID_MAX = 15





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

	tunidstr := strings.TrimLeft(tunid, "tun")
	fmt.Println(tunidstr)

	tunidint, _ := strconv.Atoi(tunidstr)
	fmt.Println("removing tun", tunidint)

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

// Block on reading from the TUN device
// After receiving data from the TUN device it checks to see if the client
// has disconnected and if so quits.
func clientTUN (tun *tuntap.Interface, tun_ch chan []byte, quit_ch chan int) {
	for {
		pkt, err := tun.ReadPacket()
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(pkt.Packet)

		// Check if there is data in the quit channel that tells us to stop
		select {
		case quit_tun := <- quit_ch:
			if quit_tun == 1 {
				return
			}
		default:

		}

		tun_ch <- pkt.Packet
	}
}

// Takes care of interacting with a client
func handleClient (tcpc net.Conn) {
	buf := make([]byte, 4096)
	var err error

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
	prefix.Prefix, err = prefixes.getPrefix(newclient.Id)
	if err != nil { log.Fatal(err) }
	fmt.Println("Going to assign prefix: ", prefix.Prefix)

	// Send the client the prefix
	pbuf, err := json.Marshal(prefix)
	if err != nil {
		log.Fatal(err)
	}
	tcpc.Write(pbuf)

	fmt.Println("before tun")

	// Setup a tun interface
	tunname := getTunName()
	fmt.Println("trying to use tunname", tunname)
	tun, err := tuntap.Open(tunname, tuntap.DevTun)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(tunname)

	// Remove the /64 portion
	prefixbase := strings.Split(prefix.Prefix, "/")

	// Enable the tun interface
	exec.Command("ifconfig", tunname, "up").Run()
	fmt.Println("up")

	// Set an IP address for the tun interface
	exec.Command("ifconfig", tunname, "inet6", "add", prefixbase[0] + "2").Run()
	fmt.Println("got ip for tun")

	// Route all packets for that prefix to the tun interface
	exec.Command("ip", "-6", "route", "add", prefix.Prefix, "dev",
		tunname).Run()
	fmt.Println("added route")

	tcp_ch := make(chan []byte)
	quit_tcp_ch := make(chan int)
	go clientTCP(tcpc, tcp_ch, quit_tcp_ch)

	tun_ch := make(chan []byte)
	tun_quit_ch := make(chan int)
	go clientTUN(tun, tun_ch, tun_quit_ch)

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
				//exec.Command("ifconfig", tunname, "down").Run()
				tun_quit_ch <- 1
				err = tun.Close()
				if (err != nil) { log.Fatal(err) }
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

	tun_id_set = make(map[int]bool)



	// Parse the config file
	var cfg ConfigIni
	err := gcfg.ReadFileInto(&cfg, "config.ini")
	if err != nil {
		log.Fatal(err)
	}

	prefixes = Create(cfg.Server.Assignments, cfg.Server.Prefixrange)




	l, err := net.Listen("tcp", cfg.Server.Localhost + ":" + cfg.Server.Listenport)
	if err != nil {
		log.Fatal(err)
	}

	go acceptTcp(l, client_quit)

	// Wait on the accept tcp goroutine
	// This keeps the application from exiting
	<- client_quit



}

