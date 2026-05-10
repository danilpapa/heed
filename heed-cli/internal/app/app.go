package app

import (
	"encoding/json"
	"fmt"
	"heed-cli/internal/model"
	"heed-cli/internal/transport"
	"heed-cli/internal/ui"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"sync"
	"syscall"
	"time"
)

type App struct {
	listener  *transport.UDPListener
	renderer  *ui.Renderer
	events    []*model.Event
	mu        sync.Mutex
	exitCh    chan bool
	eventsCh  chan *model.Event
}

func New(port string, filters []string) (*App, error) {
	l, err := transport.NewUDPListener(port)
	if err != nil {
		return nil, err
	}

	r := ui.NewRenderer(filters)

	return &App{
		listener:  l,
		renderer:  r,
		events:    make([]*model.Event, 0),
		exitCh:    make(chan bool),
		eventsCh:  make(chan *model.Event, 100),
	}, nil
}

func (a *App) Run() {
	go a.listenForSignal()
	go a.readEvents()

	fmt.Println("📡 Listening for events... (press Ctrl+C to quit and save)")

	for {
		select {
		case <-a.exitCh:
			fmt.Println("\n💾 Saving events...")
			a.saveToJSON()
			return
		case event := <-a.eventsCh:
			if !a.renderer.ShouldRender(event) {
				continue
			}

			a.mu.Lock()
			a.events = append(a.events, event)
			a.mu.Unlock()

			a.renderer.Render(event)
		}
	}
}

func (a *App) listenForSignal() {
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh
	a.exitCh <- true
}

func (a *App) readEvents() {
	for {
		event, err := a.listener.Read()
		if err != nil {
			continue
		}
		a.eventsCh <- event
	}
}

func (a *App) saveToJSON() error {
	a.mu.Lock()
	defer a.mu.Unlock()

	if len(a.events) == 0 {
		fmt.Println("⚠️  No events to save")
		return nil
	}

	now := time.Now().Format("2006-01-02_15-04-05")
	filename := filepath.Join(os.Getenv("HOME"), "Desktop", fmt.Sprintf("heed-events_%s.json", now))

	desktopDir := filepath.Join(os.Getenv("HOME"), "Desktop")
	if err := os.MkdirAll(desktopDir, 0755); err != nil {
		log.Printf("❌ Failed to create directory: %v", err)
		return err
	}

	data, err := json.MarshalIndent(a.events, "", "  ")
	if err != nil {
		log.Printf("❌ Failed to marshal JSON: %v", err)
		return err
	}

	if err := os.WriteFile(filename, data, 0644); err != nil {
		log.Printf("❌ Failed to write file: %v", err)
		return err
	}

	fmt.Printf("✅ Saved %d events to: %s\n", len(a.events), filename)
	return nil
}
