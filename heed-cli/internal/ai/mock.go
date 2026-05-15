package ai

import (
	"fmt"
	"heed-cli/internal/model"
	"sync"
)

type MockAIService struct {
	 mu       sync.Mutex
	callCount int
}

func NewMockAIService() *MockAIService {
	return &MockAIService{
		callCount: 0,
	}
}

func (m *MockAIService) AnalyzeEvents(events []*model.Event) (string, error) {
	m.mu.Lock()
	m.callCount++
	call := m.callCount
	m.mu.Unlock()

	if len(events) == 0 {
		return "No events to analyze", nil
	}

	networkEvents := 0
	uiEvents := 0
	errorEvents := 0

	for _, e := range events {
		if e.Category == "Network" {
			networkEvents++
		} else if e.Category == "UI" {
			uiEvents++
		}
		if e.Detail != "" && len(e.Detail) > 50 {
			errorEvents++
		}
	}

	result := fmt.Sprintf("Analysis #%d:\n", call)
	result += fmt.Sprintf("  📊 Events analyzed: %d\n", len(events))
	result += fmt.Sprintf("  🌐 Network events: %d\n", networkEvents)
	result += fmt.Sprintf("  🎨 UI events: %d\n", uiEvents)

	if errorEvents > 0 {
		result += fmt.Sprintf("  ⚠️  Potential issues detected: %d\n", errorEvents)
	} else {
		result += "  ✅ No issues detected\n"
	}

	return result, nil
}
