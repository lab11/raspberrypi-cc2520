package main

import (
	"encoding/json"
	"fmt"
	"net"
	"log"
	"strings"
	"os/exec"
	"sync"
	"github.com/lab11/go-tuntap/tuntap"
	"code.google.com/p/gcfg"
)

var prefixes *PrefixManager
var tunids *TunManager

type mutexWrap struct {
	lock *sync.Mutex
}

var client_locks map[string]*mutexWrap

func lockClient (id string) {
	var mw *mutexWrap

	mw = client_locks[id]
	if mw == nil {
		mw = &mutexWrap{lock: new(sync.Mutex)}
	}
	client_locks[id] = mw
	fmt.Println(mw)
	mw.lock.Lock()
}
func unlockClient (id string) {
	fmt.Println("unlocking")
	mw := client_locks[id]
	mw.lock.Unlock()
}


func clientTCP (tcpc net.Conn, tcp_ch chan []byte, quit_ch chan int) {
	for {
		buf := make([]byte, 4096)
		rlen, err := tcpc.Read(buf)
		fmt.Println("got data from TCP")
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
func clientTUN (tun *tuntap.Interface, tun_ch chan []byte, quit_ch chan int,
	quit_ch2 chan int) {
	for {
		pkt, err := tun.ReadPacket()
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println("GOT TUN PACKET")
		fmt.Println(pkt.Packet)

		// Check if there is data in the quit channel that tells us to stop
		select {
		case quit_tun := <- quit_ch:
			if quit_tun == 1 {
				tun.Close()
				<- quit_ch2
				fmt.Println("tun gone")
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

	fmt.Println("got client")

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




	lockClient(newclient.Id)

	fmt.Println("got client lock")

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

	// Setup a tun interface
	tunname := tunids.getNewTunName()
	tun, err := tuntap.Open(tunname, tuntap.DevTun)
	fmt.Println("lies")
	if err != nil { log.Fatal(err) }

	// Remove the /64 portion
	prefixbase := strings.Split(prefix.Prefix, "/")

	// Enable the tun interface
	exec.Command("ifconfig", tunname, "up").Run()

	// Set an IP address for the tun interface
	//exec.Command("ifconfig", tunname, "inet6", "add", prefixbase[0] + "1").Run()
	exec.Command("ifconfig", tunname, "inet6", "add", "fe80::212:cccc:dddd:ffff/64").Run()

	// Route all packets for that prefix to the tun interface
	exec.Command("ip", "-6", "route", "add", prefix.Prefix, "dev",
		tunname).Run()
fmt.Println("sdfs")
	// Setup and run the goroutines that will handle interaction with the client
	tcp_ch := make(chan []byte)
	quit_tcp_ch := make(chan int)
	go clientTCP(tcpc, tcp_ch, quit_tcp_ch)

	tun_ch := make(chan []byte)
	tun_quit_ch := make(chan int, 10)
	tun_quit_ch2 := make(chan int)
	go clientTUN(tun, tun_ch, tun_quit_ch, tun_quit_ch2)

	// Loop while shuffling packets around
	for {
		select {
		case newpkt := <- tcp_ch:
			// Received a packet from the client via the TCP connection
			// Send it to the TUN device
			fmt.Println(newpkt)
			var tuntappkt tuntap.Packet
			tuntappkt.Packet = newpkt
			tun.WritePacket(&tuntappkt)

		case tunpkt := <- tun_ch:
			// Got a packet from the TUN device, destined for the client
			// Write it into the TCP connection
			tcpc.Write(tunpkt)

		case quit_tcp := <- quit_tcp_ch:
			// Got a quit signal from the TCP listener, this means that the
			// client disconnected.
			// Shut everything down
			if quit_tcp == 1 {
				fmt.Println("Client disconnected")
				// Send a quit message to the TUN listener. This will block
				// until the TUN listener gets it, which will only happen
				// once a packet is routed to the now disconnected client.
				tun_quit_ch <- 1
				fmt.Println("sent shutdown")
				// Now send a UDP packet to get the TUN listener to wake it up
				serverAddr, _ := net.ResolveUDPAddr("udp6", "[" + prefixbase[0] + "3]:8765")
				con, _ := net.DialUDP("udp6", nil, serverAddr)
				con.Write([]byte("1"))
				con.Close()

				fmt.Println("sent udp")

				tun_quit_ch2 <- 1

				fmt.Println("unset tunnnn ")
				tunids.unsetTunName(tunname)
				fmt.Println("done with that tun")
				unlockClient(newclient.Id)
				fmt.Println("unlocked clients ")
				return
			}
		}
	}
}

// Sit in a loop accepting TCP connections from tunnel clients
func acceptTcp (tcpl net.Listener) {
	for {
		c, err := tcpl.Accept()
		if err != nil {
			log.Fatal(err)
		}
		go handleClient(c)
	}
}


func main () {
	log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds | log.Lshortfile)

	// Dummy channel that keeps this application alive
	main_quit := make(chan int)

	client_locks = make(map[string]*mutexWrap)

	// Parse the config file
	var cfg ConfigIni
	err := gcfg.ReadFileInto(&cfg, "config.ini")
	if err != nil {
		log.Fatal(err)
	}

	prefixes = Create(cfg.Server.Assignments, cfg.Server.Prefixrange)
	tunids = CreateTunIds()

	// Start the TCP listener
	l, err := net.Listen("tcp", cfg.Server.Localhost + ":" + cfg.Server.Listenport)
	if err != nil {
		log.Fatal(err)
	}

	go acceptTcp(l)

	// Wait on the accept tcp goroutine
	// This keeps the application from exiting
	<- main_quit
}
