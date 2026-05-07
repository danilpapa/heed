.PHONY: help build run install-deps clean

BINARY_NAME=heed-cli
GO=go
PORT?=9876

help:
	@echo "Heed CLI - Event Log Monitor"
	@echo ""
	@echo "Usage:"
	@echo "  make build         Build the CLI binary"
	@echo "  make run           Build and run with TUI filter selector"
	@echo "  make run-no-filter Run without filter selector (show all events)"
	@echo "  make run-filter F=<filter> Run with specific filter (comma-separated)"
	@echo "  make install-deps  Download Go dependencies"
	@echo "  make clean         Remove built binary"
	@echo ""
	@echo "Examples:"
	@echo "  make run"
	@echo "  make run PORT=9877"
	@echo "  make run-filter F=UI,Network"

build:
	$(GO) mod download
	$(GO) build -o $(BINARY_NAME) .

run: build
	./$(BINARY_NAME) -port $(PORT)

run-no-filter: build
	./$(BINARY_NAME) -port $(PORT) -filter ""

run-filter: build
	./$(BINARY_NAME) -port $(PORT) -filter "$(F)"

install-deps:
	$(GO) mod download
	$(GO) mod tidy

clean:
	rm -f $(BINARY_NAME)
