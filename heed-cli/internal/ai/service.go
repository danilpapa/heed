package ai

import "heed-cli/internal/model"

type AIService interface {
	AnalyzeEvents(events []*model.Event) (string, error)
}

type Analysis struct {
	Timestamp string
	Issues    []string
	Summary   string
}
