package main

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"go.uber.org/fx"
)

type ContentService struct{}

func NewContentService() *ContentService {
	return &ContentService{}
}

func (s *ContentService) GenerateContent() string {
	return fmt.Sprintf(`{"timestamp": "%s", "message": "This is content from the Golang backend."}`, time.Now().Format(time.RFC3339))
}

func NewHTTPServer(lc fx.Lifecycle, s *ContentService) *http.Server {
	addr := ":8081"
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprint(w, s.GenerateContent())
	})

	server := &http.Server{
		Addr:    addr,
		Handler: mux,
	}

	lc.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {
			fmt.Println("Starting HTTP server on", addr)
			go server.ListenAndServe()
			return nil
		},
		OnStop: func(ctx context.Context) error {
			fmt.Println("Stopping HTTP server.")
			return server.Shutdown(ctx)
		},
	})

	return server
}

func main() {
	fx.New(
		fx.Provide(NewContentService, NewHTTPServer),
		fx.NopLogger,
		fx.Invoke(func(*http.Server) {}),
	).Run()
}
