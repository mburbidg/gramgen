package main

import (
	"fmt"
	"io"
	"log"
)

var lexerHeader = `lexer grammar GQLLexer;

options { caseInsensitive = true; }

`

type lexerGenerator struct{}

func (gen lexerGenerator) generate(root *node, firstScannerProd string, w io.Writer) map[string]string {
	fmt.Fprintf(w, "%s", lexerHeader)
	tokens := map[string]string{}
	skipping := true
	visitProductions(root, func(node *node) bool {
		if node.attr["name"] == firstScannerProd {
			skipping = false
		}
		if !skipping {
			rhs := node.elem[0]
			switch {
			case rhs.elem[0].name == "terminalsymbol":
				token := tokenize(node.attr["name"])
				tokens[node.attr["name"]] = token
				fmt.Fprintf(w, "%s\n", token)
				fmt.Fprintf(w, "   : '%s'\n", rhs.elem[0].value)
				fmt.Fprintf(w, "   ;\n\n")
			case node.attr["name"] == "reserved word":
				gen.keywords(node.elem[0], w)
			case node.attr["name"] == "pre-reserved word":
				gen.keywords(node.elem[0], w)
			case node.attr["name"] == "non-reserved word":
				gen.keywords(node.elem[0], w)
			}
		}
		return false
	})
	return tokens
}

func (gen lexerGenerator) keywords(rhs *node, w io.Writer) {
	if rhs == nil || rhs.name != "rhs" {
		log.Fatalf("expecting <rhs>, when processing keywords\n")
	}
	for _, n := range rhs.elem {
		if n.name != "alt" {
			log.Fatalf("expecting '<alt>' node when processing keyword\n")
		}
		if len(n.elem) != 1 {
			log.Fatalf("expecting 1 element node, when processing keyword\n")
		}
		if kw := n.elem[0]; kw.name == "kw" {
			token := tokenize(kw.value)
			fmt.Fprintf(w, "%s\n", token)
			fmt.Fprintf(w, "   : '%s'\n", token)
			fmt.Fprintf(w, "   ;\n\n")
		}
	}
}
