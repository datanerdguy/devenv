package greet

import "testing"

func TestHello(t *testing.T) {
	tests := []struct {
		name, in, want string
	}{
		{"com nome", "Lucas", "Olá, Lucas!"},
		{"vazio", "", "Olá, mundo!"},
		{"só espaços", "  ", "Olá, mundo!"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Hello(tt.in); got != tt.want {
				t.Errorf("Hello(%q) = %q, quero %q", tt.in, got, tt.want)
			}
		})
	}
}
