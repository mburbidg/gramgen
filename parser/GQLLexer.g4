lexer grammar GQLLexer;

options { caseInsensitive = true; }

LITERAL
   : SIGNED_NUMERIC_LITERAL
   | GENERAL_LITERAL
   ;

GENERAL_LITERAL
   : PREDEFINED_TYPE_LITERAL
   | LIST_LITERAL
   | RECORD_LITERAL
   ;

PREDEFINED_TYPE_LITERAL
   : BOOLEAN_LITERAL
   | CHARACTER_STRING_LITERAL
   | BYTE_STRING_LITERAL
   | TEMPORAL_LITERAL
   | DURATION_LITERAL
   | NULL_LITERAL
   ;

UNSIGNED_LITERAL
   : UNSIGNED_NUMERIC_LITERAL
   | GENERAL_LITERAL
   ;

BOOLEAN_LITERAL
   : 'TRUE'
   | 'FALSE'
   | 'UNKNOWN'
   ;

CHARACTER_STRING_LITERAL
   : SINGLE_QUOTED_CHARACTER_SEQUENCE
   | DOUBLE_QUOTED_CHARACTER_SEQUENCE
   ;

UNBROKEN_CHARACTER_STRING_LITERAL
   : NO_ESCAPE? UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE
   | NO_ESCAPE? UNBROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE
   ;

SINGLE_QUOTED_CHARACTER_SEQUENCE
   : NO_ESCAPE? UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE
   ;

DOUBLE_QUOTED_CHARACTER_SEQUENCE
   : NO_ESCAPE? UNBROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE
   ;

ACCENT_QUOTED_CHARACTER_SEQUENCE
   : NO_ESCAPE? UNBROKEN_ACCENT_QUOTED_CHARACTER_SEQUENCE
   ;

NO_ESCAPE
   : COMMERCIAL_AT
   ;

UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE
   : QUOTE SINGLE_QUOTED_CHARACTER_REPRESENTATION* QUOTE
   ;

UNBROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE
   : DOUBLE_QUOTE DOUBLE_QUOTED_CHARACTER_REPRESENTATION* DOUBLE_QUOTE
   ;

UNBROKEN_ACCENT_QUOTED_CHARACTER_SEQUENCE
   : GRAVE_ACCENT ACCENT_QUOTED_CHARACTER_REPRESENTATION* GRAVE_ACCENT
   ;


SINGLE_QUOTED_CHARACTER_REPRESENTATION
	: SingleQuotedCharacter*
	;


DOUBLE_QUOTED_CHARACTER_REPRESENTATION
	: DoubleQuotedCharacter*
	;


ACCENT_QUOTED_CHARACTER_REPRESENTATION
	: AccentQuotedCharacter*
	;

CHARACTER_REPRESENTATION
   : 
   ;

DOUBLE_SINGLE_QUOTE
   : QUOTE QUOTE
   ;

DOUBLE_DOUBLE_QUOTE
   : DOUBLE_QUOTE DOUBLE_QUOTE
   ;

DOUBLE_GRAVE_ACCENT
   : GRAVE_ACCENT GRAVE_ACCENT
   ;


STRING_LITERAL_CHARACTER
	:
	;

ESCAPED_CHARACTER
   : ESCAPED_REVERSE_SOLIDUS
   | ESCAPED_QUOTE
   | ESCAPED_DOUBLE_QUOTE
   | ESCAPED_GRAVE_ACCENT
   | ESCAPED_TAB
   | ESCAPED_BACKSPACE
   | ESCAPED_NEWLINE
   | ESCAPED_CARRIAGE_RETURN
   | ESCAPED_FORM_FEED
   | UNICODE_ESCAPE_VALUE
   ;

ESCAPED_REVERSE_SOLIDUS
   : REVERSE_SOLIDUS REVERSE_SOLIDUS
   ;

ESCAPED_QUOTE
   : REVERSE_SOLIDUS QUOTE
   ;

ESCAPED_DOUBLE_QUOTE
   : REVERSE_SOLIDUS DOUBLE_QUOTE
   ;

ESCAPED_GRAVE_ACCENT
   : REVERSE_SOLIDUS GRAVE_ACCENT
   ;

ESCAPED_TAB
   : REVERSE_SOLIDUS 't'
   ;

ESCAPED_BACKSPACE
   : REVERSE_SOLIDUS 'b'
   ;

ESCAPED_NEWLINE
   : REVERSE_SOLIDUS 'n'
   ;

ESCAPED_CARRIAGE_RETURN
   : REVERSE_SOLIDUS 'r'
   ;

ESCAPED_FORM_FEED
   : REVERSE_SOLIDUS 'f'
   ;

UNICODE_ESCAPE_VALUE
   : UNICODE_4_DIGIT_ESCAPE_VALUE
   | UNICODE_6_DIGIT_ESCAPE_VALUE
   ;

UNICODE_4_DIGIT_ESCAPE_VALUE
   : REVERSE_SOLIDUS 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
   ;

UNICODE_6_DIGIT_ESCAPE_VALUE
   : REVERSE_SOLIDUS 'U' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
   ;

BYTE_STRING_LITERAL
   : 'X' QUOTE SPACE* (HEX_DIGIT SPACE* HEX_DIGIT SPACE*)* QUOTE (SEPARATOR QUOTE SPACE* (HEX_DIGIT SPACE* HEX_DIGIT SPACE*)* QUOTE)*
   ;

SIGNED_NUMERIC_LITERAL
   : SIGN? UNSIGNED_NUMERIC_LITERAL
   ;

UNSIGNED_NUMERIC_LITERAL
   : EXACT_NUMERIC_LITERAL
   | APPROXIMATE_NUMERIC_LITERAL
   ;

EXACT_NUMERIC_LITERAL
   : UNSIGNED_INTEGER
   | UNSIGNED_DECIMAL_IN_COMMON_NOTATION EXACT_NUMBER_SUFFIX?
   | UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION EXACT_NUMBER_SUFFIX
   | UNSIGNED_DECIMAL_INTEGER EXACT_NUMBER_SUFFIX?
   ;

APPROXIMATE_NUMERIC_LITERAL
   : UNSIGNED_DECIMAL_IN_COMMON_NOTATION APPROXIMATE_NUMBER_SUFFIX
   | UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION APPROXIMATE_NUMBER_SUFFIX?
   | UNSIGNED_DECIMAL_INTEGER APPROXIMATE_NUMBER_SUFFIX
   ;

EXACT_NUMBER_SUFFIX
   : 'M'
   ;

APPROXIMATE_NUMBER_SUFFIX
   : 'F'
   | 'D'
   ;

SIGN
   : PLUS_SIGN
   | MINUS_SIGN
   ;

UNSIGNED_INTEGER
   : UNSIGNED_DECIMAL_INTEGER
   | UNSIGNED_HEXADECIMAL_INTEGER
   | UNSIGNED_OCTAL_INTEGER
   | UNSIGNED_BINARY_INTEGER
   ;

UNSIGNED_DECIMAL_IN_COMMON_NOTATION
   : UNSIGNED_DECIMAL_INTEGER ( (PERIOD UNSIGNED_DECIMAL_INTEGER?)?)
   | PERIOD UNSIGNED_DECIMAL_INTEGER
   ;

UNSIGNED_DECIMAL_INTEGER
   : DIGIT ( UNDERSCORE? DIGIT)*
   ;

UNSIGNED_HEXADECIMAL_INTEGER
   : '0x' ( UNDERSCORE? HEX_DIGIT)+
   ;

UNSIGNED_OCTAL_INTEGER
   : '0o' ( UNDERSCORE? OCTAL_DIGIT)+
   ;

UNSIGNED_BINARY_INTEGER
   : '0b' ( UNDERSCORE? BINARY_DIGIT)+
   ;

SIGNED_DECIMAL_INTEGER
   : SIGN? UNSIGNED_DECIMAL_INTEGER
   ;

UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION
   : MANTISSA 'E' EXPONENT
   ;

MANTISSA
   : EXACT_NUMERIC_LITERAL
   ;

EXPONENT
   : SIGNED_DECIMAL_INTEGER
   ;

TEMPORAL_LITERAL
   : DATE_LITERAL
   | TIME_LITERAL
   | DATETIME_LITERAL
   | SQL_DATETIME_LITERAL
   ;

DATE_LITERAL
   : 'DATE' DATE_STRING
   ;

TIME_LITERAL
   : 'TIME' TIME_STRING
   ;

DATETIME_LITERAL
   : ('DATETIME' | 'TIMESTAMP') DATETIME_STRING
   ;

DATE_STRING
   : UNBROKEN_CHARACTER_STRING_LITERAL
   ;

TIME_STRING
   : UNBROKEN_CHARACTER_STRING_LITERAL
   ;

DATETIME_STRING
   : UNBROKEN_CHARACTER_STRING_LITERAL
   ;

SQL_DATETIME_LITERAL
   : 
   ;

DURATION_LITERAL
   : 'DURATION' DURATION_STRING
   | SQL_INTERVAL_LITERAL
   ;

DURATION_STRING
   : UNBROKEN_CHARACTER_STRING_LITERAL
   ;

SQL_INTERVAL_LITERAL
   : 
   ;

NULL_LITERAL
   : 'NULL'
   ;

LIST_LITERAL
   : LIST_VALUE_CONSTRUCTOR_BY_ENUMERATION
   ;

RECORD_LITERAL
   : RECORD_VALUE_CONSTRUCTOR
   ;

OBJECT_NAME
   : IDENTIFIER
   ;

OBJECT_NAME_OR_BINDING_VARIABLE
   : REGULAR_IDENTIFIER
   ;

DIRECTORY_NAME
   : IDENTIFIER
   ;

SCHEMA_NAME
   : IDENTIFIER
   ;

GRAPH_NAME
   : REGULAR_IDENTIFIER
   | DELIMITED_GRAPH_NAME
   ;

DELIMITED_GRAPH_NAME
   : DELIMITED_IDENTIFIER
   ;

GRAPH_TYPE_NAME
   : IDENTIFIER
   ;

ELEMENT_TYPE_NAME
   : IDENTIFIER
   ;

BINDING_TABLE_NAME
   : REGULAR_IDENTIFIER
   | DELIMITED_BINDING_TABLE_NAME
   ;

DELIMITED_BINDING_TABLE_NAME
   : DELIMITED_IDENTIFIER
   ;

PROCEDURE_NAME
   : IDENTIFIER
   ;

LABEL_NAME
   : IDENTIFIER
   ;

PROPERTY_NAME
   : IDENTIFIER
   ;

FIELD_NAME
   : IDENTIFIER
   ;

PARAMETER_NAME
   : DOLLAR_SIGN SEPARATED_IDENTIFIER
   ;

VARIABLE
   : GRAPH_VARIABLE
   | GRAPH_PATTERN_VARIABLE
   | BINDING_TABLE_VARIABLE
   | VALUE_VARIABLE
   | BINDING_VARIABLE
   ;

GRAPH_VARIABLE
   : BINDING_VARIABLE
   ;

GRAPH_PATTERN_VARIABLE
   : ELEMENT_VARIABLE
   | PATH_OR_SUBPATH_VARIABLE
   ;

PATH_OR_SUBPATH_VARIABLE
   : PATH_VARIABLE
   | SUBPATH_VARIABLE
   ;

ELEMENT_VARIABLE
   : BINDING_VARIABLE
   ;

PATH_VARIABLE
   : BINDING_VARIABLE
   ;

SUBPATH_VARIABLE
   : REGULAR_IDENTIFIER
   ;

BINDING_TABLE_VARIABLE
   : BINDING_VARIABLE
   ;

VALUE_VARIABLE
   : BINDING_VARIABLE
   ;

BINDING_VARIABLE
   : REGULAR_IDENTIFIER
   ;

TOKEN
   : NON_DELIMITER_TOKEN
   | DELIMITER_TOKEN
   ;

NON_DELIMITER_TOKEN
   : REGULAR_IDENTIFIER
   | PARAMETER_NAME
   | KEY_WORD
   | UNSIGNED_NUMERIC_LITERAL
   | BYTE_STRING_LITERAL
   | MULTISET_ALTERNATION_OPERATOR
   ;

IDENTIFIER
   : REGULAR_IDENTIFIER
   | DELIMITED_IDENTIFIER
   ;

SEPARATED_IDENTIFIER
   : EXTENDED_IDENTIFIER
   | DELIMITED_IDENTIFIER
   ;

NON_DELIMITED_IDENTIFIER
   : REGULAR_IDENTIFIER
   | EXTENDED_IDENTIFIER
   ;

REGULAR_IDENTIFIER
   : IDENTIFIER_START IDENTIFIER_EXTEND*
   ;

EXTENDED_IDENTIFIER
   : IDENTIFIER_EXTEND+
   ;

DELIMITED_IDENTIFIER
   : DOUBLE_QUOTED_CHARACTER_SEQUENCE
   | ACCENT_QUOTED_CHARACTER_SEQUENCE
   ;


IDENTIFIER_START
	: ID_Start
	| Pc
	;


IDENTIFIER_EXTEND
	: ID_Continue
	| Sc
	;

KEY_WORD
   : RESERVED_WORD
   | NON_RESERVED_WORD
   ;

RESERVED_WORD
   : PRE_RESERVED_WORD
   | 'ABS'
   | 'ACOS'
   | 'ALL'
   | 'ALL_DIFFERENT'
   | 'AND'
   | 'ANY'
   | 'ARRAY'
   | 'AS'
   | 'ASC'
   | 'ASCENDING'
   | 'ASIN'
   | 'AT'
   | 'ATAN'
   | 'AVG'
   | 'BIG'
   | 'BIGINT'
   | 'BINARY'
   | 'BOOL'
   | 'BOOLEAN'
   | 'BOTH'
   | 'BTRIM'
   | 'BY'
   | 'BYTE_LENGTH'
   | 'BYTES'
   | 'CALL'
   | 'CASE'
   | 'CAST'
   | 'CEIL'
   | 'CEILING'
   | 'CHAR_LENGTH'
   | 'CHARACTER_LENGTH'
   | 'CHARACTERISTICS'
   | 'CLOSE'
   | 'COALESCE'
   | 'COLLECT_LIST'
   | 'COMMIT'
   | 'COPY'
   | 'COS'
   | 'COSH'
   | 'COT'
   | 'COUNT'
   | 'CREATE'
   | 'CURRENT_DATE'
   | 'CURRENT_GRAPH'
   | 'CURRENT_PROPERTY_GRAPH'
   | 'CURRENT_SCHEMA'
   | 'CURRENT_TIME'
   | 'CURRENT_TIMESTAMP'
   | 'CURRENT_USER'
   | 'DATE'
   | 'DATETIME'
   | 'DAY'
   | 'DEC'
   | 'DECIMAL'
   | 'DEGREES'
   | 'DELETE'
   | 'DESC'
   | 'DESCENDING'
   | 'DETACH'
   | 'DISTINCT'
   | 'DOUBLE'
   | 'DROP'
   | 'DURATION'
   | 'DURATION_BETWEEN'
   | 'ELEMENT_ID'
   | 'ELSE'
   | 'END'
   | 'EXCEPT'
   | 'EXISTS'
   | 'EXP'
   | 'FALSE'
   | 'FILTER'
   | 'FINISH'
   | 'FLOAT'
   | 'FLOAT16'
   | 'FLOAT32'
   | 'FLOAT64'
   | 'FLOAT128'
   | 'FLOAT256'
   | 'FLOOR'
   | 'FOR'
   | 'FROM'
   | 'GROUP'
   | 'HAVING'
   | 'HOME_GRAPH'
   | 'HOME_PROPERTY_GRAPH'
   | 'HOME_SCHEMA'
   | 'HOUR'
   | 'IF'
   | 'IN'
   | 'INSERT'
   | 'INT'
   | 'INTEGER'
   | 'INT8'
   | 'INTEGER8'
   | 'INT16'
   | 'INTEGER16'
   | 'INT32'
   | 'INTEGER32'
   | 'INT64'
   | 'INTEGER64'
   | 'INT128'
   | 'INTEGER128'
   | 'INT256'
   | 'INTEGER256'
   | 'INTERSECT'
   | 'INTERVAL'
   | 'IS'
   | 'LEADING'
   | 'LEFT'
   | 'LET'
   | 'LIKE'
   | 'LIMIT'
   | 'LIST'
   | 'LN'
   | 'LOCAL'
   | 'LOCAL_DATETIME'
   | 'LOCAL_TIME'
   | 'LOCAL_TIMESTAMP'
   | 'LOG'
   | 'LOG10'
   | 'LOWER'
   | 'LTRIM'
   | 'MATCH'
   | 'MAX'
   | 'MIN'
   | 'MINUTE'
   | 'MOD'
   | 'MONTH'
   | 'NEXT'
   | 'NODETACH'
   | 'NORMALIZE'
   | 'NOT'
   | 'NULL'
   | 'NULLS'
   | 'NULLIF'
   | 'OCTET_LENGTH'
   | 'OF'
   | 'OFFSET'
   | 'OPTIONAL'
   | 'OR'
   | 'ORDER'
   | 'OTHERWISE'
   | 'PARAMETER'
   | 'PARAMETERS'
   | 'PATH'
   | 'PATH_LENGTH'
   | 'PATHS'
   | 'PERCENTILE_CONT'
   | 'PERCENTILE_DISC'
   | 'POWER'
   | 'PRECISION'
   | 'PROPERTY_EXISTS'
   | 'RADIANS'
   | 'REAL'
   | 'RECORD'
   | 'REMOVE'
   | 'REPLACE'
   | 'RESET'
   | 'RETURN'
   | 'RIGHT'
   | 'ROLLBACK'
   | 'RTRIM'
   | 'SAME'
   | 'SCHEMA'
   | 'SECOND'
   | 'SELECT'
   | 'SESSION'
   | 'SET'
   | 'SIGNED'
   | 'SIN'
   | 'SINH'
   | 'SKIP'
   | 'SMALL'
   | 'SMALLINT'
   | 'SQRT'
   | 'START'
   | 'STDDEV_POP'
   | 'STDDEV_SAMP'
   | 'STRING'
   | 'SUM'
   | 'TAN'
   | 'TANH'
   | 'THEN'
   | 'TIME'
   | 'TIMESTAMP'
   | 'TRAILING'
   | 'TRIM'
   | 'TRUE'
   | 'TYPED'
   | 'UBIGINT'
   | 'UINT'
   | 'UINT8'
   | 'UINT16'
   | 'UINT32'
   | 'UINT64'
   | 'UINT128'
   | 'UINT256'
   | 'UNION'
   | 'UNKNOWN'
   | 'UNSIGNED'
   | 'UPPER'
   | 'USE'
   | 'USMALLINT'
   | 'VALUE'
   | 'VARBINARY'
   | 'VARCHAR'
   | 'VARIABLE'
   | 'WHEN'
   | 'WHERE'
   | 'WITH'
   | 'XOR'
   | 'YEAR'
   | 'YIELD'
   | 'ZONED'
   | 'ZONED_DATETIME'
   | 'ZONED_TIME'
   ;

PRE_RESERVED_WORD
   : 'AGGREGATE'
   | 'AGGREGATES'
   | 'ALTER'
   | 'CATALOG'
   | 'CLEAR'
   | 'CLONE'
   | 'CONSTRAINT'
   | 'CURRENT_ROLE'
   | 'DATA'
   | 'DIRECTORY'
   | 'EXACT'
   | 'EXISTING'
   | 'FUNCTION'
   | 'GQLSTATUS'
   | 'GRANT'
   | 'INSTANT'
   | 'NOTHING'
   | 'NUMERIC'
   | 'ON'
   | 'OPEN'
   | 'PARTITION'
   | 'PROCEDURE'
   | 'PRODUCT'
   | 'PROJECT'
   | 'QUERY'
   | 'RECORDS'
   | 'REFERENCE'
   | 'RENAME'
   | 'REVOKE'
   | 'SUBSTRING'
   | 'TEMPORAL'
   | 'UNIQUE'
   | 'UNIT'
   | 'VALUES'
   ;

NON_RESERVED_WORD
   : 'ACYCLIC'
   | 'BINDING'
   | 'BINDINGS'
   | 'CONNECTING'
   | 'DESTINATION'
   | 'DIFFERENT'
   | 'DIRECTED'
   | 'EDGE'
   | 'EDGES'
   | 'ELEMENT'
   | 'ELEMENTS'
   | 'FIRST'
   | 'GRAPH'
   | 'GROUPS'
   | 'KEEP'
   | 'LABEL'
   | 'LABELED'
   | 'LABELS'
   | 'LAST'
   | 'NFC'
   | 'NFD'
   | 'NFKC'
   | 'NFKD'
   | 'NO'
   | 'NODE'
   | 'NORMALIZED'
   | 'ONLY'
   | 'ORDINALITY'
   | 'PROPERTY'
   | 'READ'
   | 'RELATIONSHIP'
   | 'RELATIONSHIPS'
   | 'REPEATABLE'
   | 'SHORTEST'
   | 'SIMPLE'
   | 'SOURCE'
   | 'TABLE'
   | 'TEMP'
   | 'TO'
   | 'TRAIL'
   | 'TRANSACTION'
   | 'TYPE'
   | 'UNDIRECTED'
   | 'VERTEX'
   | 'WALK'
   | 'WITHOUT'
   | 'WRITE'
   | 'ZONE'
   ;

MULTISET_ALTERNATION_OPERATOR
   : '|+|'
   ;

DELIMITER_TOKEN
   : GQL_SPECIAL_CHARACTER
   | BRACKET_RIGHT_ARROW
   | BRACKET_TILDE_RIGHT_ARROW
   | CHARACTER_STRING_LITERAL
   | CONCATENATION_OPERATOR
   | DATE_STRING
   | DATETIME_STRING
   | DELIMITED_IDENTIFIER
   | DOUBLE_COLON
   | DOUBLE_MINUS_SIGN
   | DOUBLE_PERIOD
   | DURATION_STRING
   | GREATER_THAN_OPERATOR
   | GREATER_THAN_OR_EQUALS_OPERATOR
   | LEFT_ARROW
   | LEFT_ARROW_BRACKET
   | LEFT_ARROW_TILDE
   | LEFT_ARROW_TILDE_BRACKET
   | LEFT_MINUS_RIGHT
   | LEFT_MINUS_SLASH
   | LEFT_TILDE_SLASH
   | LESS_THAN_OPERATOR
   | LESS_THAN_OR_EQUALS_OPERATOR
   | MINUS_LEFT_BRACKET
   | MINUS_SLASH
   | NOT_EQUALS_OPERATOR
   | RIGHT_ARROW
   | RIGHT_BRACKET_MINUS
   | RIGHT_BRACKET_TILDE
   | SLASH_MINUS
   | SLASH_MINUS_RIGHT
   | SLASH_TILDE
   | SLASH_TILDE_RIGHT
   | TILDE_LEFT_BRACKET
   | TILDE_RIGHT_ARROW
   | TILDE_SLASH
   | TIME_STRING
   ;

BRACKET_RIGHT_ARROW
   : ']->'
   ;

BRACKET_TILDE_RIGHT_ARROW
   : ']~>'
   ;

CONCATENATION_OPERATOR
   : '||'
   ;

DOUBLE_COLON
   : '::'
   ;

DOUBLE_MINUS_SIGN
   : '--'
   ;

DOUBLE_PERIOD
   : '..'
   ;

GREATER_THAN_OPERATOR
   : RIGHT_ANGLE_BRACKET
   ;

GREATER_THAN_OR_EQUALS_OPERATOR
   : '>='
   ;

LEFT_ARROW
   : '<-'
   ;

LEFT_ARROW_TILDE
   : '<~'
   ;

LEFT_ARROW_BRACKET
   : '<-['
   ;

LEFT_ARROW_TILDE_BRACKET
   : '<~['
   ;

LEFT_MINUS_RIGHT
   : '<->'
   ;

LEFT_MINUS_SLASH
   : '<-/'
   ;

LEFT_TILDE_SLASH
   : '<~/'
   ;

LESS_THAN_OPERATOR
   : LEFT_ANGLE_BRACKET
   ;

LESS_THAN_OR_EQUALS_OPERATOR
   : '<='
   ;

MINUS_LEFT_BRACKET
   : '-['
   ;

MINUS_SLASH
   : '-/'
   ;

NOT_EQUALS_OPERATOR
   : '<>'
   ;

RIGHT_ARROW
   : '->'
   ;

RIGHT_BRACKET_MINUS
   : ']-'
   ;

RIGHT_BRACKET_TILDE
   : ']~'
   ;

SLASH_MINUS
   : '/-'
   ;

SLASH_MINUS_RIGHT
   : '/->'
   ;

SLASH_TILDE
   : '/~'
   ;

SLASH_TILDE_RIGHT
   : '/~>'
   ;

TILDE_LEFT_BRACKET
   : '~['
   ;

TILDE_RIGHT_ARROW
   : '~>'
   ;

TILDE_SLASH
   : '~/'
   ;

DOUBLE_SOLIDUS
   : '//'
   ;

SEPARATOR
   : (COMMENT | WHITESPACE)+
   ;


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


BIDIRECTIONAL_CONTROL_CHARACTER
	: '\u202a'
	;

COMMENT
   : SIMPLE_COMMENT
   | BRACKETED_COMMENT
   ;


SIMPLE_COMMENT
	: '//' .*? [\n\r]
	;

SIMPLE_COMMENT_INTRODUCER
   : DOUBLE_SOLIDUS
   | DOUBLE_MINUS_SIGN
   ;

SIMPLE_COMMENT_CHARACTER
   : 
   ;


BRACKETED_COMMENT
	: '/*' .*? '*/'
	;

BRACKETED_COMMENT_INTRODUCER
   : '/*'
   ;

BRACKETED_COMMENT_TERMINATOR
   : '*/'
   ;

BRACKETED_COMMENT_CONTENTS
   : 
   ;


NEWLINE
	: [\n\r]
	;

EDGE_SYNONYM
   : 'EDGE'
   | 'RELATIONSHIP'
   ;

EDGES_SYNONYM
   : 'EDGES'
   | 'RELATIONSHIPS'
   ;

NODE_SYNONYM
   : 'NODE'
   | 'VERTEX'
   ;

GQL_TERMINAL_CHARACTER
   : GQL_LANGUAGE_CHARACTER
   | OTHER_LANGUAGE_CHARACTER
   ;

GQL_LANGUAGE_CHARACTER
   : SIMPLE_LATIN_LETTER
   | DIGIT
   | GQL_SPECIAL_CHARACTER
   ;

SIMPLE_LATIN_LETTER
   : SIMPLE_LATIN_LOWER_CASE_LETTER
   | SIMPLE_LATIN_UPPER_CASE_LETTER
   ;

SIMPLE_LATIN_LOWER_CASE_LETTER
   : 'a'
   | 'b'
   | 'c'
   | 'd'
   | 'e'
   | 'f'
   | 'g'
   | 'h'
   | 'i'
   | 'j'
   | 'k'
   | 'l'
   | 'm'
   | 'n'
   | 'o'
   | 'p'
   | 'q'
   | 'r'
   | 's'
   | 't'
   | 'u'
   | 'v'
   | 'w'
   | 'x'
   | 'y'
   | 'z'
   ;

SIMPLE_LATIN_UPPER_CASE_LETTER
   : 'A'
   | 'B'
   | 'C'
   | 'D'
   | 'E'
   | 'F'
   | 'G'
   | 'H'
   | 'I'
   | 'J'
   | 'K'
   | 'L'
   | 'M'
   | 'N'
   | 'O'
   | 'P'
   | 'Q'
   | 'R'
   | 'S'
   | 'T'
   | 'U'
   | 'V'
   | 'W'
   | 'X'
   | 'Y'
   | 'Z'
   ;

HEX_DIGIT
   : STANDARD_DIGIT
   | 'A'
   | 'B'
   | 'C'
   | 'D'
   | 'E'
   | 'F'
   | 'a'
   | 'b'
   | 'c'
   | 'd'
   | 'e'
   | 'f'
   ;

DIGIT
   : STANDARD_DIGIT
   | OTHER_DIGIT
   ;

STANDARD_DIGIT
   : OCTAL_DIGIT
   | '8'
   | '9'
   ;

OCTAL_DIGIT
   : BINARY_DIGIT
   | '2'
   | '3'
   | '4'
   | '5'
   | '6'
   | '7'
   ;

BINARY_DIGIT
   : '0'
   | '1'
   ;


OTHER_DIGIT
	:
	;

GQL_SPECIAL_CHARACTER
   : SPACE
   | AMPERSAND
   | ASTERISK
   | COLON
   | EQUALS_OPERATOR
   | COMMA
   | COMMERCIAL_AT
   | DOLLAR_SIGN
   | DOUBLE_QUOTE
   | EXCLAMATION_MARK
   | GRAVE_ACCENT
   | RIGHT_ANGLE_BRACKET
   | LEFT_BRACE
   | LEFT_BRACKET
   | LEFT_PAREN
   | LEFT_ANGLE_BRACKET
   | MINUS_SIGN
   | PERIOD
   | PLUS_SIGN
   | QUESTION_MARK
   | QUOTE
   | REVERSE_SOLIDUS
   | RIGHT_BRACE
   | RIGHT_BRACKET
   | RIGHT_PAREN
   | SEMICOLON
   | SOLIDUS
   | UNDERSCORE
   | VERTICAL_BAR
   | PERCENT
   | CIRCUMFLEX
   | TILDE
   ;

SPACE
   : ' '
   ;

AMPERSAND
   : '&'
   ;

ASTERISK
   : '*'
   ;

CIRCUMFLEX
   : '^'
   ;

COLON
   : ':'
   ;

COMMA
   : ','
   ;

COMMERCIAL_AT
   : '@'
   ;

DOLLAR_SIGN
   : '$'
   ;

DOUBLE_QUOTE
   : '"'
   ;

EQUALS_OPERATOR
   : '='
   ;

EXCLAMATION_MARK
   : '!'
   ;

RIGHT_ANGLE_BRACKET
   : '>'
   ;

GRAVE_ACCENT
   : '`'
   ;

LEFT_BRACE
   : '{'
   ;

LEFT_BRACKET
   : '['
   ;

LEFT_PAREN
   : '('
   ;

LEFT_ANGLE_BRACKET
   : '<'
   ;

MINUS_SIGN
   : '-'
   ;

PERCENT
   : '%'
   ;

PERIOD
   : '.'
   ;

PLUS_SIGN
   : '+'
   ;

QUESTION_MARK
   : '?'
   ;

QUOTE
   : '\''
   ;

REVERSE_SOLIDUS
   : '\\'
   ;

RIGHT_BRACE
   : '}'
   ;

RIGHT_BRACKET
   : ']'
   ;

RIGHT_PAREN
   : ')'
   ;

SEMICOLON
   : ';'
   ;

SOLIDUS
   : '/'
   ;

TILDE
   : '~'
   ;

UNDERSCORE
   : '_'
   ;

VERTICAL_BAR
   : '|'
   ;


OTHER_LANGUAGE_CHARACTER
	:
	;


fragment ID_Start
	: [\p{ID_Start}]
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
	: ~[`]
	;

