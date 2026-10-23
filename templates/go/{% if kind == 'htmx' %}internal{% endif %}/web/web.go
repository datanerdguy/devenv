// Package web tem o site: páginas em templates/ e o htmx em static/, embutidos no binário.
//
// As rotas que o htmx chama devolvem só o pedaço de HTML que muda (templates que começam com `_`).
package web

import (
	"bytes"
	"embed"
	"fmt"
	"html/template"
	"io/fs"
	"log/slog"
	"net/http"
	"strconv"
	"strings"
	"sync"
)

// all: inclui os templates que começam com _ (o embed pula esses por padrão).
//
//go:embed all:templates static
var files embed.FS

type app struct {
	title  string
	tmpl   *template.Template
	logger *slog.Logger

	mu    sync.Mutex
	todos []string // exemplo em memória; troque por um banco de verdade
}

// New devolve o handler do site.
func New(logger *slog.Logger, title string) (http.Handler, error) {
	tmpl, err := template.ParseFS(files, "templates/*.html")
	if err != nil {
		return nil, fmt.Errorf("lendo os templates: %w", err)
	}
	static, err := fs.Sub(files, "static")
	if err != nil {
		return nil, fmt.Errorf("lendo static/: %w", err)
	}

	a := &app{title: title, tmpl: tmpl, logger: logger}
	mux := http.NewServeMux()
	mux.Handle("GET /static/", http.StripPrefix("/static/", http.FileServerFS(static)))
	mux.HandleFunc("GET /{$}", a.index)
	mux.HandleFunc("POST /todos", a.add)
	mux.HandleFunc("DELETE /todos/{i}", a.remove)
	return mux, nil
}

func (a *app) index(w http.ResponseWriter, _ *http.Request) {
	a.render(w, "index.html", map[string]any{"Title": a.title, "Todos": a.snapshot()})
}

func (a *app) add(w http.ResponseWriter, r *http.Request) {
	if text := strings.TrimSpace(r.FormValue("text")); text != "" {
		a.mu.Lock()
		a.todos = append(a.todos, text)
		a.mu.Unlock()
	}
	a.render(w, "_todos.html", a.snapshot())
}

func (a *app) remove(w http.ResponseWriter, r *http.Request) {
	if i, err := strconv.Atoi(r.PathValue("i")); err == nil {
		a.mu.Lock()
		if i >= 0 && i < len(a.todos) {
			a.todos = append(a.todos[:i], a.todos[i+1:]...)
		}
		a.mu.Unlock()
	}
	a.render(w, "_todos.html", a.snapshot())
}

func (a *app) snapshot() []string {
	a.mu.Lock()
	defer a.mu.Unlock()
	return append([]string(nil), a.todos...)
}

// render monta a página inteira antes de escrever, para um erro no template virar um 500 limpo.
func (a *app) render(w http.ResponseWriter, name string, data any) {
	var buf bytes.Buffer
	if err := a.tmpl.ExecuteTemplate(&buf, name, data); err != nil {
		a.logger.Error("template", "name", name, "err", err)
		http.Error(w, "erro interno", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	_, _ = buf.WriteTo(w)
}
