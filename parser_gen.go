package main

import (
	"fmt"
	"io"
	"log"
	"strings"
)

var parserHeader = `parser grammar GQLParser;

options { tokenVocab = GQLLexer; }

gqlRequest
   : gqlProgram SEMICOLON? EOF
   ;

`

type parserGenerator struct{}

func (gen parserGenerator) generate(root *node, firstScannerProd string, tokens map[string]string, w io.Writer) {
	fmt.Fprintf(w, "%s", parserHeader)
	visitProductions(root, func(node *node) bool {
		if node.attr["name"] == firstScannerProd {
			return true
		}
		builder := &strings.Builder{}
		builder.WriteString(formatName(node.attr["name"]) + "\n")
		if len(node.elem) != 1 {
			log.Fatalf("Unexpected rhs ordinality\n")
		}
		gen.rhs(node.elem[0], tokens, builder)
		builder.WriteString("\n   ;\n\n")
		fmt.Fprintf(w, "%s", builder.String())
		return false
	})
}

func (gen parserGenerator) rhs(node *node, tokens map[string]string, builder *strings.Builder) {
	if len(node.elem) > 0 {
		builder.WriteString("   : ")
		switch node.elem[0].name {
		case "alt":
			gen.alt(node.elem, tokens, "\n   ", builder)
		default:
			prefix := ""
			for i, n := range node.elem {
				if i > 0 {
					prefix = " "
				}
				switch n.name {
				case "BNF":
					gen.BNF(n, tokens, prefix, builder)
				case "opt":
					gen.opt(n, tokens, prefix, builder)
				case "repeat":
					builder.WriteString("+")
				case "kw":
					gen.kw(n, tokens, prefix, builder)
				case "group":
					gen.group(n, tokens, prefix, builder)
				case "seeTheRules":
					builder.WriteString(prefix + "seeTheRules")
				default:
					log.Fatalf("unhandled type: %s\n", n.name)
				}
			}
		}
	}
}

func (gen parserGenerator) alt(nodes []*node, tokens map[string]string, prefix string, builder *strings.Builder) {
	outerPrefix := ""
	for i, a := range nodes {
		if i > 0 {
			outerPrefix = prefix + "| "
		}
		builder.WriteString(outerPrefix)
		innerPrefix := ""
		for j, n := range a.elem {
			if j > 0 {
				innerPrefix = " "
			}
			switch n.name {
			case "BNF":
				gen.BNF(n, tokens, innerPrefix, builder)
			case "kw":
				gen.kw(n, tokens, innerPrefix, builder)
			case "opt":
				gen.opt(n, tokens, innerPrefix, builder)
			case "group":
				gen.group(n, tokens, " ", builder)
			case "repeat":
				builder.WriteString("+")
			default:
				log.Fatalf("unhandled type: %s\n", n.name)
			}
		}
	}
}

func (gen parserGenerator) BNF(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	if token, ok := tokens[node.attr["name"]]; ok {
		builder.WriteString(prefix + token)
	} else {
		builder.WriteString(prefix + formatName(node.attr["name"]))
	}
}

func (gen parserGenerator) kw(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	builder.WriteString(prefix + node.value)
}

func (gen parserGenerator) opt(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	if gen.optRepeat(node, tokens, prefix, builder) {
		return
	}
	builder.WriteString(prefix)
	if len(node.elem) > 1 {
		builder.WriteString("(")
	}
	switch node.elem[0].name {
	case "alt":
		gen.alt(node.elem, tokens, " ", builder)
	default:
		separator := ""
		for i, n := range node.elem {
			if i > 0 {
				separator = " "
			}
			switch n.name {
			case "BNF":
				gen.BNF(n, tokens, separator, builder)
			case "kw":
				gen.kw(n, tokens, separator, builder)
			case "opt":
				gen.opt(n, tokens, separator, builder)
			case "repeat":
				builder.WriteString("+")
			case "group":
				gen.group(n, tokens, " ", builder)
			default:
				log.Fatalf("unhandled type: %s\n", n.name)
			}
		}
	}
	if len(node.elem) > 1 {
		builder.WriteString(")")
	}
	builder.WriteString("?")
}

func (gen parserGenerator) optRepeat(node *node, tokens map[string]string, prefix string, builder *strings.Builder) bool {
	if len(node.elem) == 2 && node.elem[1].name == "repeat" {
		builder.WriteString(prefix)
		switch n := node.elem[0]; n.name {
		case "group":
			gen.group(n, tokens, "", builder)
		case "BNF":
			gen.BNF(n, tokens, "", builder)
		default:
			log.Fatalf("unhandled type: %s\n", n.name)
		}
		builder.WriteString("*")
		return true
	}
	return false
}

func (gen parserGenerator) group(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	builder.WriteString(prefix + "(")
	if len(node.elem) > 0 {
		switch node.elem[0].name {
		case "alt":
			gen.alt(node.elem, tokens, " ", builder)
		default:
			innerPrefix := ""
			for i, n := range node.elem {
				if i > 0 {
					innerPrefix = " "
				}
				switch n.name {
				case "BNF":
					gen.BNF(n, tokens, innerPrefix, builder)
				case "opt":
					gen.opt(n, tokens, " ", builder)
				default:
					log.Fatalf("unhandled type: %s\n", node.name)
				}
			}
		}
	}
	builder.WriteString(")")
}
