package main

import (
	"encoding/binary"
	"encoding/json"
	"errors"
	"log"
	"net"
	"os"
	"strconv"
	"strings"
	"sync"
)

type PrefixManager struct {
	prefixfile *os.File // the file to store the prefix assignments in
	prefixes map[string]string // map of id -> prefix
	inuse map[string]bool // map of prefix -> bool; marks prefixes as used
	prefixcidr *net.IPNet // the range of available prefixes
	prefixstart uint64 // first prefix in integer form
	lock sync.Mutex // only one client can get a prefix at a time
}

// When a client connects retrieve the prefix they should use.
// First tries to find if they have already connected and uses the previous
// prefix.
func (pm *PrefixManager) getPrefix (id string) (prefix string, err error) {
	pm.lock.Lock()

	prefix, in := pm.prefixes[id]

	if !in {
		var i uint64 = pm.prefixstart
		ipb := make([]byte, 16)

		for {
			binary.BigEndian.PutUint64(ipb[0:8], i)
			binary.BigEndian.PutUint64(ipb[8:16], 0)
			possible_prefix := net.IP(ipb).String() + "/64"

			if pm.prefixcidr.Contains(ipb) {
				taken, in := pm.inuse[possible_prefix]
				if !in || !taken {
					pm.prefixes[id] = possible_prefix
					pm.inuse[possible_prefix] = true
					prefix = possible_prefix
					break
				}
			} else {
				pm.lock.Unlock()
				return "", errors.New("Out of prefixes")
			}
			i++
		}
	}

	// Write the result to the file
	pm.prefixfile.Seek(0, 0)
	b, _ := json.Marshal(pm.prefixes)
	pm.prefixfile.Write(b)

	pm.lock.Unlock()
	return prefix, nil
}

func Create (filename string, prefixrange string) (*PrefixManager) {
	var err error

	var pm PrefixManager
	pm.prefixes = make(map[string]string)
	pm.inuse = make(map[string]bool)

	// Read in all the existing assignments
	assignbuf := make([]byte, 12000)
	pm.prefixfile, err = os.OpenFile(filename, os.O_RDWR, 0)
	rlen, err := pm.prefixfile.Read(assignbuf)
	err = json.Unmarshal(assignbuf[0:rlen], &pm.prefixes)

	// Put all of the assigned prefixes in the used set
	for k, _ := range pm.prefixes {
		pm.inuse[pm.prefixes[k]] = true
	}

	// Get the prefix block to select prefixes from
	_, pm.prefixcidr, err = net.ParseCIDR(prefixrange)
	if err != nil { log.Fatal(err) }

	// Figure out the first IP address in the prefix range
	prefixstrings := strings.Split(prefixrange, "/")
	prefixip := net.ParseIP(prefixstrings[0])
	pm.prefixstart = binary.BigEndian.Uint64(prefixip)
	// Now mask only those bits in the prefix
	prefixlen, _ := strconv.Atoi(prefixstrings[1])
	prefixlenu64 := uint64(prefixlen)
	pm.prefixstart = ((pm.prefixstart >> (64 - prefixlenu64)) << (64 - prefixlenu64))


	return &pm
}


