parser grammar StringParser;

options {
	tokenVocab = StringLexer;
}

string
:
	L_APOSTROPHE
	(
		NON_Q_CHAR
		| APOSTROPHE APOSTROPHE
		| REVERSE_SOLIDUS REVERSE_SOLIDUS
		| controlDirectives
	)* R_APOSTROPHE
;

controlDirectives
:
	(
		PAGE
		| ALPHABET
		| EXTENDED2
		| EXTENDED4
		| ARBITARY
	)
;
