
*	FileRec.i
*	    of the PCQ Pascal runtime library
*
*	This file just defines the offsets into the File Record.  It's
*	used by many of the reading, writing, opening and closing routines.
*

HANDLE	EQU	0
NEXT	EQU	4
BUFFER	EQU	8
CURRENT	EQU	12
LAST	EQU	16
MAX	EQU	20
RECSIZE	EQU	24
INTERACTIVE	EQU	28
EOF	EQU	29
ACCESS	EQU	30

