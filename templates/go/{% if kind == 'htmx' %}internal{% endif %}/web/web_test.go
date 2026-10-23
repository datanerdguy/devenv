package web

import (
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
)

func newHandler(t *testing.T) http.Handler {
	t.Helper()
	h, err := New(slog.New(slog.NewTextHandler(io.Discard, nil)), "teste")
	if err != nil {
		t.Fatal(err)
	}
	return h
}

func do(h http.Handler, req *http.Request) *httptest.ResponseRecorder {
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func TestIndex(t *testing.T) {
	rec := do(newHandler(t), httptest.NewRequest(http.MethodGet, "/", nil))
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), "htmx.min.js") {
		t.Fatalf("GET / = %d\n%s", rec.Code, rec.Body)
	}
}

func TestAddAndRemove(t *testing.T) {
	h := newHandler(t)
	form := url.Values{"text": {"comprar café"}}
	req := httptest.NewRequest(http.MethodPost, "/todos", strings.NewReader(form.Encode()))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	body := do(h, req).Body.String()
	if !strings.Contains(body, "comprar café") || strings.Contains(body, "<html") {
		t.Fatalf("POST /todos devolveu:\n%s", body)
	}
	body = do(h, httptest.NewRequest(http.MethodDelete, "/todos/0", nil)).Body.String()
	if strings.Contains(body, "comprar café") {
		t.Fatalf("DELETE /todos/0 não removeu:\n%s", body)
	}
}

func TestStatic(t *testing.T) {
	rec := do(newHandler(t), httptest.NewRequest(http.MethodGet, "/static/htmx.min.js", nil))
	if rec.Code != http.StatusOK {
		t.Fatalf("GET /static/htmx.min.js = %d", rec.Code)
	}
}
