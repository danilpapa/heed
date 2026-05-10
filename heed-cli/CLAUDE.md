# Heed CLI - Project Documentation

## Project Overview

**heed-cli** is a Go-based command-line tool that listens to iOS app event logs sent over UDP from the `HeedInstrument` Swift SDK. It receives JSON-formatted events and displays them in the terminal with optional filtering by event category.

This is part of the broader Heed project, which provides automated event instrumentation and monitoring for iOS applications.

## Architecture

### High-Level Flow

1. **HeedInstrument (iOS)** → Captures UI/network/lifecycle events via runtime swizzling
2. **UDPExporter** → Sends events as JSON packets over UDP
3. **heed-cli** → Listens on UDP port, receives events, filters them, displays in terminal

### Core Components

#### 1. **main.go** - Entry Point
- Parses command-line flags (`--port`, `--filter`)
- Either loads filters from command-line OR shows interactive TUI selector
- Creates and runs the app
- **Key logic**: If no filter flag provided, triggers interactive multi-select TUI

#### 2. **internal/selector/** - Filter Selection TUI
- **LoadFilters()** - Reads available filters from `filters.txt`
- **SelectFilters()** - Shows interactive multi-select prompt using `survey/v2`
  - Arrow keys to navigate
  - Space to toggle selection
  - Enter to confirm
  - Filters start UNSELECTED

#### 3. **internal/app/** - Main Application
- **App struct** - Contains UDP listener and renderer
- **Run()** - Infinite loop that:
  - Reads events from UDP
  - Filters events based on selected categories
  - Renders (prints) matching events

#### 4. **internal/ui/render.go** - Event Display
- **Renderer struct** - Holds filter map for O(1) lookup
- **ShouldRender()** - Checks if event matches selected filters
- **Render()** - Pretty-prints events to console:
  ```
  HH:MM:SS  CATEGORY     EVENTTYPE              DURATION  DETAIL
  ```

#### 5. **internal/transport/udp.go** - UDP Listener
- Creates UDP connection on specified port
- Reads incoming packets
- Deserializes JSON to Event struct

#### 6. **internal/model/event.go** - Data Model
```go
type Event struct {
    Timestamp time.Time
    Category  string    // Navigation, UI, Network, Performance, App, Reliability
    Type      string    // Specific event type
    Duration  float64   // In seconds
    Detail    string    // Event details
}
```

## Available Filters

Located in `filters.txt` (one per line):
- **Navigation** - Screen navigation, push/pop events
- **UI** - Button taps, text field edits, gestures
- **Network** - HTTP requests, response status
- **Performance** - Duration metrics, slow operations
- **App** - App lifecycle, backgrounding, foregrounding
- **Reliability** - Errors, crashes, warnings

## Building and Running

### Build
```bash
make build          # Compile binary
go build -o heed-cli .
```

### Run with Interactive TUI
```bash
make run            # Default port 9876
make run PORT=9877  # Custom port
```
- Shows interactive filter selector
- Filters unchecked by default
- Use arrow keys, space to select, enter to confirm

### Run with Pre-selected Filters
```bash
make run-filter F=UI,Network
make run-filter F=Navigation
```

### Run without Filters (Show All Events)
```bash
make run-no-filter
```

### Dependencies
```bash
make install-deps   # Download Go dependencies
```

## Dependencies

- **survey/v2** - Interactive CLI prompts and multi-select
- **golang.org/x/term** - Terminal utilities
- Standard library: flag, fmt, log, strings, bufio, os, time, etc.

## File Structure

```
heed-cli/
├── main.go                          # Entry point
├── Makefile                         # Build and run targets
├── go.mod                           # Go module definition
├── filters.txt                      # Available filter categories
├── internal/
│   ├── app/
│   │   └── app.go                  # Main app logic
│   ├── selector/
│   │   └── selector.go             # TUI filter selector
│   ├── ui/
│   │   └── render.go               # Event rendering
│   ├── transport/
│   │   └── udp.go                  # UDP listener
│   └── model/
│       └── event.go                # Event data structure
└── heed-cli                         # Compiled binary (after build)
```

## How It Works - Step by Step

### 1. User Starts the App
```bash
$ make run
```

### 2. Filter Selection (if no --filter flag)
```
main.go → selector.LoadFilters() → Load from filters.txt
       → selector.SelectFilters() → Show TUI prompt
```

TUI Display:
```
? Select event filters (use arrow keys, space to select, enter to confirm):
  ◯ Navigation
  ◯ UI
  ◯ Network
  ◯ Performance
  ◯ App
  ◯ Reliability
```

User selects: Space on UI, Space on Network, Enter
→ filters = ["UI", "Network"]

### 3. App Startup
```
main.go → app.New(*port, filters)
       → NewRenderer(filters)      // Creates filter map
       → app.Run()                 // Start listening
```

### 4. Event Loop
```
for {
    event := listener.Read()        // Read UDP packet
    if !renderer.ShouldRender(event) {
        continue                    // Skip if not matching filters
    }
    renderer.Render(event)          // Print to terminal
}
```

### 5. iOS App sends event (from HeedInstrument)
```json
{
  "timestamp": "2026-05-07T23:30:45.123Z",
  "category": "UI",
  "type": "buttonTapped",
  "duration": 0.05,
  "detail": "LoginButton"
}
```

### 6. Event Rendering
```
23:30:45  UI           buttonTapped              50ms  LoginButton
```

## Key Implementation Details

### Filter Selection
- Uses `github.com/AlecAivazis/survey/v2` for interactive prompts
- `MultiSelect` component with:
  - Arrow keys for navigation
  - Space for toggling selection
  - Enter to confirm
  - All options start UNSELECTED

### Filtering Logic
- **Renderer.filters** is a `map[string]bool` for O(1) lookups
- If no filters selected: show all events
- If filters selected: only show events where `event.Category` is in the map

### Port Configuration
- Default: 9876 (configured in HeedInstrument's UDPExporter)
- Configurable via `--port` flag or `PORT=` in make

## Recent Implementation (May 2026)

1. Created `Makefile` with targets for different run modes
2. Implemented interactive TUI filter selector using survey/v2
3. Updated filter handling from single filter to multiple filters
4. Created `filters.txt` with hardcoded categories
5. Enhanced `app.go` to accept slice of filters
6. Updated `render.go` to use filter map instead of string comparison

## Command-Line Flags

```bash
./heed-cli -port 9876              # Listen on port 9876
./heed-cli -filter "UI,Network"    # Use specific filters (no TUI)
./heed-cli -port 9877 -filter "App"  # Both options combined
```

## Error Handling

- **LoadFilters()** - Returns error if filters.txt not found or unreadable
- **SelectFilters()** - Returns error if user cancels or input fails
- **app.New()** - Returns error if UDP listener fails
- All errors logged with `log.Fatal()` and exit the program

## Testing Locally

1. Build heed-cli: `make build`
2. Start listener: `make run` (select filters)
3. Run HeedSandbox iOS app with UDP export to localhost:9876
4. Events should appear in terminal

## Future Enhancements

- Add filter persistence (save last selection)
- Support for complex filter expressions (AND, OR, NOT)
- Output formats: JSON, CSV, etc.
- Event logging to file
- Real-time statistics
- Event search/replay functionality
