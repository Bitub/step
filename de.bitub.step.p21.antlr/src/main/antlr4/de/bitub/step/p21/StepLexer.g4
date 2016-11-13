lexer grammar StepLexer;

@header {	
import java.util.*;

import openifctools.com.openifcjavatoolbox.stringconverter.StringConverter;
import java.nio.charset.CharacterCodingException;
}

tokens {
	FILE_DESCRIPTION,
	FILE_SCHEMA
}

@members {
Map<String,Integer> keywords = new HashMap<String,Integer>() {{
	put("FILE_DESCRIPTION", StepParser.FILE_DESCRIPTION);
	put("FILE_SCHEMA", StepParser.FILE_SCHEMA);
}};
}

// ------------ everything inside  DEFAULT mode --------------------

/** 
 * Seperators
 */
ISO_10303_21
:
	'ISO-10303-21;'
;

END_ISO_10303_21
:
	'END-ISO-10303-21;'
;

HEADER
:
	'HEADER;'
;

DATA
:
	'DATA'
;

ENDSEC
:
	'ENDSEC;'
;

/**
 * Start Tokens for HEADER_MODE
 */
USER_DEFINED_KEYWORD
:
	'!' STANDARD_KEYWORD
;

STANDARD_KEYWORD
:
	UPPER
	(
		UPPER
		| DIGIT
	)*
;

/**
 * Integer consist of an sign and any number of digits.
 * 
 * TODO:
 * 	- remove leading zeros
 *  - check if at least one digit is non-zero 
 */
INTEGER
:
	SIGN? DIGIT+
;

/**
 * Real consist of an optional sign digits and an optional exponent.
 * 
 * Example: +12.345E-5 or 12.7
 */
REAL
:
	SIGN? DIGIT+ '.' DIGIT*
	(
		'E' SIGN? DIGIT+
	)?
;

STRING
:
	APOSTROPHE (~[\r\n\'] | '\'\'')* APOSTROPHE
	{
	     String s = getText();
	     s = s.substring(1, s.length() - 1); // strip the leading and trailing quotes
	     try {
	          s = StringConverter.decode(s);
	     }catch (CharacterCodingException e) {
	          e.printStackTrace();
	     }
	     setText(s);
	   }

;

/**
 * The entity instance name is an # followed by an unsigned integer
 */
ENTITY_INSTANCE_NAME
:
	'#' DIGIT+
;

/**
 * An enumeration is an sequence of capital letters and digits, 
 * starting with an capital letter and delimited by full stops.
 */
ENUMERATION
:
	'.' UPPER
	(
		UPPER
		| DIGIT
	)* '.'
;

BINARY
:
	'""'
	(
		'0' .. '3'
	) HEX* '""'
;

/**
 * Punctuation
 */
SEMICOLON
:
	';'
;

LPAREN
:
	'('
;

RPAREN
:
	')'
;

COMMA
:
	','
;

HASH
:
	'#'
;

EQUAL
:
	'='
;

NOT
:
	'!'
;

/**
 * Special values
 */
OMITTED
:
	'$'
;

DERIVED
:
	'*'
;

fragment
APOSTROPHE
:
	'\''
;

fragment
SIGN
:
	'+'
	| '-'
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

// -------------- strip out unnecessary characters -----------------

NL
:
	'\r'? '\n' -> skip
;

COMMENT
:
	(
		'//' ~( '\n' | '\r' )* '\r'? '\n'
		| '/*'
	) .*? '*/' -> skip
;

WS
:
	[ \t\f]+ -> skip
;
 