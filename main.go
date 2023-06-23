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
	refs  int
}

func newNode() *node {
	return &node{
		attr: map[string]string{},
		elem: []*node{},
	}
}

type format struct {
	needColon   bool
	needNewline bool
	indentLevel int
}

// This is a list of rules that are in the lexical section of the BNF that are
// actually syntactic rules.
var ruleExceptions = map[string]bool{
	"list literal":   true,
	"record literal": true,
}

// The rules not used in parsing the GQL Language. They are metadata about the
// language used in the specification.
var metaRules = map[string]bool{
	"token":               true,
	"non delimiter token": true,
	"delimiter token":     true,
	"key word":            true,
	"reserved word":       true,
	"non reserved word":   true,
	"pre reserved word":   true,
}

func main() {
	bnf := flag.String("bnf", "", "path to an XML file containing the bnf rules for GQL")
	lexer := flag.String("lexer", "parser/GQLLexer.g4", "Path to the generated ANTLR lexer")
	parser := flag.String("parser", "parser/GQLParser.g4", "Path to the generated ANTLR parser")
	firstScannerProd := flag.String("first-scanner-prod", "boolean literal", "The first scanner production")
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
			n := newNode()
			if t, ok := s.Top(); ok {
				t.elem = append(t.elem, n)
			}
			s.Push(n)
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
	name = strings.Replace(name, "/", " ", -1)
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
