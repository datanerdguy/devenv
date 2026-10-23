// Package greet tem a lógica do programa, separada do main para ser testada.
package greet

import "strings"

// Hello devolve uma saudação para name (ou para o mundo, se vazio).
func Hello(name string) string {
	name = strings.TrimSpace(name)
	if name == "" {
		name = "mundo"
	}
	return "Olá, " + name + "!"
}
