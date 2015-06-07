
{
	Identify.i

	These are the constants, types and variables required
for the compiler.

}


CONST

	Hash_Size	= 255;		{ Size of the Hash Table - 1 }
	literalsize	= 8000;		{ room for character literals }

	eqsize		= 127;		{ size of the error buffer }

	BufferSize	= 2048;		{ size of Input buffer }
	BufferMax	= BufferSize - 1; { Last index in Buffer }

	Spell_Max	= 10000;	{ Size of the spelling records }

{
	These are the symbols.  Note that the first 40 or so
correspond to the appropriate entries in the Reserved array.
}

TYPE
    Symbols = (and1, array1, begin1, by1, case1,
		const1, div1, do1, downto1, else1, end1, extern1,
		file1, for1, forward1, func1, goto1, if1, in1,
		label1, mod1, not1, of1, or1, packed1, private1,
		proc1, program1, record1, repeat1, return1, set1,
		shl1, shr1, then1, to1, type1, until1, var1, while1,
		with1, xor1,

		ident1, numeral1, asterisk1, becomes1, colon1,
		comma1, dotdot1, endtext1, equal1, greater1,
		leftbrack1, leftparent1, less1, minus1,
		notequal1, notgreater1, notless1, period1, plus1,
		rightbrack1, rightparent1, semicolon1, leftcurl1,
		rightcurl1, quote1, apostrophe1, carat1, at1, pound1,
		ampersand1, realdiv1, realnumeral1, unknown1, Char1);

CONST
    LastReserved = Xor1;

TYPE

    TypeObject = (ob_array, ob_set, ob_record, ob_ordinal, ob_pointer,
		 ob_enumer, ob_subrange, ob_synonym, ob_file, ob_real);

    TypeRec = Record
	Next	: ^TypeRec;
	Object  : TypeObject;
	SubType	: ^TypeRec;
	Ref	: Address; { An IDPtr to record fields, or
			     a TypePtr to the index type of an array }
	Upper,
	Lower	: Integer;
	Size	: Integer;
    end;
    TypePtr = ^TypeRec;

    IDObject = (global, local, refarg, valarg, proc, func, obtype, field,
		stanproc, stanfunc, constant, pending_type, typed_const,
		lab);

    IDStorage = (st_none, st_external, st_internal, st_private, st_initialized,
		 st_forward);

    IDRec = Record
	Next	: ^IDRec;
	Name	: String;
	Object	: IDObject;
	VType	: TypePtr;
	Param	: ^IDRec;
	Level	: Short;
	Storage	: IDStorage;
	Offset	: Integer;
	Unique	: Integer;
	Source	: String;
    end;
    IDPtr = ^IDRec;

    BlockRec = Record
	Previous : ^BlockRec;
	FirstType: TypePtr;
	Level	 : Short;
	Table	 : Array [0..Hash_Size] of IDPtr;
    end;
    BlockPtr = ^BlockRec;

{ The following record allows me to nest include calls to the
  limits of memory. }

    FileRec = Record
	PCQFile	: Text;
	Previous: ^FileRec;
	SaveLine,
	SaveStart : Integer;
	SaveChar  : Char;
	Name	: String;
    end;
    FileRecPtr = ^FileRec;

{ The next record saves the names of include files so I won't load
  them twice.  Note that only as much of the record as is required
  for a particular file name is allocated. }

    IncludeRec = record
	Next : ^IncludeRec;
	Name : Array [0..100] of Char;
    end;
    IncludeRecPtr = ^IncludeRec;

{ This next record helps implement the With statement.  For each active
  with statement, there is a corresponding record.  These are stacked
  (to handle scoping), and simply contain a pointer to the proper type. }

    WithRec = Record
		  Previous : ^WithRec;
		  RecType  : TypePtr;
		  Offset   : Integer;
	      end;
    WithRecPtr = ^WithRec;

{	This is the spelling table stuff.  Originally I was allocating
    memory for ID names one at a time, then freeing them at the end of
    a procedure definition.  I was probably wasting too much time allocating
    memory, however, so I switched back to a one-big-array method, although
    this is somewhat more flexible than the 1.0 version. }

TYPE
    SpellRec = Record
		   Previous : ^SpellRec;
		   First : Integer; { The first index held in this record }
		   Data  : Array [0..Spell_Max] of Char;
	       end;
    SpellRecPtr = ^SpellRec;

VAR

{
	These are the global variables for the compiler.
When this file is included by the main program, space is
allocated for the variables.  The external files, although
they also import this file, just generate external
references.
}

	CurrentBlock	: BlockPtr;

{ Space for literal strings and arrays in the program text }

	LitQ		: Array [0..LiteralSize] of Char;
	LitPtr		: Integer;

{ The reserved words, held here in order to make searching quicker }

	Reserved	: Array [And1..LastReserved] of String;

{ These four implement the error queue, which prints out the latest
128 chars or two lines, whichever is less, when an error occurs }

	ErrorQ		: Array [1..EQSize] of Char;
	EQStart		: Short;
	EQEnd		: Short;
	ErrorPtr	: Short;

{ The spelling table variables }

	CurrentSpellRec : SpellRecPtr;
	SpellPtr	: Integer;

{ The With variables }

	FirstWith,
	LastWith	: WithRecPtr;
	StackLoad	: Integer;

{ Many of these are named similar to the vars in Small-C, but watch
out for different meanings. }

	StandardStorage	: IDStorage;	{ The default storage mode }
	NxtLab		: Integer;	{ Just the current label }
	LitLab		: Integer;	{ Label of the literals }
	StackSpace	: Integer;	{ Counts local var stack space }
	ErrorCount	: Integer;	{ Literally the # of errors }
	InFile		: FileRecPtr;	{ The current input record }
	MainMode	: Boolean;	{ Is this a program file? }
	IncludeList	: IncludeRecPtr;{ list of include files }
	FnStart		: Integer;	{ The line # of the start of this }
	LineNo		: Integer;	{ Current line number. }

	CurrFn		: IDPtr;	{ Index of current proc or func }
	BadType,			{ Universal type index }
	IntType,			{ These are just pointers to }
	BoolType,			{ the appropriate types }
	RealType,
	CharType,
	TextType,
	StringType,
	AddressType,
	ShortType,
	ByteType,
	LiteralType	: TypePtr;	{ Temp type for array lits }
	CurrSym		: Symbols;	{ Current symbol }
	SymLoc		: Integer;	{ Literal integer }
	RealValue	: Real;		{ Literal float }
	SymText		: String;	{ Holds ident. text }
	CurrentChar	: Char;		{ The current char! }
	BuffedChar	: Char;		{ Buffered character }
	CharBuffed	: Boolean;	{ is a char buffered? }
	RangeCheck	: Boolean;	{ Doing rangechecks? }
	IOCheck		: Boolean;	{ Doing IO checks? }
	Do_Offsets	: Boolean; 	{ Write offset information }
	Report_IDS	: Boolean;	{ Write long list of all IDS }
	StdOut_Interactive : Boolean;	{ stdout is a console }
	MainName	: String;	{ Main file name }
	TypeID		: IDPtr;	{ Points to a type's ID rec }
	InputName	: String;	{ Extra copy of full file name }
