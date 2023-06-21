package main

import (
	"bufio"
	"encoding/xml"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"reflect"
	"strings"
	"unicode"
)

type node struct {
	name  string
	attr  map[string]string
	value string
	elem  []*node
}

type format struct {
	needColon   bool
	needNewline bool
	indentLevel int
}

func main() {
	bnf := flag.String("bnf", "", "path to an XML file containing the bnf rules for GQL")
	lexer := flag.String("lexer", "GQLLexer.g4", "Path to the generated ANTLR lexer")
	parser := flag.String("parser", "GQLParser.g4", "Path to the generated ANTLR parser")
	flag.Parse()

	f, err := os.Open(*bnf)
	if err != nil {
		log.Fatalf("error opening xml: %s\n", err)
	}
	defer f.Close()
	r := bufio.NewReader(f)
	decoder := xml.NewDecoder(r)

	lexerFile, err := os.Create(*lexer)
	if err != nil {
		log.Fatalf("error opening lexer output file '%s': %s\n", *lexerFile, err)
	}
	defer lexerFile.Close()

	parserFile, err := os.Create(*parser)
	if err != nil {
		log.Fatalf("error opening parser output file '%s': %s\n", *parserFile, err)
	}
	defer parserFile.Close()

	root := buildTree(decoder)
	tokens := collectTokens(root)
	for k, v := range tokens {
		log.Printf("%s=%s\n", k, v)
	}
	generateAntlrGrammar(root, "identifier start", tokens, parserFile)
}

func buildTree(decoder *xml.Decoder) *node {
	s := NewStack[*node]()
	for token, err := decoder.Token(); err == nil; token, err = decoder.Token() {
		switch v := token.(type) {
		case xml.StartElement:
			n := &node{}
			if t, ok := s.Top(); ok {
				t.elem = append(t.elem, n)
			}
			s.Push(n)
			s.MustTop().attr = map[string]string{}
			s.MustTop().name = v.Name.Local
			for _, attr := range v.Attr {
				s.MustTop().attr[attr.Name.Local] = attr.Value
			}
		case xml.EndElement:
			n, _ := s.Pop()
			if _, ok := s.Top(); !ok {
				return n
			}
		case xml.CharData:
			if t, ok := s.Top(); ok {
				t.value = string(v.Copy())
			}
		case xml.ProcInst:
			log.Printf("xml.ProcInst not handled\n", reflect.TypeOf(v))
		default:
			log.Printf("'case %s:' not handled\n", reflect.TypeOf(v))
		}
	}
	return nil
}

func collectTokens(root *node) map[string]string {
	tokens := map[string]string{}
	visitProductions(root, func(node *node) bool {
		rhs := node.elem[0]
		if rhs.elem[0].name == "terminalsymbol" {
			tokens[node.attr["name"]] = tokenize(node.attr["name"])
		}
		return false
	})
	return tokens
}

func generateAntlrGrammar(root *node, firstScannerProduction string, tokens map[string]string, w io.Writer) {
	visitProductions(root, func(node *node) bool {
		if node.attr["name"] == firstScannerProduction {
			return true
		}
		builder := &strings.Builder{}
		builder.WriteString(formatName(node.attr["name"]) + "\n")
		if len(node.elem) != 1 {
			log.Fatalf("Unexpected rhs ordinality\n")
		}
		rhs(node.elem[0], tokens, builder)
		builder.WriteString("\n   ;\n\n")
		fmt.Fprintf(w, "%s", builder.String())
		return false
	})
}

func rhs(node *node, tokens map[string]string, builder *strings.Builder) {
	if len(node.elem) > 0 {
		builder.WriteString("   : ")
		switch node.elem[0].name {
		case "alt":
			alt(node.elem, tokens, "\n   ", builder)
		default:
			prefix := ""
			for i, n := range node.elem {
				if i > 0 {
					prefix = " "
				}
				switch n.name {
				case "BNF":
					BNF(n, tokens, prefix, builder)
				case "opt":
					opt(n, tokens, prefix, builder)
				case "repeat":
					builder.WriteString("+")
				case "kw":
					kw(n, tokens, prefix, builder)
				case "group":
					group(n, tokens, prefix, builder)
				case "seeTheRules":
					builder.WriteString(prefix + "seeTheRules")
				default:
					log.Fatalf("unhandled type: %s\n", n.name)
				}
			}
		}
	}
}

func alt(nodes []*node, tokens map[string]string, prefix string, builder *strings.Builder) {
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
				BNF(n, tokens, innerPrefix, builder)
			case "kw":
				kw(n, tokens, innerPrefix, builder)
			case "opt":
				opt(n, tokens, innerPrefix, builder)
			case "group":
				group(n, tokens, " ", builder)
			case "repeat":
				builder.WriteString("+")
			default:
				log.Fatalf("unhandled type: %s\n", n.name)
			}
		}
	}
}

func BNF(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	if token, ok := tokens[node.attr["name"]]; ok {
		builder.WriteString(prefix + token)
	} else {
		builder.WriteString(prefix + formatName(node.attr["name"]))
	}
}

func kw(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	builder.WriteString(prefix + node.value)
}

func opt(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	if optRepeat(node, tokens, prefix, builder) {
		return
	}
	builder.WriteString(prefix)
	if len(node.elem) > 1 {
		builder.WriteString("(")
	}
	switch node.elem[0].name {
	case "alt":
		alt(node.elem, tokens, " ", builder)
	default:
		separator := ""
		for i, n := range node.elem {
			if i > 0 {
				separator = " "
			}
			switch n.name {
			case "BNF":
				BNF(n, tokens, separator, builder)
			case "kw":
				kw(n, tokens, separator, builder)
			case "opt":
				opt(n, tokens, separator, builder)
			case "repeat":
				builder.WriteString("+")
			case "group":
				group(n, tokens, " ", builder)
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

func optRepeat(node *node, tokens map[string]string, prefix string, builder *strings.Builder) bool {
	if len(node.elem) == 2 && node.elem[1].name == "repeat" {
		builder.WriteString(prefix)
		switch n := node.elem[0]; n.name {
		case "group":
			group(n, tokens, "", builder)
		case "BNF":
			BNF(n, tokens, "", builder)
		default:
			log.Fatalf("unhandled type: %s\n", n.name)
		}
		builder.WriteString("*")
		return true
	}
	return false
}

func group(node *node, tokens map[string]string, prefix string, builder *strings.Builder) {
	builder.WriteString(prefix + "(")
	if len(node.elem) > 0 {
		switch node.elem[0].name {
		case "alt":
			alt(node.elem, tokens, " ", builder)
		default:
			innerPrefix := ""
			for i, n := range node.elem {
				if i > 0 {
					innerPrefix = " "
				}
				switch n.name {
				case "BNF":
					BNF(n, tokens, innerPrefix, builder)
				case "opt":
					opt(n, tokens, " ", builder)
				default:
					log.Fatalf("unhandled type: %s\n", node.name)
				}
			}
		}
	}
	builder.WriteString(")")
}

func visitProductions(root *node, visitor func(node *node) bool) {
	for _, node := range root.elem {
		done := visitor(node)
		if done {
			break
		}
	}
}

func indent(builder *strings.Builder, level int) string {
	for i := 0; i < level; i++ {
		builder.WriteString("  ")
	}
	return builder.String()
}

func formatName(name string) string {
	name = strings.Replace(name, "-", " ", -1)
	words := strings.Split(name, " ")
	builder := strings.Builder{}
	for i, w := range words {
		if i > 0 {
			builder.WriteString(capitalize(w))
		} else {
			builder.WriteString(w)
		}
	}
	return builder.String()
}

func capitalize(str string) string {
	runes := []rune(str)
	runes[0] = unicode.ToUpper(runes[0])
	return string(runes)
}

func tokenize(str string) string {
	return strings.Replace(strings.ToUpper(str), " ", "_", -1)
}

func punctuation(builder *strings.Builder, format *format) {
	if format.needNewline {
		builder.WriteString("\n")
		format.needNewline = false
	}
	indent(builder, format.indentLevel)
	if format.needColon {
		builder.WriteString(":")
		format.needColon = false
	}
}
