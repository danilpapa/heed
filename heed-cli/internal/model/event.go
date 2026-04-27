package model

import "time"

type Event struct {
	Timestamp time.Time `json:"timestamp"`
	Category  string    `json:"category"`
	Type string         `json:"event_type"`
	Duration  float64   `json:"duration"`
	Detail    string    `json:"detail"`
}