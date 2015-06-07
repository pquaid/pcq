Program Optimizer;

{
    Peep.p from PCQ Pascal

Peep is a peephole optimizer that works on the assembly code
produced by PCQ Pascal.  It is not designed to work on any other
code, so be careful.  It reads in the assembly program, optimizes
whatever it can, then writes out a slightly shorter, slightly
faster equivalent file.

Peep makes all sorts of assumptions about the source code, one of
which is that the source code is correct.  For example, if an
instruction takes two operands, Peep expects there to be two
operands.  That's O.K. for the compiler output, but you might run
into trouble if you tried using it on normal assembly programs.
It is highly unlikely that anything written in assembly could be
improved by Peep anyway.

Using Peep is entirely optional.
}



{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}
{$I "Include:Utils/Break.i"}

Const
    MaxPeeps = 199;

type
    Operation = (
		op_ADD,
		op_ADDA,
		op_ADDQ,
		op_AND,
		op_ASL,
		op_ASR,
		op_BCC,
		op_BCS,
		op_BEQ,
		op_BGE,
		op_BGT,
		op_BHI,
		op_BLE,
		op_BLS,
		op_BLT,
		op_BNE,
		op_BPL,
		op_BRA,
		op_BSET,
		op_CLR,
		op_CMP,
		op_CNOP,
		op_DBRA,
		op_DC,
		op_DIVS,
		op_DIVU,
		op_DS,
		op_END,
		op_EOR,
		op_EXG,
		op_EXT,
		op_JMP,
		op_JSR,
		op_LEA,
		op_LINK,
		op_LSL,
		op_LSR,
		op_MOVE,
		op_MOVEM,
		op_MOVEQ,
		op_MULS,
		op_MULU,
		op_NEG,
		op_NOT,
		op_OR,
		op_PEA,
		op_RTS,
		op_SCC,
		op_SCS,
		op_SECTION,
		op_SEQ,
		op_SGE,
		op_SGT,
		op_SHI,
		op_SLE,
		op_SLS,
		op_SLT,
		op_SNE,
		op_SUB,
		op_SUBQ,
		op_SWAP,
		op_TRAP,
		op_TST,
		op_UNLK,
		op_XDEF,
		op_XREF,
		op_None,
		op_LABEL,
		op_EOF);

    CodeCell = record
	OpCode	: Operation;
	OSize	: Char;
	Deleted	: Boolean;
	Operand1,
	Operand2,
	Trailer  : String;
	Buffer	: Array [0..127] of Char;
    end;
    CodeCellPtr = ^CodeCell;

    PeepArray = Array [0..MaxPeeps] of CodeCell;

const

{
    Count   : Array [0..12] of Integer = (0,0,0,0,0,0,0,0,0,0,0,0,0);

    Desc    : Array [0..12] of String = (
		"move 0 to clear          ",
		"remove middleman in move ",
		"swap MOVEQ for AND $FFFF ",
		"reuse data register      ",
		"don't reload Dn          ",
		"remove 0 test for dest=Dn",
		"remove 0 test for src=Dn ",
		"strip rts trailers       ",
		"remove tst               ",
		"tst, don't move          ",
		"don't and with #255      ",
		"lose test in Scc/Bcc     ",
		"swap beq/bra             ");
}
    OpCodes : Array [op_ADD..op_XREF] of String = (
		"add",
		"adda",
		"addq",
		"and",
		"asl",
		"asr",
		"bcc",
		"bcs",
		"beq",
		"bge",
		"bgt",
		"bhi",
		"ble",
		"bls",
		"blt",
		"bne",
		"bpl",
		"bra",
		"bset",
		"clr",
		"cmp",
		"cnop",
		"dbra",
		"dc",
		"divs",
		"divu",
		"ds",
		"end",
		"eor",
		"exg",
		"ext",
		"jmp",
		"jsr",
		"lea",
		"link",
		"lsl",
		"lsr",
		"move",
		"movem",
		"moveq",
		"muls",
		"mulu",
		"neg",
		"not",
		"or",
		"pea",
		"rts",
		"scc",
		"scs",
		"section",
		"seq",
		"sge",
		"sgt",
		"shi",
		"sle",
		"sls",
		"slt",
		"sne",
		"sub",
		"subq",
		"swap",
		"trap",
		"tst",
		"unlk",
		"xdef",
		"xref");

var
    FirstPeep,
    LastPeep	: Integer;
    PeepHole	: PeepArray;
    InputLine	: String;
    InputFileName : String;
    InputFile	: Text;
    OutputFileName : String;
    OutputFile	: Text;
    EndOfFile	: Boolean;
    Changed	: Boolean;



Procedure Die(ExitCode : Integer);
begin
    Close(InputFile);
    Close(OutputFile);
    Exit(ExitCode);
end;

Procedure FindOperand(var c : CodeCell; SymText : String);

{
	This just does a binary chop search of the list of operations
}

var
    top,
    middle,
    bottom	: Operation;
    compare	: Short;
begin
    Bottom := op_ADD;
    Top := op_XREF;

    compare := strpos(SymText, '.');
    if compare = -1 then
	c.OSize := ' '
    else begin
	c.OSize := SymText[Succ(Compare)];
	SymText[compare] := '\0';
    end;

    while Bottom <= Top do begin
	middle := Operation((Byte(bottom) + Byte(top)) shr 1);
	Compare := stricmp(OpCodes[Middle], SymText);
	if Compare = 0 then begin
	    c.Opcode := Middle;
	    return;
	end else if Compare < 0 then
	    Bottom := Succ(Middle)
	else
	    Top := Pred(Middle);
    end;
    Writeln('Unknown instruction "', SymText, '"');
    Die(10);
end;

Procedure ReadWord(InLine : String; var pos : Integer;
			var dest : String; delim : Char);
begin
    while isspace(InLine[pos]) do
	Inc(pos);
    dest := Adr(Inline[pos]);
    while (not isspace(Inline[pos])) and
	  (Inline[pos] <> '\0') and
	  (Inline[pos] <> delim) do
	Inc(pos);
    Inline[pos] := '\0';
    Inc(pos);
end;

Procedure ReadInstruction(var c : CodeCell);
var
    OpStorage : String;
    Leave     : Boolean;
    InputPos,
    LastPos   : Integer;
begin
    with c do begin
	OpCode := op_NONE;
	OSize  := ' ';
	Deleted:= False;
	Operand1 := "";
	Operand2 := "";
	Trailer  := "";
	InputLine := Adr(c.Buffer);
    end;
    repeat
	Leave := True;
	repeat
	    if eof(InputFile) then begin
		c.OpCode := op_EOF;
		return;
	    end;
	    ReadLn(InputFile, InputLine);
	until (strlen(InputLine) > 0) and (InputLine[0] <> '*');

	if isspace(InputLine[0]) then begin { It's not a label }
	    InputPos := 0;
	    ReadWord(InputLine, InputPos, OpStorage, '\0');
	    if strlen(OpStorage) > 0 then begin
		FindOperand(c, OpStorage);
		case c.OpCode of
		  op_ADD..op_ASR,
		  op_BSET,op_CMP..op_DBRA,
		  op_DIVS,op_DIVU,op_EOR,op_EXG,
		  op_LEA..op_MULU,
		  op_OR, op_SECTION,op_SUB, OP_SUBQ :
			begin
			    ReadWord(InputLine, InputPos, c.Operand1, ',');
			    ReadWord(InputLine, InputPos, c.Operand2, '\0');
			end;
		  op_BCC..op_BRA,op_CLR,
		  op_EXT,op_JMP,op_JSR,
		  op_NEG,op_NOT,op_PEA,
		  op_SCC..op_SNE,
		  op_SWAP..op_UNLK,
		  op_XDEF,op_XREF :
			begin
			    ReadWord(InputLine, InputPos, c.Operand1, '\0');
			end;
		  op_DC, OP_DS :
			begin
			    while isspace(InputLine[InputPos]) do
				Inc(InputPos);
			    c.Operand1 := Adr(InputLine[Inputpos]);
			end;
		  op_END,op_RTS : ;
		end;
	    end else
		Leave := False;
	end else     { It's a label }
	    c.OpCode := op_LABEL;

    until Leave;
end;


Procedure FillPeepholeArray;
var
    WasLabel : Boolean;
begin
    LastPeep := 0;
    FirstPeep := 0;
    repeat
	ReadInstruction(PeepHole[LastPeep]);
	WasLabel := PeepHole[LastPeep].OpCode = op_LABEL;
	Inc(LastPeep);
    until WasLabel or (LastPeep > MaxPeeps) or (EOF(InputFile));
end;


Procedure WriteInstruction(CellNum : Integer);
begin
    with PeepHole[CellNum] do begin

	if OpCode = op_EOF then
	    return;

	if Deleted then
	    return;

	if OpCode = op_LABEL then begin
	    Writeln(OutputFile, String(Adr(Buffer)));
	    return;
	end;

	Write(OutputFile, '\t', OpCodes[OpCode]);

	if OSize <> ' ' then
	    write(OutputFile, '.', OSize);

	if strlen(Operand1) > 0 then
	    Write(OutputFile, '\t', Operand1);

	if strlen(Operand2) > 0 then
	    Write(OutputFile, ',', Operand2);

	Writeln(OutputFile);
    end;
end;

Procedure EmptyPeepholeArray;
var
    i : Integer;
begin
    for i := FirstPeep to Pred(LastPeep) do
	WriteInstruction(i);
end;

Function NextInstruction(Current : Integer) : Integer;
begin
    repeat
	Inc(Current);
	if Current > LastPeep then
	    NextInstruction := -1;
    until not PeepHole[Current].Deleted;
    NextInstruction := Current;
end;

Function IsDataRegister(op : String) : Boolean;
begin
    IsDataRegister := (strlen(op) = 2) and
		      (toupper(op[0]) = 'D') and
		      isdigit(op[1]);
end;


Function IsAddressRegister(op : String) : Boolean;
begin
    IsAddressRegister := ((strlen(op) = 2) and
			 (toupper(op[0]) = 'A') and
			 isdigit(op[1])) or
			 strieq(op, "sp");
end;


Function IsRegister(op : String) : Boolean;
begin
    IsRegister := (strlen(op) = 2) and
		  ((toupper(op[0]) = 'A') or (toupper(op[0]) = 'D')) and
		  isdigit(op[1]);
end;

{
    Carry out optimizations in a three-instruction window.
    The optimizations are:

	scc	Dn
	tst.b	Dn	=>  scc    Dn
	beq	lab	    b~cc   lab

	scc	Dn
	tst.b	Dn	=>  scc    Dn
	bne	lab     =>  bcc    lab

	move.x	??,Dn
	any.x	???,Dn	=>  any.x  ???,??  not done - sub and add
	move.x	Dn,??			   require one operand to
					   be a register

	beq	lab1
	bra	lab2	=>  bne   lab2  (happens in case statements)
	lab1		    lab1
}

Procedure Optimize3(Op1 : Integer);
var
    Op2, Op3 : Integer;
begin
    if Peephole[Op1].Deleted then
	return;

    Op2 := NextInstruction(Op1);
    if Op2 = -1 then
	return;
    Op3 := NextInstruction(Op2);
    if Op3 = -1 then
	return;

{    if (Peephole[Op1].OpCode = op_MOVE) and
	(Peephole[Op3].OpCode = op_MOVE) and
	(Peephole[Op1].OSize = Peephole[Op3].OSize) and
	IsDataRegister(Peephole[Op1].Operand2) and
	streq(Peephole[Op1].Operand1,Peephole[Op3].Operand2) and
	streq(Peephole[Op1].Operand2,Peephole[Op3].Operand1) then begin
	case Peephole[Op2].OpCode of
	  op_ADD..op_ASR,
	  op_CMP,op_DIVS,op_DIVU,
	  op_EOR,
	  op_LSL,op_LSR,
	  op_MULS,op_MULU,op_OR,
	  op_SUB,op_SUBQ :
		if (Peephole[Op2].OSize = Peephole[Op1].OSize) and
		    streq(Peephole[Op2].Operand2,Peephole[Op1].Operand2) then begin
		    Peephole[Op2].Operand2 := Peephole[Op1].Operand1;
		    Peephole[Op1].Deleted := True;
		    Peephole[Op3].Deleted := True;
		    Changed := True;
		end;
	  op_CLR,op_NEG,
	  op_NOT,op_TST :
		if (Peephole[Op2].OSize = Peephole[Op1].OSize) and
		    streq(Peephole[Op2].Operand1,Peephole[Op1].Operand2) then begin
		    Peephole[Op2].Operand1 := Peephole[Op1].Operand1;
		    Peephole[Op1].Deleted := True;
		    Peephole[Op3].Deleted := True;
		    Changed := True;
		end;
	end;
    end else} if ((Peephole[Op1].OpCode >= op_SCC) or
		(Peephole[Op1].OpCode <= op_SNE)) and
		IsDataRegister(Peephole[Op1].Operand1) and
		(Peephole[Op2].OpCode = op_TST) and
		streq(Peephole[Op1].Operand1, Peephole[Op2].Operand1) and
		((Peephole[Op3].OpCode = op_BEQ) or
		(Peephole[Op3].OpCode = op_BNE)) then begin
	if Peephole[Op3].OpCode = op_BEQ then begin
	    case Peephole[Op1].OpCode of
	      op_SEQ : Peephole[Op3].OpCode := op_BNE;
	      op_SGE : Peephole[Op3].OpCode := op_BLT;
	      op_SGT : Peephole[Op3].OpCode := op_BLE;
	      op_SLE : Peephole[Op3].OpCode := op_BGT;
	      op_SLT : Peephole[Op3].OpCode := op_BGE;
	      op_SNE : Peephole[Op3].OpCode := op_BEQ;
	      op_SLS : Peephole[Op3].OpCode := op_BHI;
	      op_SCS : Peephole[Op3].OpCode := op_BCC;
	      op_SCC : Peephole[Op3].OpCode := op_BCS;
	      op_SHI : Peephole[Op3].OpCode := op_BLS;
	    end;
	end else begin
	    case Peephole[Op1].OpCode of
	      op_SEQ : Peephole[Op3].OpCode := op_BEQ;
	      op_SGE : Peephole[Op3].OpCode := op_BGE;
	      op_SGT : Peephole[Op3].OpCode := op_BGT;
	      op_SLE : Peephole[Op3].OpCode := op_BLE;
	      op_SLT : Peephole[Op3].OpCode := op_BLT;
	      op_SNE : Peephole[Op3].OpCode := op_BNE;
	      op_SCC : Peephole[Op3].OpCode := op_BCC;
	      op_SHI : Peephole[Op3].OpCode := op_BHI;
	      op_SLS : Peephole[Op3].OpCode := op_BLS;
	      op_SCS : Peephole[Op3].OpCode := op_BCS;
	    end;
	end;
	Peephole[Op2].Deleted := True;
	Changed := True;
	{ Inc(Count[11]); }
    end else if (Peephole[Op1].OpCode = op_BEQ) and
		(Peephole[Op2].OpCode = op_BRA) and
		(Peephole[Op3].OpCode = op_LABEL) and
		streq(Peephole[Op1].Operand1,Adr(Peephole[Op3].Buffer)) then begin
	Peephole[Op2].OpCode := op_BNE;
	Peephole[Op1].Deleted := True;
	Changed := True;
	{ Inc(Count[12]); }
    end;
end;

{
    Carry out optimizations in a two-instruction window.
    The optimizations are:

	move.x	??,Dn
	move.x	Dn,???	=>	move.x	??,??? (?? <> (a0)+ )

	move.x	??,Dn
	add.x	Dn,???	=>	add.l	??,???

	move.x	Dn,???
	move.x	???,Dn	=>	move.x	Dn,???

	move.x	Dn,???		move.x	Dn,???
	move.x	???,??	=>	move.x	Dn,??

	any.x	??,Dn
	cmp.x	#0,Dn	=>	any.x	??,Dn

	move.x	Dn,??
	cmp.x	#0,Dn	=>	move.x	Dn,?? (?? <> An)

	rts
	anything	=>	rts

	any.x	??,Dn
	tst.x	Dn	=>	any.x	??,Dn

	any.x	Dn
	tst.x	Dn	=>	any.x	Dn

	move.x	??,Dn	=>	tst.x	??
	scc	Dn		scc	Dn

	move.b	#?,Dn
	and.x	#255,Dn	=>	move.x	#?,Dn

	move.w	??,Dn		moveq	#0,Dn
	and.l	#65535,Dn =>	move.w	??,Dn

}

Procedure Optimize2(Op1 : Integer);
var
    Op2 : Integer;
begin
    if Peephole[Op1].deleted then
	return;

    Op2 := NextInstruction(Op1);
    if Op2 = -1 then
	return;

    if (Peephole[Op1].OpCode = op_MOVE) and
	(Peephole[Op2].OpCode = op_MOVE) and
	(Peephole[Op1].OSize = Peephole[Op2].OSize) then begin

	if IsDataRegister(Peephole[Op1].Operand1) and
	   streq(Peephole[Op1].Operand2,Peephole[Op2].Operand1) then begin

	    if streq(Peephole[Op1].Operand1,Peephole[Op2].Operand2) then begin
		Peephole[Op2].Deleted := True;
		{ Inc(Count[4]); }
	    end else begin
		Peephole[Op2].Operand1 := Peephole[Op1].Operand1;
		{ Inc(Count[3]); }
	    end;
	    Changed := True;
	end else if IsRegister(Peephole[Op1].Operand2) and
		streq(Peephole[Op1].Operand2,Peephole[Op2].Operand1) and
		(not streq(Peephole[Op1].Operand1,"(a0)+")) and
		(not IsRegister(Peephole[Op2].Operand2)) then begin
	    Peephole[Op1].Operand2 := Peephole[Op2].Operand2;
	    Peephole[Op2].Deleted := True;
	    Changed := True;
	    { Inc(Count[1]); }
	end;
    end else if Peephole[Op1].OpCode = op_RTS then begin
	case Peephole[Op2].OpCode of
	  op_ADD..op_CMP,
	  op_DBRA,op_DIVU,
	  op_EOR..op_RTS,
	  op_SCC..op_SCS,
	  op_SEQ..op_UNLK : begin
				Peephole[Op2].Deleted := True;
				Changed := True;
				{ Inc(Count[7]); }
			    end;
	end;
    end else if (Peephole[Op2].OpCode = op_CMP) and
		(streq(Peephole[Op2].Operand1,"#0") or
		 streq(Peephole[Op2].Operand1, "#$0")) and
		IsDataRegister(Peephole[Op2].Operand2) then begin
	case Peephole[Op1].OpCode of
	  op_NEG,op_NOT,op_EXT :
		if streq(Peephole[Op1].Operand1,Peephole[Op2].Operand2) and
		    (Peephole[Op1].OSize = Peephole[Op2].OSize) then begin
		    Peephole[Op2].Deleted := True;
		    Changed := True;
		    { Inc(Count[5]); }
		end;
	  op_ADD,op_ADDQ,op_AND,
	  op_ASL,op_ASR,op_DIVS,op_DIVU,op_EOR,
	  op_EXG,op_LSL,op_LSR,
	  op_MULS,op_MULU,op_OR,
	  op_SUB,op_SUBQ :
		if streq(Peephole[Op1].Operand2,Peephole[Op2].Operand2) and
			(Peephole[Op1].OSize = Peephole[Op2].OSize) then begin
		    Peephole[Op2].Deleted := True;
		    Changed := True;
		    { Inc(Count[5]); }
		end;
	  op_MOVE, op_MOVEQ :
		if streq(Peephole[Op1].Operand2,Peephole[Op2].Operand2) and
			(Peephole[Op1].OSize = Peephole[Op2].OSize) then begin
		    Peephole[Op2].Deleted := True;
		    Changed := True;
		    { Inc(Count[5]); }
		end else if streq(Peephole[Op1].Operand1,Peephole[Op2].Operand2) and
			(Peephole[Op1].OSize = Peephole[Op2].OSize) and
			(not IsAddressRegister(Peephole[Op1].Operand1)) then begin
		    Peephole[Op2].Deleted := True;
		    Changed := True;
		    { Inc(Count[6]); }
		end;
	end;
    end else if (Peephole[Op2].OpCode = op_TST) and
		IsDataRegister(Peephole[Op2].Operand1) then begin
	case Peephole[Op1].OpCode of
	  op_NEG,op_NOT,op_EXT :
		if streq(Peephole[Op1].Operand1,Peephole[Op2].Operand1) and
		    (Peephole[Op1].OSize = Peephole[Op2].OSize) then begin
		    Peephole[Op2].Deleted := True;
		    Changed := True;
		    { Inc(Count[8]); }
		end;
	  op_ADD,op_ADDQ,op_AND,
	  op_ASL,op_ASR,op_DIVS,op_DIVU,op_EOR,
	  op_EXG,op_LSL,op_LSR,
	  op_MOVE,op_MOVEQ,op_MULS,op_MULU,
	  op_OR,op_SUB,op_SUBQ :
		if streq(Peephole[Op1].Operand2,Peephole[Op2].Operand1) and
			(Peephole[Op1].OSize = Peephole[Op2].OSize) then begin
		    Peephole[Op2].Deleted := True;
		    Changed := True;
		    { Inc(Count[8]); }
		end;
	end;
    end else if (Peephole[Op1].OpCode = op_MOVE) and
		(Peephole[Op2].OpCode >= op_SCC) and
		(Peephole[Op2].OpCode <= op_SNE) and
		streq(Peephole[Op1].Operand2,Peephole[Op2].Operand1) then begin
	with Peephole[Op1] do begin
	    OpCode := op_TST;
	    Operand2 := "";
	end;
	{ Inc(Count[9]); }
	Changed := True;
    end else if (Peephole[Op1].OpCode = op_MOVE) and
		(Peephole[Op1].Operand1[0] = '#') and
		(Peephole[Op2].OpCode = op_AND) and
		streq(Peephole[Op2].Operand1,"#255") and
		IsDataRegister(Peephole[Op1].Operand2) and
		streq(Peephole[Op1].Operand2,Peephole[Op2].Operand2) and
		(Peephole[Op1].OSize = 'b') then begin
	Peephole[Op1].OSize := Peephole[Op2].OSize;
	Peephole[Op2].Deleted := True;
	Changed := True;
	{ Inc(Count[10]); }
     end else if (Peephole[Op1].OpCode = op_MOVE) and
		 (Peephole[Op2].OpCode = op_AND) and
		 IsDataRegister(Peephole[Op1].Operand2) and
		 streq(Peephole[Op1].Operand2,Peephole[Op2].Operand2) and
		 streq(Peephole[Op2].Operand1,"#65535") and
		 (Peephole[Op1].OSize = 'w') and
		 (Peephole[Op2].OSize = 'l') then begin

	Peephole[Op2].OpCode := op_MOVE;
	Peephole[Op2].Operand1 := Peephole[Op1].Operand1;
	Peephole[Op2].OSize := 'w';

	Peephole[Op1].OpCode := op_MOVEQ;
	Peephole[Op1].OSize := ' ';
	Peephole[Op1].Operand1 := "#0";

	Changed := True;
	{ Inc(Count[2]); }
{    end else if (Peephole[Op1].OpCode = op_MOVE) and
		(Peephole[Op2].OpCode = op_CMP) and
		IsDataRegister(Peephole[Op1].Operand2) and
		streq(Peephole[Op1].Operand2,Peephole[Op2].Operand2) and
		(Peephole[Op2].Operand1[0] = '#') and
		(Peephole[Op1].OSize = Peephole[Op2].OSize) then begin
	Peephole[Op2].Operand2 := Peephole[Op1].Operand1;
	Peephole[Op1].Deleted := True;
	Changed := True; }
    end;
end;

{
    Carry out optimizations in a one-instruction window.
    The optimizations are:

	move.x	#0,??	=>	clr.x ?? (if x <> l and ?? <> Dn )
}

Procedure Optimize1(Op : Integer);
begin
    if Peephole[Op].Deleted then
	return;

    with Peephole[Op] do begin
	if (OpCode = op_MOVE) and
	   (streq(Operand1, "#0") or streq(Operand1, "#$0")) and
	   ((not IsDataRegister(Operand2)) or (OSize <> 'l')) then begin
	    Operand1 := Operand2;
	    Operand2 := "";
	    OpCode := op_CLR;
	    Changed := True;
	    { Inc(Count[0]); }
	end;
    end;
end;

{
Procedure ReadCounts;
var
    CountFile : Text;
    i	: Integer;
begin
    if reopen("Work:Pascal/1.2/peep_counts.txt", CountFile) then begin
	for i := 0 to 12 do
	    readln(CountFile, Count[i]);
	Close(CountFile);
    end;
end;

Procedure WriteCounts;
var
    CountFile : Text;
    i : Integer;
begin
    if open("work:pascal/1.2/peep_counts.txt", CountFile) then begin
	for i := 0 to 12 do begin
	    writeln(CountFile, Count[i]);
	    writeln(Desc[i], ' : ', Count[i]);
	end;
	Close(CountFile);
    end;
end;
}

var
    i : Integer;
begin
    Writeln('PCQ Peephole optimizer');

    InputFileName := AllocString(256);
    OutputFileName := AllocString(256);

    GetParam(1,InputFileName);
    GetParam(2,OutputFileName);

    if (strlen(InputfileName) <= 0) or 
       (strlen(OutputFileName) <= 0) then begin
	Writeln('Usage: Optimize filename');
	Exit(20);
    end;

  {  ReadCounts; }

    FirstPeep := 0;
    LastPeep  := 0;

    if not open(OutputFileName, OutputFile) then begin
	Writeln('Could not open output file: ', OutputFileName);
	Exit(10);
    end;

    if reopen(InputFileName, InputFile) then begin
	while not eof(InputFile) do begin
	    FillPeepholeArray;
	    repeat
		Changed := False;
		for i := FirstPeep to LastPeep do begin
		    Optimize3(i);
		    Optimize2(i);
		    Optimize1(i);
		end;
		if CheckBreak then
		    Die(20);
	    until not Changed;
	    EmptyPeepholeArray;
	end;

	{ WriteCounts; }
	Die(0);
    end;

end.
