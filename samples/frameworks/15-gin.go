// Package main demonstrates the Gin web framework.
//
// Covers routing groups, middleware, binding and validation,
// context handling, graceful shutdown and structured responses.
package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
)

// Article is the API representation of a post.
type Article struct {
	ID        int      `json:"id"`
	Title     string   `json:"title"      binding:"required,min=1,max=200"`
	Severity  string   `json:"severity"   binding:"required,oneof=debug info warning error"`
	LikeCount int      `json:"like_count" binding:"gte=0"`
	Tags      []string `json:"tags,omitempty"`
}

// ErrNotFound is returned when no article matches.
var ErrNotFound = errors.New("article not found")

// store is a concurrency-safe in-memory repository.
type store struct {
	mu    sync.RWMutex
	items map[int]Article
}

// FindByID returns one article or ErrNotFound.
func (s *store) FindByID(id int) (Article, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	article, ok := s.items[id]
	if !ok {
		return Article{}, ErrNotFound // inline comment
	}
	return article, nil
}

// requestLogger is a custom middleware.
func requestLogger(logger *slog.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		c.Next()
		logger.Info("request",
			slog.String("method", c.Request.Method),
			slog.String("path", c.FullPath()),
			slog.Int("status", c.Writer.Status()),
			slog.Duration("took", time.Since(start)),
		)
	}
}

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	repo := &store{items: map[int]Article{1: {ID: 1, Title: "hello", Severity: "info"}}}

	router := gin.New()
	router.Use(gin.Recovery(), requestLogger(logger))

	api := router.Group("/api/v1")
	{
		api.GET("/articles/:id", func(c *gin.Context) {
			var uri struct {
				ID int `uri:"id" binding:"required,min=1"`
			}
			if err := c.ShouldBindUri(&uri); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}

			article, err := repo.FindByID(uri.ID)
			switch {
			case errors.Is(err, ErrNotFound):
				c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			case err != nil:
				c.JSON(http.StatusInternalServerError, gin.H{"error": "internal"})
			default:
				c.JSON(http.StatusOK, article)
			}
		})

		api.POST("/articles", func(c *gin.Context) {
			var payload Article
			if err := c.ShouldBindJSON(&payload); err != nil {
				c.AbortWithStatusJSON(http.StatusUnprocessableEntity, gin.H{"error": err.Error()})
				return
			}
			c.JSON(http.StatusCreated, payload)
		})
	}

	srv := &http.Server{Addr: ":8080", Handler: router, ReadHeaderTimeout: 5 * time.Second}

	go func() {
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Error("listen failed", slog.Any("err", err))
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	_ = srv.Shutdown(ctx)
}
