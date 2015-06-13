Program CEBBS;

{*********************************************************************}
{*  BBS.p                                                            *}
{*								     *}
{*  PRO-BBS written and copyright (c) 1989 by David Stromberger      *}
{*								     *}
{*  PRO-BBS translated to Pascal and modified 1991 Chris Pressey     *}
{*								     *}
{*  See file "BBS.i" for version number				     *}
{*								     *}
{*********************************************************************}

 {$I "Include:exec/exec.i"}
 {$I "Include:intuition/intuition.i"}
 {$I "Include:intuition/intuitionbase.i"}
 {$I "Include:devices/serial.i"}
 {$I "Include:devices/keymap.i"}
 {$I "Include:devices/timer.i"}
 {$I "Include:hardware/cia.i"}
 {$I "Include:exec/nodes.i"}
 {$I "Include:exec/lists.i"}
 {$I "Include:exec/libraries.i"}
 {$I "Include:exec/ports.i"}
 {$I "Include:exec/interrupts.i"}
 {$I "Include:exec/io.i"}
 {$I "Include:exec/memory.i"}
 {$I "Include:libraries/dos.i"}
 {$I "Include:libraries/dosextens.i"}
 {$I "Include:utils/stringlib.i"}
 {$I "Include:utils/ioutils.i"}
 {$I "Include:Utils/ConsoleUtils.i"}
 {$I "Include:Utils/DOSUtils.i"}
 {$I "Include:Utils/ConsoleIO.i"}
 {$I "Include:Utils/SameName.i"}
 {$I "Include:Utils/Random.i"}
 {$I "Include:Utils/DateTools.i"}
 {$I "Include:Utils/BuildMenu.i"}
{$I "BBS.i"}
{$I "bbsintui.p"}
{$I "bbsfwds.p"}
{$I "iofuncs.i"}
{$I "SList.p"}
{$I "Vote.p"}
{$I "Message.p"}
{$I "Main.p"}
{$I "Xfrs.p"}
{$I "Prune.p"}
{$I "Show_menu.p"}
{$I "Main_menu.p"}

procedure setvars;

begin
rc := false;
abort := false;
online := false;
usermask := false;
ff := address ($bfd000);
end;

Procedure Opening_message;

begin
emit (char(12));
emits (version);
emits ("\n");
emits ("Copyright (C) 1991 Chris Pressey\n");
emits ("Please wait, setting up.\n\n");
end;

procedure OpenModem;

begin
ReadSer_Req := AllocMem(sizeof(IOExtSer), MEMF_PUBLIC + MEMF_CLEAR);
ReadSer_Req^.io_SerFlags := SERF_SHARED + SERF_XDISABLED;
ReadSer_Req^.IOSer.io_Message.mn_ReplyPort := CreatePort("Read_RS",0);
if(OpenDevice(SERIALNAME, 0, ReadSer_Req, 0)) <> 0 then
	begin
	CloseWindow(W);
	DeletePort(ReadSer_Req^.IOSer.io_Message.mn_ReplyPort);
	FreeMem(ReadSer_Req,sizeof(IOExtSer));
	exit(20);
	end;
ReadSer_Req^.IOSer.io_Command := CMD_READ;
ReadSer_Req^.IOSer.io_Length := 1;
ReadSer_Req^.IOSer.io_Data := adr(rs_in[0]);

WriteSer_Req := AllocMem(sizeof(IOExtSer),MEMF_PUBLIC + MEMF_CLEAR);
WriteSer_Req^.io_SerFlags := SERF_SHARED + SERF_XDISABLED;
WriteSer_Req^.IOSer.io_Message.mn_ReplyPort := CreatePort("Write_RS",0);
if(OpenDevice(SERIALNAME, 0, WriteSer_Req, 0)) <> 0 then
	begin
	CloseWindow(W);
	DeletePort(WriteSer_Req^.IOSer.io_Message.mn_ReplyPort);
	FreeMem(WriteSer_Req,sizeof(IOExtSer));
	DeletePort(ReadSer_Req^.IOSer.io_Message.mn_ReplyPort);
	FreeMem(ReadSer_Req,sizeof(IOExtSer));
	exit(20);
	end;
WriteSer_Req^.IOSer.io_Command := CMD_WRITE;
WriteSer_Req^.IOSer.io_Length := 1;
WriteSer_Req^.IOSer.io_Data := adr(rs_out[0]);
ReadSer_Req^.io_SerFlags := SERF_SHARED + SERF_XDISABLED;
ReadSer_Req^.io_Baud := 1200;
ReadSer_Req^.io_ReadLen := 8;
ReadSer_Req^.io_WriteLen := 8;
ReadSer_Req^.io_CtlChar := 1;
ReadSer_Req^.IOSer.io_Command := SDCMD_SETPARAMS;
if DoIO(ReadSer_Req) <> 0 then;
ReadSer_Req^.IOSer.io_Command := CMD_READ;

BeginIO(ReadSer_Req);
end;

begin
OpenConsoleDevice;
cia_ptr := Address($BFD000);

W := OpenWindow(Adr(NW));
if W = nil then exit(18);

WritePort := CreatePort(Nil, 0);
if WritePort = Nil then exit(19);

WriteReq := CreateStdIO(WritePort);
if WriteReq = Nil then exit(21);

WriteReq^.io_Data := Address(w);
WriteReq^.io_Length := SizeOf(Window);

if OpenDevice("console.device", 0, IORequestPtr(WriteReq), 0) <> 0 then;

if not local then OpenModem;

setvars;
if toupper(commandline [0]) = 'L' then local := true;

full := true;
makeintuimenus;

opening_message;

mess := allocstring (4096);

loadbbsdata;

bbs;
end.
