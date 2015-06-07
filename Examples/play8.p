Program Play8;

{
	Play8.p

	Play a one-shot 8SVX IFF sound file.  The command line is simply
	Play8 filename, where the filename is any path and must be
	present.  This code was derived from Eric Jacobsen's spIFF.c.
	The differences between this and spIFF.c:
	   a) This was translated from C to Pascal
	   b) Several sound files in my collection had odd-length
		name or annotation fields.  That is, the field lengths
		in the file were odd, but the actual data was padded
		with an extra 0 byte.  So this program handles that.
	   c) I added decompression routines taken from an old IFF
		documentation disk.  I couldn't find any properly
		formatted compressed sound files, however, so I'm not
		sure if the decompression is accurate.  The program
		will certainly try to decompress files, but mine came
		out garbage.  Based on the samples I've accumulated,
		it seems that few of them are compressed anyway.

	In my distribution, I included a sample sample, as it were,
	called UseTheForce.8SVX, which obviously came from Star Wars.
}

{$I "Include:Devices/Audio.i"}
{$I "Include:Exec/IO.i"}
{$I "Include:Utils/IOUtils.i"}
{$I "Include:Libraries/DOS.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}
{$I "Include:Exec/Memory.i"}
{$I "Include:Exec/Devices.i"}

type
    Voice8Header = record
	oneShotHiSamples,
	repeatHiSamples,
	samplesPreHiCycle : Integer;
	samplesPerSec : Short;
	ctOctave	: Byte;
	sCompression	: Byte;
	volume : Integer;
    end;

type
    FibTable = Array [0..15] of Byte;

const
    ckname	: String = Nil;
    NoMem	: String = "\nNot enough memory.\n";
    reps	: Integer = 1;
    wrt_flg	: Boolean = True;
    ioa		: IOAudioPtr = Nil;
    dbuf	: Address = Nil;
    FP		: FileHandle = Nil;
    codeToDelta	: FibTable = (-34, -21, -13, -8, -5, -3, -2, -1, 0,
				1, 2, 3, 5, 8, 13, 21);

var
    VHeader	: Voice8Header;
    chan	: Char;
    s, ps	: String;
    dlen, oerr,
    i		: Integer;
    chnk	: ^Integer;
    ckbuffer	: Array [0..2] of Short;
    t		: Address;

Function D1Unpack(source : String; n : Integer; dest : String; x : Byte) : Byte;
var
    d : Byte;
    i, lim : Integer;
begin
    lim := n shl 1;
    for i := 0 to lim - 1 do begin
	d := Ord(Source[i shr 1]);
	if Odd(i) then
	    d := d and 15
	else
	    d := d shr 4;
	x := x + codeToDelta[d];
	dest[i] := Chr(x);
    end;
    D1Unpack := x;
end;

Procedure DUnpack(source : String; n : Integer; dest : Address);
var
    x : Byte;
begin
    x := D1Unpack(@source[2], n - 2, dest, Ord(Source[1]));
end;

Procedure OpenFile;
var
    NameBuffer : Array [0..127] of char;
    Name : String;
begin
    Name := Adr(NameBuffer);
    GetParam(1, Name);
    if strlen(Name) = 0 then begin
	Writeln('Usage: Play8 filename');
	Exit(10);
    end;
    FP := DOSOpen(Name, MODE_OLDFILE);
    if FP = Nil then begin
	Writeln('Could not open ', Name);
	Exit(10);
    end;
end;

procedure CleanUp;
begin
    if ioa <> Nil then begin
	with ioa^.ioa_Request.io_Message do begin
	    if mn_ReplyPort <> Nil then
		DeletePort(mn_ReplyPort);
	end;
	FreeMem(ioa, SizeOf(IOAudio));
    end;
    if dbuf <> Nil then
	FreeMem(dbuf, dlen);
    if FP <> nil then
	DOSClose(FP);
end;


Procedure pExit(Msg : String);
begin
    Writeln(Msg);
    CleanUp;
    Exit(20);
end;

Procedure DoRead(Buffer : Address; Length : Integer);
var
    ReadResult : Integer;
begin
    ReadResult := DOSRead(FP, Buffer, Length);
    if ReadResult <> Length then
	pExit("Read error");
end;

Procedure WriteData(len : Integer);
var
    MBuffer : Array [0..127] of Char;
    MString : String;
begin
    MString := Adr(MBuffer);
    if Odd(len) then
	len := Succ(len);
    MBuffer[127] := '\0';
    while len > 127 do begin
	DoRead(MString, 127);
	if wrt_flg then
	    Write(MString);
	len := len - 127;
    end;
    if len > 0 then begin
	DoRead(MString, len);
	MString[len] := '\0';
	if wrt_flg then
	    Writeln(MString);
    end;
    wrt_flg := True;
end;

begin
    ckname := Adr(ckbuffer);
    ckname[4] := '\0';
    chan := Chr(15);
    OpenFile;
    DoRead(ckname, 4);
    if streq(ckname, "FORM") then begin
	DoRead(ckname,4);	{ Get size out of the way. }
	DoRead(ckname,4);
	if streq(ckname,"8SVX") then begin
	    DoRead(ckname,4);
	    while not streq(ckname,"BODY") do begin
		DoRead(Adr(dlen), 4);
		if streq(ckname,"VHDR") then
		    DoRead(Adr(VHeader), SizeOf(Voice8Header))
		else begin
		    chnk := Address(ckname);
		    case chnk^ of
		      $4e414d45: Write("\nName of sample: ");
		      $41555448: Write("\nAuthor: ");
		      $28432920,
		      $28632920,
		      $2843294a,
		      $2863294a: Write("\n(c) notice: ");
		      $414e4e4f: WriteLn("\nAnnotation field:");
		    else
		      wrt_flg := True;
		    end;
		    WriteData(dlen);
		end;
		DoRead(ckname, 4);
	    end;
	    DoRead(Adr(dlen), 4);
	    Writeln(dlen, ' bytes at ', VHeader.samplesPerSec, 'Hz');
	end else
	    pExit("Not an 8SVX sound file.")
    end else
	pExit("Not an IFF file.");
    ioa := AllocMem(SizeOf(IOAudio), MEMF_PUBLIC);
    if ioa = Nil then
	pExit(NoMem);
    with ioa^.ioa_Request.io_Message do begin
	mn_ReplyPort := CreatePort(Nil, 0);
	if mn_ReplyPort = nil then
	    pExit("Unable to allocate port");
    end;

    dbuf := AllocMem(dlen, MEMF_PUBLIC + MEMF_CHIP);
    if dbuf = Nil then
	pExit(NoMem);

    with ioa^ do begin
	ioa_Request.io_Message.mn_Node.ln_Pri := 10;
	ioa_Data := Adr(chan);
	ioa_Length := 1;
	ioa_AllocKey := 0;
    end;

    oerr := OpenDevice(AUDIONAME, 0, IORequestPtr(ioa), 0);
    if oerr <> 0 then
	pExit("Can't open audio device");

    if dlen > 131000 then begin  { Supposed hardware limitation. }
	dlen := 131000;
    end else if Odd(dlen) then
	dlen := Pred(dlen);
    DoRead(dbuf, dlen);

    if VHeader.sCompression = 1 then begin
	t := AllocMem(dlen shl 1, MEMF_CHIP + MEMF_PUBLIC);
	if t = Nil then
	    pExit("Not enough memory for decompression");
	DUnpack(dbuf, dlen, t);
	FreeMem(dbuf, dlen);
	dbuf := t;
	dlen := dlen shl 1;
    end else if VHeader.sCompression > 1 then
	pExit("Unknown compression type");

    with ioa^ do begin
	ioa_Request.io_Command := CMD_WRITE;
	ioa_Request.io_Flags := ADIOF_PERVOL;
	ioa_Data := dbuf;
	ioa_Cycles := 1;		{ 1 or from command line. }
	ioa_Length := dlen;
	ioa_Period := 3579546 div VHeader.samplesPerSec;
	ioa_Volume := 64;	 	{ Always use maximum volume. }
    end;

    BeginIO(IORequestPtr(ioa));
    oerr := WaitIO(IORequestPtr(ioa));

    if oerr <> 0 then
	Writeln('Error ', oerr, ' playing sample');
    CloseDevice(IORequestPtr(ioa));
    CleanUp;
end.
