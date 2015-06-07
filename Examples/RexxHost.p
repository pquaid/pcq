Program RexxHost;

{ This program runs an ARexx command called "RexxHost.RXH",
  waits for its commands (and tells you about them when they
  come), and quits whenever the ARexx program is finished.  }

{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Rexx/ARexxStrings.i"}
{$I "Include:Rexx/RexxIO.i"}
{$I "Include:Rexx/Storage.i"}
{$I "Include:Exec/Interrupts.i"}

VAR
    MyPort: MsgPortPtr;

Procedure Demo;
var
    rmptr	: RexxMsgPtr;
    MyCommand	: RexxMsgPtr;
    RexxPort	: MsgPortPtr;
    Token,
    Scan	: String;
    Quote	: Char;
    Len		: Integer;
begin
    RexxSysBase := OpenLibrary("rexxsyslib.library", 0);
    if RexxSysBase <> nil then begin
	New(MyPort);	{ Allocate memory }
	if InitPort(MyPort, "MyPort") <> -1 then begin
	    AddPort(MyPort);
	    MyCommand := CreateRexxMsg(MyPort, "RXH", "MyPort");
	    MyCommand^.rm_Args[0] := CreateArgString("RexxHost.RXH", 12);
	    MyCommand^.rm_Action := RXCOMM;
	    Forbid;
	    RexxPort := FindPort("REXX");
	    if RexxPort = nil then begin
		Permit;
		Writeln('Could not find the ARexx port');
		ClearRexxMsg(MyCommand, 16);
		DeleteRexxMsg(MyCommand);
		RemPort(MyPort);
		FreePort(MyPort);
		CloseLibrary(RexxSysBase);
		Exit(20);
	    end;
	    PutMsg(RexxPort, MessagePtr(MyCommand));
	    Permit;
	    repeat
		rmptr := RexxMsgPtr(WaitPort(MyPort));
		rmptr := RexxMsgPtr(GetMsg(MyPort));
		if rmptr <> MyCommand then begin
		    StcToken(rmptr^.rm_Args[0], Quote, Len, Scan, Token);
		    writeln(Scan);
		    rmptr^.rm_Result1 := 0;
		    rmptr^.rm_Result2 := 0;
		    ReplyMsg(MessagePtr(rmptr));
		end else begin
		    writeln('received the reply');
		    writeln('return code 1 was ', MyCommand^.rm_Result1);
		    writeln('return code 2 was ', MyCommand^.rm_Result2);
		end;
	    until rmptr = MyCommand;
	    ClearRexxMsg(MyCommand, 16);
	    DeleteRexxMsg(MyCommand);
	    RemPort(MyPort);
	    FreePort(MyPort);
	end else
	    writeln('Could not initialize the port.');
	CloseLibrary(RexxSysBase);
    end else
	Writeln('Could not open the ARexx library.');
end;

begin
    Demo;
end.
