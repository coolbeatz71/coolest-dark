// Package languagetour demonstrates the core Go constructs.
package languagetour

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"time"
)

// Severity describes how serious a log line is.
type Severity int

// Severity levels, declared with iota.
const (
	Debug Severity = iota
	Info
	Warning
	Error
)

// ErrNotFound is returned when no entry matches.
var ErrNotFound = errors.New("not found")

// Repository is a generic store contract.
//
// T is the stored entity type and ID the identifier type.
type Repository[T any, ID comparable] interface {
	FindByID(ctx context.Context, id ID) (T, error)
}

// LogEntry is an immutable value type.
type LogEntry struct {
	Message  string   `json:"message"`
	Severity Severity `json:"severity"`
	Tags     []string `json:"tags,omitempty"`
}

// String implements fmt.Stringer.
func (e LogEntry) String() string {
	return fmt.Sprintf("[%d] %s (%d tags)", e.Severity, e.Message, len(e.Tags))
}

// LogRepository is a concurrency-safe in-memory store.
type LogRepository struct {
	mu    sync.RWMutex
	store map[int]LogEntry
}

// FindByID looks one entry up, honouring context cancellation.
func (r *LogRepository) FindByID(ctx context.Context, id int) (LogEntry, error) {
	r.mu.RLock()
	defer r.mu.RUnlock() // inline comment

	select {
	case <-ctx.Done():
		return LogEntry{}, ctx.Err()
	case <-time.After(10 * time.Millisecond):
	}

	entry, ok := r.store[id]
	if !ok {
		return LogEntry{}, fmt.Errorf("id %d: %w", id, ErrNotFound)
	}
	return entry, nil
}

// Describe uses a switch with no condition.
func (r *LogRepository) Describe(count int, severity Severity) string {
	switch {
	case count == 0:
		return "empty"
	case severity == Error:
		return "failing"
	case count > 100:
		return "busy"
	default:
		return "ok"
	}
}
