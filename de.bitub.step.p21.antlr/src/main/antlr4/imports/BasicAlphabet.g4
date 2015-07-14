lexer grammar BasicAlphabet;

fragment
SPACE
:
	' '
;

fragment
DIGIT
:
	(
		'0' .. '9'
	)
;

fragment
LOWER
:
	(
		'a' .. 'z'
	)
;

fragment
UPPER
:
	(
		'A' .. 'Z'
		| '_'
	)
;

fragment
SPECIAL
:
	(
		'!'
		| '""'
		| '*'
		| '$'
		| '%'
		| '&'
		| '.'
		| '#'
		| '+'
		| ','
		| '-'
		| '('
		| ')'
		| '?'
		| '/'
		| ':'
		| ';'
		| '<'
		| '='
		| '>'
		| '@'
		| '['
		| ']'
		| '{'
		| '|'
		| '}'
		| '^'
		| '`'
		| '~'
	)
;

fragment
REVERSE_SOLIDUS
:
	'\\'
;

fragment
APOSTROPHE
:
	'\''
;

fragment
CHARACTER
:
	(
		SPACE
		| DIGIT
		| LOWER
		| UPPER
		| SPECIAL
		| REVERSE_SOLIDUS
		| APOSTROPHE
	)
;