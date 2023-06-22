package main

import (
	"bufio"
	"encoding/xml"
	"flag"
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
	firstScannerProd := flag.String("first-scanner-prod", "literal", "The first scanner production")
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

	lexerGen := lexerGenerator{}
	tokens := lexerGen.generate(root, *firstScannerProd, lexerFile)

	parserGen := parserGenerator{}
	parserGen.generate(root, *firstScannerProd, tokens, parserFile)
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
