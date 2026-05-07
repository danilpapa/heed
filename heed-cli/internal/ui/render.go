package ui

import (
	"fmt"
	"heed-cli/internal/model"
)

type Renderer struct {
	filters map[string]bool
}

func NewRenderer(filters []string) *Renderer {
	filterMap := make(map[string]bool)
	for _, f := range filters {
		filterMap[f] = true
	}
	return &Renderer{filters: filterMap}
}

func (r *Renderer) ShouldRender(e *model.Event) bool {
	if len(r.filters) == 0 {
		return true
	}
	return r.filters[e.Category]
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