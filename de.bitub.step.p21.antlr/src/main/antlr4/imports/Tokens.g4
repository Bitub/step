lexer grammar Tokens;

import BasicAlphabet;

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
 * Integer consist of an sign and any number of digits
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
	APOSTROPHE .*? APOSTROPHE
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

ENTITY_INSTANCE_NAME
:
	'#' DIGIT+
;

ENUMERATION
:
	'.' UPPER
	(
		UPPER
		| DIGIT
	)* '.'
;

fragment
BINARY
:
	'""'
	(
		'0' .. '3'
	) HEX* '""'
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

//NON_Q_CHAR
//:
//	(
//		SPECIAL
//		| DIGIT
//		| SPACE
//		| LOWER
//		| UPPER
//	)
//;
//
//STRING
//:
//	START_STRING
//	(
//		NON_Q_CHAR
//		| APOSTROPHE APOSTROPHE
//		| REVERSE_SOLIDUS REVERSE_SOLIDUS
//		| CONTROL_DIRECTIVES
//	) -> more
//;
//
//START_STRING
//:
//	'\'' -> pushMode ( INSIDE_STRING )
//;
//
//
///**
// * Mode for all character inside a string.
// */
//mode INSIDE_STRING;
//
//// this is the end of a string
////
//END_STRING
//:
//	'\'' -> popMode
//;
//
//CONTROL_DIRECTIVES
//:
//	(
//		PAGE
//		| ALPHABET
//		| EXTENDED2
//		| EXTENDED4
//		| ARBITARY
//	)
//;
//
//PAGE
//:
//	REVERSE_SOLIDUS 'S' REVERSE_SOLIDUS CHARACTER
//;
//
//ALPHABET
//:
//	REVERSE_SOLIDUS 'P' UPPER REVERSE_SOLIDUS
//;
//
//EXTENDED2
//:
//	REVERSE_SOLIDUS 'X2' REVERSE_SOLIDUS HEX_TWO
//	(
//		HEX_TWO
//	)* END_EXTENDED
//;
//
//EXTENDED4
//:
//	REVERSE_SOLIDUS 'X4' REVERSE_SOLIDUS HEX_FOUR
//	(
//		HEX_FOUR
//	)* END_EXTENDED
//;
//
//END_EXTENDED
//:
//	REVERSE_SOLIDUS 'X0' REVERSE_SOLIDUS
//;
//
//ARBITARY
//:
//	REVERSE_SOLIDUS 'X' REVERSE_SOLIDUS HEX_ONE
//;
//
//HEX_ONE
//:
//	HEX HEX
//;
//
//HEX_TWO
//:
//	HEX_ONE HEX_ONE
//;
//
//HEX_FOUR
//:
//	HEX_TWO HEX_TWO
//;
