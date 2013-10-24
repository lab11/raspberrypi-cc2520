package main

import (
	"fmt"
	"strconv"
	"strings"
	"sync"
)


const TUN_ID_MIN = 0
const TUN_ID_MAX = 15

type TunManager struct {
	tunset map[int]bool
	lock sync.Mutex

}

// Returns tunX
func (t *TunManager) getNewTunName () (tunid string) {
	t.lock.Lock()

	var tunidint int

	for i:=TUN_ID_MIN; i<=TUN_ID_MAX; i++ {
		if !t.tunset[i] {
			t.tunset[i] = true
			tunidint = i
			break
		}
	}

	tunid = "tun" + strconv.Itoa(tunidint)

	t.lock.Unlock()
	return
}

func (t *TunManager) unsetTunName (tunid string) {
	t.lock.Lock()

	tunidstr := strings.TrimLeft(tunid, "tun")
	fmt.Println(tunidstr)

	tunidint, _ := strconv.Atoi(tunidstr)
	fmt.Println("removing tun", tunidint)

	t.tunset[tunidint] = false

	t.lock.Unlock()
}

// Manages which TUN ids are free and not
func CreateTunIds () (*TunManager) {
	var t TunManager
	t.tunset = make(map[int]bool)

	return &t
}
