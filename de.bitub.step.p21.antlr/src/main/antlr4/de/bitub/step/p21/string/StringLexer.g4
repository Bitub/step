lexer grammar StringLexer;

L_APOSTROPHE
:
	APOSTROPHE -> pushMode ( INSIDE_STRING )
;

mode INSIDE_STRING;

/**
 * Normal characters
 */
NON_Q_CHAR
:
	(
		SPECIAL
		| DIGIT
		| SPACE
		| LOWER
		| UPPER
	)
;

/**
 * Special characters encoding
 */
PAGE
:
	REVERSE_SOLIDUS 'S' REVERSE_SOLIDUS CHARACTER
;

ALPHABET
:
	REVERSE_SOLIDUS 'P' UPPER REVERSE_SOLIDUS
;

EXTENDED2
:
	REVERSE_SOLIDUS 'X2' REVERSE_SOLIDUS HEX_TWO
	(
		HEX_TWO
	)* END_EXTENDED
;

EXTENDED4
:
	REVERSE_SOLIDUS 'X4' REVERSE_SOLIDUS HEX_FOUR
	(
		HEX_FOUR
	)* END_EXTENDED
;

ARBITARY
:
	REVERSE_SOLIDUS 'X' REVERSE_SOLIDUS HEX_ONE
;

/**
 * fragment rules as helpers
 */
fragment
END_EXTENDED
:
	REVERSE_SOLIDUS 'X0' REVERSE_SOLIDUS
;

fragment
HEX_ONE
:
	HEX HEX
;

fragment
HEX_TWO
:
	HEX_ONE HEX_ONE
;

fragment
HEX_FOUR
:
	HEX_TWO HEX_TWO
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

fragment
HEX
:
	'0' .. '9'
	| 'A' .. 'F'
;

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

/**
 * Ending rule for inside STRING mode
 */
R_APOSTROPHE
:
	APOSTROPHE -> popMode
;
