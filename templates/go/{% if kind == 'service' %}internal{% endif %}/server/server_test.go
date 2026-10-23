package server

import (
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func do(t *testing.T, h http.Handler, method, path, body string) *httptest.ResponseRecorder {
	t.Helper()
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func TestItems(t *testing.T) {
	h := New(slog.New(slog.NewTextHandler(io.Discard, nil)))

	steps := []struct {
		method, path, body string
		want               int
	}{
		{http.MethodGet, "/health", "", http.StatusOK},
		{http.MethodPost, "/items", `{"id": 1, "name": "a"}`, http.StatusCreated},
		{http.MethodPost, "/items", `{"id": 1, "name": "a"}`, http.StatusConflict},
		{http.MethodPost, "/items", `{"id": 2}`, http.StatusBadRequest},
		{http.MethodGet, "/items/1", "", http.StatusOK},
		{http.MethodGet, "/items/2", "", http.StatusNotFound},
		{http.MethodGet, "/items/x", "", http.StatusBadRequest},
	}
	for _, s := range steps {
		if rec := do(t, h, s.method, s.path, s.body); rec.Code != s.want {
			t.Errorf("%s %s = %d, quero %d (%s)", s.method, s.path, rec.Code, s.want, rec.Body)
		}
	}

	if got := do(t, h, http.MethodGet, "/items", "").Body.String(); got != `[{"id":1,"name":"a"}]`+"\n" {
		t.Errorf("GET /items = %q", got)
	}
}
