{
	ConsoleIO.i of PCQ Pascal

	This file implements all the normal console.device stuff for
dealing with windows.  The first set of routines is standard Amiga stuff,
culled from the ROM Kernel Manual.  See ConsoleTest.p for an example of
using these routines.

	The source code for these routines is under Runtime/Extras
}


{$I "Include:Exec/IO.i"}
{$I "Include:Exec/Ports.i"}

Procedure ConPutChar(Request : IOStdReqPtr; Character : Char);
    External;

Procedure ConWrite(Request : IOStdReqPtr; Str : String; length : Integer);
    External;

Procedure ConPutStr(Request : IOStdReqPtr; Str : String);
    External;

Procedure QueueRead(Request : IOStdReqPtr; Where : String);
    External;

Function ConGetChar(consolePort : MsgPortPtr; Request : IOStdReqPtr;
			WhereTo : String) : Char;
    External;
