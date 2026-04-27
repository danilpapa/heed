package main

import (
	"flag"
	"heed-cli/internal/app"
	"log"
)

func main() {
	port := flag.String("port", "9876", "UDP port")
	filter := flag.String("filter", "", "filter events by category")

	flag.Parse()

	a, err := app.New(*port, *filter)
	if err != nil {
		log.Fatal(err)
	}

	a.Run()
}
