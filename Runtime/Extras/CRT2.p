External;

{
    These are a second set of routines for use with the
    CRT stuff (mimicking the Turbo CRT unit routines).  These
    are simple uses of the console device, made to look
    something like the PC equivalents.

    Since these routines are based on the other CRT routines (in
    particular WriteString()) I made a seperate file so the code
    wouldn't have to be included.

    For each of these routines, CRT is a pointer to the CRT information
    record returned by the Attach console routine.
}


{$I "Include:Utils/StringLib.i"}

    Procedure WriteString(CRT : Address; Str : String);
	External;

Procedure ClrEOL(CRT : Address);
{
    Clear to the end of the line
}
begin
    WriteString(CRT, "\cK");
end;

Procedure ClrScr(CRT : Address);
{
    Clear the text area of the window
}
begin
    WriteString(CRT, "\c1;1H\cJ");
end;

Procedure CursOff(CRT : Address);
{
    Turn the console device's text cursor off
}
begin
    WriteString(CRT, "\c0 p");
end;

Procedure CursOn(CRT : Address);
{
    Turn the text cursor on
}
begin
    WriteString(CRT, "\c p");
end;


{ Delete the current line, moving all the lines below it  }
{ up one.  The bottom line is cleared.                    }

Procedure DelLine(CRT : Address);
begin
    WriteString(CRT, "\cM");
end;

Procedure GotoXY(CRT : Address; x,y : Short);
{
    Move the text cursor to the x,y position.  This routine uses
    the ANSI CUP command.
}
var
    XRep : Array [0..7] of Char;
    YRep : Array [0..7] of Char;
    Dummy : Integer;
begin
    Dummy := IntToStr(Adr(XRep),x);
    Dummy := IntToStr(Adr(YRep),y);
    WriteString(CRT,"\c");
    WriteString(CRT,Adr(YRep));
    WriteString(CRT,";");
    WriteString(CRT,Adr(XRep));
    WriteString(CRT,"H");
end;


{  Insert a line at the current text position.  The current line and  }
{  all those below it are moved down one.                             }

Procedure InsLine(CRT : Address);
begin
    WriteString(CRT, "\cL");
end;

