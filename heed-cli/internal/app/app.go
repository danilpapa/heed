package app

import (
	"heed-cli/internal/transport"
	"heed-cli/internal/ui"
)

type App struct {
	listener *transport.UDPListener
	renderer *ui.Renderer
}

func New(port, filter string) (*App, error) {
	l, err := transport.NewUDPListener(port)
	if err != nil {
		return nil, err
	}
	
	r := ui.NewRenderer(filter)
	
	return &App{
		listener: l,
		renderer: r,
	}, nil
}

func (a *App) Run() {
	for {
		event, err := a.listener.Read()
		if err != nil {
			continue
		}
		
		if !a.renderer.ShouldRender(event) {
			continue
		}
		
		a.renderer.Render(event)
	}
}
