package main

import (
	"fmt"
	"io"
	"log"
	"strings"
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
		if _, ok := ruleExceptions[node.attr["name"]]; !skipping && !ok {
			token := gen.tokenize(node.attr["name"])
			if gen.customRule(node, w) {
				return false
			}
			builder := &strings.Builder{}
			builder.WriteString(token + "\n")
			if len(node.elem) != 1 {
				log.Fatalf("Unexpected rhs ordinality\n")
			}
			gen.rhs(node.elem[0], tokens, builder)
			builder.WriteString("\n   ;\n\n")
			fmt.Fprintf(w, "%s", builder.String())
			tokens[node.attr["name"]] = token
		}
		return false
	})
	fmt.Fprintf(w, "%s\n", commonRules)
	return tokens
}

func (gen lexerGenerator) customRule(node *node, w io.Writer) bool {
	if r, ok := customnRules[node.attr["name"]]; ok {
		fmt.Fprintf(w, "%s\n", r)
		return true
	}
	return false
}

func (gen lexerGenerator) rhs(node *node, tokens map[string]string, builder *strings.Builder) {
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
				case "terminalsymbol":
					gen.terminalSymbol(n, tokens, prefix, builder)
				case "seeTheRules":
				default:
					log.Fatalf("unhandled type: %s\n", n.name)
				}
			}
		}
	}
}

func (gen lexerGenerator) alt(nodes []*node, tokens map[string]string, prefix string, builder *strings.Builder) {
	outerPrefix := ""
	for i, a := range nodes {
		if a.name == "seeTheRules" {
			continue
		}
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
			case "terminalsymbol":
				gen.terminalSymbol(n, tokens, innerPrefix, builder)
			default:
				log.Fatalf("unhandled type: %s\n", n.name)
			}
		}
	}
}

func (gen lexerGenerator) BNF(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	builder.WriteString(prefix + gen.tokenize(node.attr["name"]))
}

func (gen lexerGenerator) kw(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	builder.WriteString(prefix + "'" + node.value + "'")
}

func (gen lexerGenerator) opt(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
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

func (gen lexerGenerator) optRepeat(node *node, tokens map[string]string, prefix string, builder *strings.Builder) bool {
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

func (gen lexerGenerator) group(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
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

func (gen lexerGenerator) terminalSymbol(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	switch v := node.value; v {
	case "'":
		builder.WriteString(prefix + "'\\" + node.value + "'")
	case "\\":
		builder.WriteString(prefix + "'\\" + node.value + "'")
	default:
		builder.WriteString(prefix + "'" + node.value + "'")
	}
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
			token := gen.tokenize(kw.value)
			fmt.Fprintf(w, "%s\n", token)
			fmt.Fprintf(w, "   : '%s'\n", token)
			fmt.Fprintf(w, "   ;\n\n")
		}
	}
}

func (gen lexerGenerator) tokenize(str string) string {
	str = strings.Replace(str, "-", " ", -1)
	return strings.Replace(strings.ToUpper(str), " ", "_", -1)
}
