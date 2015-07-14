lexer grammar StepLexer;

import Tokens;

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

/** 
 * Seperators
 */
ISO21
:
	'ISO-10303-21;'
;

ENDISO21
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

SOLIDUS
:
	'//'
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
 