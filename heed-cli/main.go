package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"net"
	"os"
	"strings"
	"time"

	"golang.org/x/term"
)

const BUF_SIZE = 65535

const (
	reset = "\033[0m"
	bold  = "\033[1m"
	dim   = "\033[2m"
	cyan  = "\033[36m"
)

var categoryColors = map[string]string{
	"Network":    "\033[34m",
	"UI":         "\033[32m",
	"Navigation": "\033[35m",
	"Lifecycle":  "\033[33m",
	"Keyboard":   "\033[36m",
	"Gesture":    "\033[95m",
	"Error":      "\033[31m",
}

var fallbackColors = []string{"\033[94m", "\033[92m", "\033[93m", "\033[96m"}
var fallbackIdx int

func colorFor(category string) string {
	if c, ok := categoryColors[category]; ok {
		return c
	}
	c := fallbackColors[fallbackIdx%len(fallbackColors)]
	categoryColors[category] = c
	fallbackIdx++
	return c
}

type EventLog struct {
	Timestamp time.Time `json:"timestamp"`
	Category  string    `json:"category"`
	EventType string    `json:"event_type"`
	Duration  float64   `json:"duration"`
	Detail    string    `json:"detail"`
}

func termHeight() int {
	_, h, err := term.GetSize(int(os.Stdout.Fd()))
	if err != nil || h < 4 {
		return 24
	}
	return h
}

func drawFooter(port, filter string, h int) {
	_, w, err := term.GetSize(int(os.Stdout.Fd()))
	if err != nil || w < 1 {
		w = 80
	}
	sep := strings.Repeat("─", w)

	info := fmt.Sprintf("%s%sheed-cli%s  :%s", bold, cyan, reset, port)
	if filter != "" {
		info += fmt.Sprintf("  %sfilter: %s%s", dim, filter, reset)
	}

	fmt.Printf("\033[s")                         
	fmt.Printf("\033[%d;1H\033[2K%s%s%s", h-1, dim, sep, reset)
	fmt.Printf("\033[%d;1H\033[2K%s", h, info)   
	fmt.Printf("\033[u")                         
}

func setup(port, filter string, h int) {
	fmt.Printf("\033[2J")         
	fmt.Printf("\033[1;%dr", h-2) 
	fmt.Printf("\033[1;1H")       
	drawFooter(port, filter, h)
}

func printEvent(e EventLog, port, filter string, h int) {
	color := colorFor(e.Category)
	t := e.Timestamp.Format("15:04:05")
	dur := fmt.Sprintf("%dms", int(e.Duration*1000))

	fmt.Printf("%s%s%s  %s%-12s%s  %-22s  %s%6s%s  %s\n",
		dim, t, reset,
		color+bold, e.Category, reset,
		e.EventType,
		dim, dur, reset,
		e.Detail,
	)
	drawFooter(port, filter, h)
}

func main() {
	port := flag.String("port", "9876", "UDP port to listen on")
	filter := flag.String("filter", "", "filter events by category")
	flag.Parse()

	addr, err := net.ResolveUDPAddr("udp", ":"+*port)
	if err != nil {
		fmt.Println("error resolving UDP address:", err)
		return
	}
	conn, err := net.ListenUDP("udp", addr)
	if err != nil {
		fmt.Println("error starting listener:", err)
		return
	}
	defer conn.Close()

	h := termHeight()
	setup(*port, *filter, h)

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
		printEvent(event, *port, *filter, h)
	}
}
