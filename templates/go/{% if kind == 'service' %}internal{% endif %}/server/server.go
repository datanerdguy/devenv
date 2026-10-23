// Package server tem as rotas HTTP do serviço.
package server

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"slices"
	"strconv"
	"sync"
	"time"
)

// Item é o recurso de exemplo da API.
type Item struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

// store guarda os itens em memória; troque por um banco de verdade.
type store struct {
	mu    sync.Mutex
	items map[int]Item
}

// New devolve o handler com todas as rotas.
func New(logger *slog.Logger) http.Handler {
	s := &store{items: map[int]Item{}}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})
	mux.HandleFunc("GET /items", s.list)
	mux.HandleFunc("POST /items", s.create)
	mux.HandleFunc("GET /items/{id}", s.get)
	return logRequests(logger, mux)
}

func (s *store) list(w http.ResponseWriter, _ *http.Request) {
	s.mu.Lock()
	items := make([]Item, 0, len(s.items))
	for _, it := range s.items {
		items = append(items, it)
	}
	s.mu.Unlock()
	slices.SortFunc(items, func(a, b Item) int { return a.ID - b.ID })
	writeJSON(w, http.StatusOK, items)
}

func (s *store) create(w http.ResponseWriter, r *http.Request) {
	var it Item
	if err := json.NewDecoder(r.Body).Decode(&it); err != nil || it.Name == "" {
		writeError(w, http.StatusBadRequest, "item inválido")
		return
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.items[it.ID]; ok {
		writeError(w, http.StatusConflict, "item já existe")
		return
	}
	s.items[it.ID] = it
	writeJSON(w, http.StatusCreated, it)
}

func (s *store) get(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "id inválido")
		return
	}
	s.mu.Lock()
	it, ok := s.items[id]
	s.mu.Unlock()
	if !ok {
		writeError(w, http.StatusNotFound, "item não encontrado")
		return
	}
	writeJSON(w, http.StatusOK, it)
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}

func logRequests(logger *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		logger.Info("request", "method", r.Method, "path", r.URL.Path, "dur", time.Since(start))
	})
}
