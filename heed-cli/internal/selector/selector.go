package selector

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"github.com/AlecAivazis/survey/v2"
)

func LoadFilters() ([]string, error) {
	file, err := os.Open("filters.txt")
	if err != nil {
		return nil, fmt.Errorf("failed to open filters.txt: %w", err)
	}
	defer file.Close()

	var filters []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line != "" {
			filters = append(filters, line)
		}
	}

	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("failed to read filters.txt: %w", err)
	}

	return filters, nil
}

func SelectFilters(filters []string) ([]string, error) {
	var selected []string

	prompt := &survey.MultiSelect{
		Message: "Select event filters (use arrow keys, space to select, enter to confirm):",
		Options: filters,
	}

	err := survey.AskOne(prompt, &selected)
	if err != nil {
		return nil, err
	}

	return selected, nil
}
