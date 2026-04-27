package ui

import (
	"fmt"
	"heed-cli/internal/model"
)

type Renderer struct {
	filter string
}

func NewRenderer(filter string) *Renderer {
	return &Renderer{filter: filter}
}

func (r *Renderer) ShouldRender(e *model.Event) bool {
	if r.filter == "" {
		return true
	}
	return e.Category == r.filter
}

func (r *Renderer) Render(e *model.Event) {
	t := e.Timestamp.Format("15:04:05")
	dur := fmt.Sprintf("%dms", int(e.Duration*1000))
	
	fmt.Printf("%s  %-12s  %-22s  %6s  %s\n",
		t,
		e.Category,
		e.Type,
		dur,
		e.Detail,
	)
}