
{

	DosStuff.X

}

Type	Entry = record
		Name	: Array [0..39] of char;
		IsD	: Boolean;
		Special,
		pad1	: Short;
		next	: ^Entry;
		end;
	EntryPtr = ^Entry;

Procedure DoRead (F : FileHandle; Buffer : Address; Length : Integer);

var
	ReadResult : Integer;
begin
	ReadResult := DOSRead(F, Buffer, Length);
	if ReadResult <> Length then
		begin
		WriteLn (Length);
		WriteLn (ReadResult);
		Exit (33);
		end;
end;

Procedure ReadCkHead (F : FileHandle; var header : Chunk);

begin
DORead(f, adr(header), sizeof(Chunk));
if odd(header.CkSize) then inc(header.CkSize);
end;

Procedure ReadJunk (F : FileHandle; var Header : Chunk);

var h : ^Array [1..1024] of char;

begin
new (h);
while Header.CkSize > 1024 do
	begin
	DoRead (F, h, 1024);
	Header.CkSize := Header.CkSize - 1024;
	end;
DoRead (F, h, Header.CkSize);
dispose (h);
end;

Function OpenIFF (idi : Integer; fs : string) : FileHandle;

	{ Opens and checks to see if a file is IFF or not }

Var	ID	: Integer;
	Header	: Chunk;
	cfh	: filehandle;

Begin
CFH := DOSOpen(fs, MODE_OLDFILE);
if CFH = nil then OpenIff := nil;
ReadCkHead (Cfh, Header);
if (header.ckID <> ID_FORM) then
	begin
	DOSClose(CFH);
	OpenIff := nil;
	end;
DORead(cfh, adr (id), sizeof(Integer));
if (id <> IDi) then
	begin
	DOSClose(CFH);
	OpenIff := nil;
	end;
OpenIff := CFH;
end; { OpenIFF }

	{ and now for some stubs... }

Function OpenILBM (filespec : string) : FileHandle;

begin
OpenILBM := OpenIFF (ID_ILBM, filespec);
end;

Function OpenSample (filespec : string) : FileHandle;

begin
OpenSample := OpenIFF (ID_8SVX, filespec);
end;

Function OpenSMUS (filespec : string) : FileHandle;

begin
OpenSMUS := OpenIFF (ID_SMUS, filespec);
end;

Function ListDir (L : FileLock; Head : EntryPtr) : Integer;

var	F	: FileInfoBlock;
	Done	: Boolean;
	S, T	: EntryPtr;
	cnt	: Short;

begin
if not Examine (L, Adr(F)) then ListDir := -1;
Done := FALSE;
Head^.next := nil;
cnt := 0;
if not ExNext (L, Adr(F)) then Done := TRUE;
T := Head;
While not Done do
	begin
	inc (cnt);
	New (S);
	T^.Next := S;
	StrnCpy (String (Adr(S^.Name)), String(Adr(F.fib_FileName)), 39);
	S^.IsD := (F.fib_DirEntryType > 0);
	T := S;
	S := nil;
	if not ExNext (L, Adr(F)) then Done := TRUE;
	end;
ListDir := cnt;
end;

Function RemoveEntry (E, head : EntryPtr) : Boolean;

var	bef, et, aft : EntryPtr;

begin
bef := Head;
et := Head^.Next;
aft := nil;
while et <> nil do
	begin
	bef := et;
	et := et^.Next;
	if et = E then
		begin
		aft := E^.Next;
		et := nil;
		end
	end;
if aft = nil then RemoveEntry := FALSE;
bef^.next := aft;
dispose (E);
RemoveEntry := TRUE;
end;

Function FindEntryByName (E : string; head : EntryPtr) : EntryPtr;

var	ep, e1: EntryPtr;

begin
ep := Head^.Next;
e1 := nil;
while ep <> nil do
	begin
	if strieq (string(adr(ep^.name)), E) then e1 := ep;
	ep := ep^.next;
	end;
FindEntryByName := e1;
end;

Function FindEntryByNumber (E : short; head : EntryPtr) : EntryPtr;

var	ep, e1 : EntryPtr;
	i : short;

begin
ep := Head^.Next;
e1 := nil;
i := 0;
while ep <> nil do
	begin
	if E = i then e1 := ep;
	inc (i);
	ep := ep^.next;
	end;
FindEntryByNumber := e1;
end;

Procedure FreeList (Head : EntryPtr);

begin
if Head^.next <> nil then FreeList (Head^.Next);
Dispose (head);
end;

Procedure SortList (Heads : EntryPtr);

var	g, h		: string;
	ep, e1, e2 	: EntryPtr;
	c		: short;

begin
ep := Heads^.next;
e1 := Heads;
while ep <> nil do
	begin
	g := string (adr(ep^.name));
	if ep^.next <> nil then
		begin
		h := string (adr(ep^.next^.name));
		c := stricmp (g, h);
		if c > 0 then
			begin
			e1^.next := ep^.next;
			ep^.next := ep^.next^.next;
			ep^.next^.next := ep;

			e1 := heads;
			ep := e1^.next;

			end else
				begin
				e1 := ep;
				ep := ep^.next;
				end
		end
	else 
		begin
		e1 := ep;
		ep := ep^.next;
		end;
	end;
end;

Function Parentage (var d : string) : Boolean;

var	f : ^Array [0..80] of char;
	i, j, k : integer;

begin
f := Address(d);
J := Strlen(d)-2;
k := StrRPos(d, '/');
if k = -1 then k := StrRPos(d, ':');
if k = -1 then Parentage := false;
for i := k to j do f^[i] := '\0';
if (j = k) and (j <> 0) then f^[j+1] := '\0';
Parentage := true;
end;
