package main

import (
	"flag"
	"fmt"
	"heed-cli/internal/app"
	"heed-cli/internal/selector"
	"log"
	"strings"
)

func main() {
	port := flag.String("port", "9876", "UDP port")
	filterStr := flag.String("filter", "", "filter events by category (comma-separated)")

	flag.Parse()

	var filters []string

	if *filterStr != "" {
		filters = strings.Split(*filterStr, ",")
		for i, f := range filters {
			filters[i] = strings.TrimSpace(f)
		}
	} else {
		availableFilters, err := selector.LoadFilters()
		if err != nil {
			log.Fatal(err)
		}

		selected, err := selector.SelectFilters(availableFilters)
		if err != nil {
			log.Fatal(err)
		}

		filters = selected
	}

	a, err := app.New(*port, filters)
	if err != nil {
		log.Fatal(err)
	}

	a.Run()
}
