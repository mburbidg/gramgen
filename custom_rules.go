package main

var customnRules = map[string]string{
	"single quoted character representation": `
SINGLE_QUOTED_CHARACTER_REPRESENTATION
	: SingleQuotedCharacter*
	;
`,
	"double quoted character representation": `
DOUBLE_QUOTED_CHARACTER_REPRESENTATION
	: DoubleQuotedCharacter*
	;
`,
	"accent quoted character representation": `
ACCENT_QUOTED_CHARACTER_REPRESENTATION
	: AccentQuotedCharacter*
	;
`,
	"string literal character": `
STRING_LITERAL_CHARACTER
	:
	;
`,
	"identifier start": `
IDENTIFIER_START
	: ID_Start
	| Pc
	;
`,
	"identifier extend": `
IDENTIFIER_EXTEND
	: ID_Continue
	| Sc
	;
`,
	"whitespace": `
WHITESPACE
   : SPACE
   | TAB
   | LF
   | VT
   | FF
   | CR
   | FS
   | GS
   | RS
   | US
   | '\u1680'
   | '\u180e'
   | '\u2000'
   | '\u2001'
   | '\u2002'
   | '\u2003'
   | '\u2004'
   | '\u2005'
   | '\u2006'
   | '\u2008'
   | '\u2009'
   | '\u200a'
   | '\u2028'
   | '\u2029'
   | '\u205f'
   | '\u3000'
   | '\u00a0'
   | '\u2007'
   | '\u202f'
	;
`,
	"bidirectional control character": `
BIDIRECTIONAL_CONTROL_CHARACTER
	: '\u202a'
	;
`,
	"simple comment": `
SIMPLE_COMMENT
	: '//' .*? [\n\r]
	;
`,
	"bracketed comment": `
BRACKETED_COMMENT
	: '/*' .*? '*/'
	;
`,
	"newline": `
NEWLINE
	: [\n\r]
	;
`,
	"other digit": `
OTHER_DIGIT
	:
	;
`,
	"other language character": `
OTHER_LANGUAGE_CHARACTER
	:
	;
`,
	"space": `
SPACE
	: ' '
	;
`,
}

var commonRules = `
fragment ID_Start
	: [\p{ID_Start}]
	;

fragment ID_Continue
	: [\p{ID_Continue}]
	;

fragment Sc
   : [\p{Sc}]
   ;

fragment Pc
   : [\p{Pc}]
   ;

fragment SingleQuotedCharacter
	: ~[']
	; 

fragment DoubleQuotedCharacter
	: ~["]
	;

fragment AccentQuotedCharacter
` + "	: ~[`]" + `
	;

fragment FF
   : [\f]
   ;

fragment RS
   : [\u001E]
   ;

fragment GS
   : [\u001D]
   ;

fragment FS
   : [\u001C]
   ;

fragment CR
   : [\r]
   ;

fragment TAB
   : [\t]
   ;

fragment LF
   : [\n]
   ;

fragment VT
   : [\u000B]
   ;

fragment US
   : [\u001F]
   ;
`
