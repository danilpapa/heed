package ui

import (
	"fmt"
	"heed-cli/internal/model"
	"regexp"
	"strings"
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

func (r *Renderer) formatDetail(detail string) string {
	// Check if it's an error
	if strings.Contains(detail, "Error Domain") {
		return r.formatNetworkError(detail)
	}

	// Truncate long details
	if len(detail) > 80 {
		return detail[:77] + "..."
	}
	return detail
}

func (r *Renderer) formatNetworkError(errStr string) string {
	// Extract error code
	codeRe := regexp.MustCompile(`Code=(-\d+)`)
	codeMatch := codeRe.FindStringSubmatch(errStr)

	// Extract error message
	msgRe := regexp.MustCompile(`"([^"]*)"`)
	msgMatch := msgRe.FindStringSubmatch(errStr)

	if len(msgMatch) > 1 && len(codeMatch) > 1 {
		msg := msgMatch[1]
		code := codeMatch[1]

		// Common error codes
		icon := "❌"
		switch code {
		case "-1003":
			msg = "DNS lookup failed: " + msg
		case "-1001":
			msg = "Timeout: " + msg
		case "-1009":
			msg = "No internet connection"
		}

		return fmt.Sprintf("%s %s", icon, msg)
	}

	// Fallback: just grab the error message
	if len(msgMatch) > 1 {
		return fmt.Sprintf("❌ %s", msgMatch[1])
	}

	return "❌ Network error"
}

func (r *Renderer) Render(e *model.Event) {
	t := e.Timestamp.Format("15:04:05")
	dur := fmt.Sprintf("%dms", int(e.Duration*1000))
	detail := r.formatDetail(e.Detail)

	fmt.Printf("%s  %-12s  %-22s  %6s  %s\n",
		t,
		e.Category,
		e.Type,
		dur,
		detail,
	)
}