package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"net"
	"time"
)

const BUF_SIZE = 65535

type EventLog struct {
	Timestamp time.Time `json:"timestamp"`
	Category  string    `json:"category"`
	EventType string    `json:"event_type"`
	Duration  float64   `json:"duration"`
	Detail    string    `json:"detail"`
}

func main() {
	port := flag.String("port", "9876", "UDP port to listen on")
	filter := flag.String("filter", "", "filter events by category")

	flag.Parse() // reading arguments

	addr, err := net.ResolveUDPAddr("udp", ":"+*port) // creating UDP addr
	if err != nil {
		fmt.Println("Error resolving UDP address:", err)
		return
	}

	conn, err := net.ListenUDP("udp", addr) // connection to addr
	if err != nil {
		fmt.Println("Error starting listener:", err)
		return
	}
	defer conn.Close()

	fmt.Printf("heed-cli listening on UDP :%s\n", *port)
	if *filter != "" {
		fmt.Printf("filter: %s\n\n", *filter)
	}

	buf := make([]byte, BUF_SIZE)
	for {
		n, _, err := conn.ReadFromUDP(buf)
		if err != nil {
			continue
		}

		var event EventLog
		if err := json.Unmarshal(buf[:n], &event); err != nil {
			continue
		}

		if *filter != "" && event.Category != *filter {
			continue
		}

		durationMs := int(event.Duration * 1000)
		t := event.Timestamp.Format("15:04:05")
		fmt.Printf("[%s] %-12s | %-20s | %dms | %s\n",
			t, event.Category, event.EventType, durationMs, event.Detail)
	}
}
