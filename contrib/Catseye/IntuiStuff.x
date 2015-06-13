External;

{	IntuiStuff.X

	Provides a pretty simple way to access menus, menu items, and sub
	items, with shortcuts, IntuiText, and gadgets. See Menus.P for more
	information.
}

{$I "INC:Exec/Memory.i"}
{$I "INC:Intuition/Intuition.i"}
{$I "INC:Graphics/Pens.i"}
{$I "INC:Utils/StringLib.i"}
{$I "INC:Libraries/Dos.i"}

Type	PropType = (Vertical,Horizontal,Both);
	CheckType= (NoChk,TogNoChk,TogCheck);
	BordType = (None,Plain,Techno,WBTechno);
	DirType  = (Nowhere,Left,Right,Up,Down);

{REQUIRED GLOBAL VARIABLES}

Var	MHeight,
	CurrMWid,
	CurrSIWid : Integer;

Function IText (Words : String; X,Y,ITColour,ITBackColour: Integer; Next : IntuiTextPtr) : IntuiTextPtr;

	{ Allocates and returns a pointer to some IntuiText. }

var	OurITPtr: IntuiTextPtr;

begin
if words <> nil then
begin
new (OurITPtr);
with OurITPtr^ do
	begin
	FrontPen	:= ITColour;
	BackPen		:= ITBackColour;
	DrawMode	:= JAM1;
	LeftEdge	:= x;
	TopEdge		:= Y;
	ITextFont	:= nil;
	IText		:= words;
	NextText	:= next;
	end;
IText := OurITPtr;
end else IText := nil;
end;

Function Shadow (Words : String; X,Y,Col1,Col2,BCol: Integer; Next: IntuiTextPtr): IntuiTextPtr;

	{ Allocates and returns a pointer to shadowed IntuiText. Col2
	  should be darker than Col1. }

var	ITP, ITQ: IntuiTextPtr;

begin
ITQ := IText (Words,X,Y,Col1,BCol,Next);
ITP := IText (Words,X-1,Y+1,Col2,BCol,ITQ);
Shadow := ITP;
end;

Function MMenu (Title: String; LE: Short;
		FItem: MenuItemPtr) : MenuPtr;

	{ Allocates and returns a pointer to a menu. Give it
	  MenuItems first, though. }

var	OurMPtr	:MenuPtr;

begin
new (OurMPtr);
with OurMPtr^ do
	begin
	nextMenu	:= nil;
	LeftEdge	:= LE;
	TopEdge		:= 0;
	Width		:= StrLen(Title) * 8 + 8;
	Height		:= 10;
	flags		:= MENUENABLED;
	MenuName	:= Title;
	FirstItem	:= Fitem;
	end;
MMenu := OurMPtr;
CurrMWid := 0;
end;

Function MItem (Name : String; ShortCut : Char; CheckT: CheckType;
		VPos : Short; SubPtr: MenuItemPtr) : MenuItemPtr;

	{ Allocates and returns a pointer to a MenuItem. }

Var	MYPtr	: MenuItemPtr;
	ItIt	: IntuiTextPtr;

begin
new (MyPtr);
ItIt := IText (name,0,1,0,1,nil);
if IntuiTextLength(ItIt) > CurrMWid then CurrMWid := IntuiTextLength(ItIt);
with MyPtr^ do
	begin
	NextItem	:= nil;
	LeftEdge	:= 0;
	TopEdge		:= VPos * MHeight;
	Width		:= CurrMWid;
	Height		:= 10;
	Flags		:= ItemText + ItemEnabled + HighComp;
		If (ShortCut <> ' ') then Flags := Flags + CommSeq;
		Case CheckT of  TogCheck: Flags := Flags + MenuToggle + CheckIt + Checked;
				TogNoChk: Flags := Flags + MenuToggle + CheckIt;
		end;
	MutualExclude	:= 0;
	ItemFill	:= ItIt;
	SelectFill	:= nil;
	Command		:= ShortCut;
	SubItem		:= SubPtr;
	end;
MItem := MyPtr;
end;

Function MSub (Name : String; ShortCut : Char; CheckT: CheckType;
	 	VPos : Short) : MenuItemPtr;

	{ Allocates and returns a pointer to a SubItem. }

Var	MYPtr	: MenuItemPtr;

begin
new (MyPtr);
with MyPtr^ do
	begin
	NextItem	:= Nil;
	LeftEdge	:= CurrMWid div 3 * 2;
	TopEdge		:= VPos * MHeight + MHeight div 2;
	Width		:= 160;
	Height		:= 10;
	Flags		:= ItemText + ItemEnabled + HighComp;
		If (ShortCut <> ' ') then Flags := Flags + CommSeq;
		Case CheckT of  TogCheck: Flags := Flags + MenuToggle + CheckIt + Checked;
				TogNoChk: Flags := Flags + MenuToggle + CheckIt;
		end;
	MutualExclude	:= 0;
	ItemFill	:= IText (name,0,1,0,1,nil);
	SelectFill	:= nil;
	Command		:= ShortCut;
	end;
MSub := MyPtr;
end;

Function PlainBorder (x1,y1,wid,hite,col : Short) : BorderPtr;

	{ Allocates and returns a pointer to a plain, rectangular
	  border. }

Var D : BorderPtr; F : ^Array [1..10] of Short; I,x2,y2 : Short;
Begin
X2 := (x1+wid)-1;
y2 := (y1+hite)-1;
New (D);
F := AllocMem (20, MEMF_PUBLIC);
For I := 1 to 9 by 2 do
	begin
	F^[I] := x1;
	F^[I+1] := y1;
	end;
F^[3] := x2; F^[5] := x2; F^[6] := y2; F^[8] := y2;
With D^ do
	Begin
	LeftEdge := x1;
	TopEdge := y1;
	FrontPen := col;
	BackPen := 0;
	DrawMode := JAM1;
	Count := 5;
	XY := F;
	NextBorder := nil;
	end;
PlainBorder := D;
end;

Function TechnoBorder (x1,y1,wid,hite,col1,col2 : Short) : BorderPtr;

	{ Allocates and returns a pointer to a 3D (in my opinion)
	  border. Col1, 2 should complement to each other for a
	  better effect. }

Var	D,E : BorderPtr;
	F,G : ^Array [1..12] of Short;
	I,x2,y2 : Short;
Begin
x2 := (x1 + wid)-1;
y2 := (y1 + hite)-1;
New (D);
New (E);
F := AllocMem (24, MEMF_PUBLIC);
G := AllocMem (24, MEMF_PUBLIC);
F^[1] := x1;
F^[2] := y1;
F^[3] := x1;
F^[4] := y2;
F^[5] := x2;
F^[6] := y2;
F^[7] := x2-1;
F^[8] := y2-1;
F^[9] := x1+1;
F^[10] := y2-1;
F^[11] := x1+1;
F^[12] := y1+1;
G^[1] := x2;
G^[2] := y2;
G^[3] := x2;
G^[4] := y1;
G^[5] := x1;
G^[6] := y1;
G^[7] := x1+1;
G^[8] := y1+1;
G^[9] := x2-1;
G^[10] := y1+1;
G^[11] := x2-1;
G^[12] := y2-1;
With D^ do
	begin
	LeftEdge := x1;
	TopEdge := y1;
	FrontPen := col1;
	BackPen := 0;
	DrawMode := JAM1;
	Count := 6;
	XY := F;
	NextBorder := nil;
	end;
With E^ do
	begin
	LeftEdge := x1;
	TopEdge := y1;
	FrontPen := col2;
	BackPen := 0;
	DrawMode := JAM1;
	Count := 6;
	XY := G;
	NextBorder := D;
	end;
TechnoBorder := E;
end;

Function WBTechnoBorder (x1,y1,wid,hite,col1,col2 : Short) : BorderPtr;

	{ TechnoBorder for a hires noninterlaced screen. }

Var	D,E : BorderPtr;
	F,G : ^Array [1..10] of Short;
	I,x2,y2 : Short;
Begin
x2 := (x1 + wid)-1;
y2 := (y1 + hite)-1;
New (D);
New (E);
F := AllocMem (20, MEMF_PUBLIC);
G := AllocMem (20, MEMF_PUBLIC);
F^[1] := x1+1;
F^[2] := y2-1;
F^[3] := x1+1;
F^[4] := y1+1;
F^[5] := x1;
F^[6] := y1;
F^[7] := x1;
F^[8] := y2;
F^[9] := x2-1;
F^[10] := y2;
G^[1] := x2-1;
G^[2] := y1+1;
G^[3] := x2-1;
G^[4] := y2-1;
G^[5] := x2;
G^[6] := y2;
G^[7] := x2;
G^[8] := y1;
G^[9] := x1;
G^[10] := y1;
With D^ do
	begin
	LeftEdge := x1;
	TopEdge := y1;
	FrontPen := col1;
	BackPen := 0;
	DrawMode := JAM1;
	Count := 5;
	XY := F;
	NextBorder := nil;
	end;
With E^ do
	begin
	LeftEdge := x1;
	TopEdge := y1;
	FrontPen := col2;
	BackPen := 0;
	DrawMode := JAM1;
	Count := 5;
	XY := G;
	NextBorder := D;
	end;
WBTechnoBorder := E;
end;

Function MBorder (x1,y1,wid,hite,col1,col2: Short; BType: BordType)
	: BorderPtr;

begin
Case BType of
	None	: MBorder := nil;
	Plain	: MBorder := PlainBorder (x1,y1,wid,hite,col1);
	Techno	: MBorder := TechnoBorder (x1,y1,wid,hite,col1,col2);
	WBTechno: MBorder := WBTechnoBorder (x1,y1,wid,hite,col1,col2);
	end;
end;

Function MImage (x,y,col: short) : ImagePtr;

	{ Allocates and returns a pointer to a generic blank image of
	  colour col and width, height of x,y. }

var	mim : ImagePtr;
Begin
New (mim);
With Mim^ do
	begin
	TopEdge := 0;
	LeftEdge := 0;
	Width := x;
	Height := y;
	Depth := 1;
	ImageData := nil;
	NextImage := nil;
	PlaneOnOff := col;
	PlanePick := 0;
	end;
MImage := Mim;
End;

Function ArrowBord (X,Y,Wid,Hite,Col: Short; Dir: DirType) : BorderPtr;

	{ Allocates and returns a pointer to an arrow-shaped border. }

Var AB: BorderPtr; SSX, SSY, I: Short; AS : ^Array[1..16] of Short;
Begin
SSX := Wid;
SSY := Hite;
if (dir = Up) or (dir = Down) then
	begin
	I := SSX;
	SSX := SSY;
	SSY := I;
	end;
AS := AllocMem (32, MEMF_PUBLIC);
new (AB);
AS^[1] := 5 * SSX;
AS^[2] := 0;
AS^[3] := 0;
AS^[4] := 5 * SSY;
AS^[5] := 5 * SSX;
AS^[6] := 10 * SSY;
AS^[7] := AS^[5];
AS^[8] := 7 * SSY;
AS^[9] := 10 * SSX;
AS^[10] := AS^[8];
AS^[11] := AS^[9];
AS^[12] := 3 * SSY;
AS^[13] := AS^[1];
AS^[14] := AS^[12];
AS^[15] := AS^[1];
AS^[16] := 0;
for I := 1 to 16 do
	AS^[I] := AS^[I] div 10;
if (dir = Right) or (dir = Down) then
	for I := 1 to 15 by 2 do
		begin
		AS^[I] := (Wid - AS^[I]);
		end;
if (dir = Up) or (dir = Down) then
	for I := 1 to 15 by 2 do
		begin
		SSX := AS^[I];
		AS^[I] := AS^[I+1];
		AS^[I+1] := SSX;
		end;
with AB^ do
	begin
	LeftEdge := X;
	TopEdge := Y;
	FrontPen := Col;
	BackPen := 0;
	DrawMode := JAM1;
	Count := 8;
	XY := AS;
	NextBorder := nil;
	end;
ArrowBord := AB;
end;

Function UShort (S : Short) : Integer;

	{ Returns a UShort-like Integer given a Short. }

var f : ^Integer;
	J,K : ^Short;
	g : Integer;
begin
new (F);
J := Address (F);
K := Address (Integer (2) + Integer (J));
J^ := 0;
K^ := S;
G := F^;
dispose (f);
UShort := G;
end;

Function CurPropPos (T : GadgetPtr; Sc : Integer; Way : PropType) : Integer;

	{ Returns a number 0-Sc reflecting the position of the prop T }

Var F : PropInfoPtr;

Begin
F := PropInfoPtr(T^.SpecialInfo);
if Way = Vertical then
	CurPropPos := UShort (F^.VertPot) DIV UShort (Sc) else
	CurPropPos := UShort (F^.HorizPot) DIV UShort (Sc);
End;

Procedure SetPropPos (T : GadgetPtr; W : WindowPtr; Sc, Pos : Integer);

	{ Sets prop T to position Pos on a scale of 0-Sc
	  Sets prop T to size 1/(sc+1) }

Var	NhBody, NhPot	: Integer;
	F		: PropInfoPtr;

Begin
F := PropInfoPtr(T^.SpecialInfo);
NhBody := $0000FFFF DIV (Sc + 1);
NhPot  := $0000FFFF * Pos DIV Sc;
ModifyProp (T, W, nil, F^.Flags, NHPOT, $FFFF, NHBODY, $FFFF);
End;

Procedure SetIntVal (T : GadgetPtr; W : WindowPtr; Vl : Integer);

	{ Sets integer gadget T to Vl and refreshes the gadget }

Var	F	: StringInfoPtr;
	D	: Short;
	St	: String;

Begin
St := AllocString (15);
d := IntToStr (St, vl);
F := StringInfoPtr(T^.SpecialInfo);
With F^ do
	begin
	NumChars := d;
	BufferPos := d + 1;
	LongInt := Vl;
	end;
StrCpy (String(F^.Buffer), St);
RefreshGList (T, W, nil, 1);
FreeString (St);
End;

Procedure Invert (R : RastPortPtr; B : GadgetPtr);

	{ Inverts the given gadget, as if it is highlighted. }

begin
SetDrMd (R, COMPLEMENT);
RectFill (R,B^.LeftEdge,B^.TopEdge,
		B^.LeftEdge + B^.Width - 1,
		B^.TopEdge + B^.Height - 1);
end;

Procedure Destroy (R : RastPortPtr; B : GadgetPtr);

	{ Erases the given gadget. Useful before a RefreshGadget(). }

begin
SetDrMd (R, JAM1);
SetAPen (R, 0);
RectFill (R,B^.LeftEdge,B^.TopEdge,
		B^.LeftEdge + B^.Width - 1,
		B^.TopEdge + B^.Height - 1);
end;

Function MBoolean (Txt: String; x1,y1,wid,hite: Short;
			Tech :BordType; Arrw : DirType) : GadgetPtr;

	{ Allocates and returns a pointer to a boolean gadget. Tech
	  determines whether is should be fancy or not. }

Var Bool : GadgetPtr; Gait : IntuiTextPtr; I,J: Short; T, ArrowB : BorderPtr;
Begin
Gait := IText (Txt,0,0,1,0,nil);
I := (wid-IntuiTextLength(Gait)) div 2;
J := (hite-8) div 2;
Gait := IText (Txt,I,J,1,0,nil);
new (Bool);
With Bool^ do
	begin
	NextGadget := nil;
	LeftEdge := x1;
	TopEdge := y1;
	Width := wid;
	Height := hite;
	Flags := GADGHCOMP;
	Activation := GADGIMMEDIATE + RELVERIFY;
	GadgetType := BOOLGADGET;
	GadgetRender := MBorder (0,0,wid,hite,2,1,Tech);
	SelectRender := nil;
	GadgetText := Gait;
	MutualExclude := 0;
	SpecialInfo := nil;
	GadgetID := 0;
	UserData := nil;
	end;
T := BorderPtr (Bool^.GadgetRender);
if Arrw <> NoWhere then
	begin
	   Case Tech of
		None  : T := ArrowBord (1, 1, wid-2, hite-2, 1, Arrw);
		Plain : T^.NextBorder := ArrowBord (2, 2, wid-4, hite-4, 1, Arrw);
		Techno, WBTechno : begin
			T^.NextBorder^.NextBorder
			:= ArrowBord (3, 3, wid-6, hite-6, 2, Arrw);
			T^.NextBorder^.NextBorder^.NextBorder
			:= ArrowBord (2, 2, wid-6, hite-6, 1, Arrw);
			end;
	   end;
	end;
MBoolean := Bool;
end;

Function DBoolean (Txt: String; x1,y1: Short; Old: GadgetPtr)
			: GadgetPtr;

	{ Allocates and returns a pointer to a duplicate gadget of
	  Old, with changed position and text. Saves on room by
	  not allocating another, identical border. }

Var Bool : GadgetPtr; Gait : IntuiTextPtr; I,J: Short;
Begin
Gait := IText (Txt,0,0,1,0,nil);
I := (Old^.Width-IntuiTextLength(Gait)) div 2;
J := (Old^.Height-8) div 2;
Gait := IText (Txt,I,J,1,0,nil);
new (Bool);
With Bool^ do
	begin
	NextGadget := nil;
	LeftEdge := x1;
	TopEdge := y1;
	Width := Old^.width;
	Height := Old^.height;
	Flags := GADGHCOMP;
	Activation := GADGIMMEDIATE + RELVERIFY;
	GadgetType := BOOLGADGET;
	GadgetRender := Old^.GadgetRender;
	SelectRender := nil;
	GadgetText := Gait;
	MutualExclude := 0;
	SpecialInfo := nil;
	GadgetID := 0;
	UserData := nil;
	end;
DBoolean := Bool;
end;

Function MProp (x1,y1,wid,hite: Short; Align: PropType; Scale, Pos : Short)
		: GadgetPtr;

	{ Allocates and returns a pointer to a generic proportional
	  gadget }

Var	PGad : GadgetPtr;
	PInf : PropInfoPtr;
Begin
new (PGad);
PInf := AllocMem (SizeOf (PropInfo), MEMF_PUBLIC);
With PInf^ do
	begin
	Case Align of	Horizontal: Flags := AUTOKNOB + FREEHORIZ;
			Vertical: Flags := AUTOKNOB + FREEVERT;
			Both: Flags := AUTOKNOB + FREEHORIZ + FREEVERT;
	end;
	HorizPot := 0;
	VertPot := 0;
	Case Align of
		Horizontal :
			begin
			HorizBody := $0000FFFF DIV (Sc + 1);
			HorizPot  := $0000FFFF * Pos DIV Sc;
			VertBody := $FFFF;
			VertPot := $FFFF;
			end;
		Horizontal :
			begin
			VertBody := $0000FFFF DIV (Sc + 1);
			VertPot  := $0000FFFF * Pos DIV Sc;
			HorizBody := $FFFF;
			HorizPot := $FFFF;
			end;
		end;
	end;
With PGad^ do
	begin
	NextGadget := nil;
	LeftEdge := x1;
	TopEdge := y1;
	Width := wid;
	Height := hite;
	Flags := GADGHCOMP;
	Activation := GADGIMMEDIATE + RELVERIFY + FOLLOWMOUSE;
	GadgetType := PROPGADGET;
	GadgetRender := MImage (0,0,0);
	SelectRender := nil;
	GadgetText := nil;
	MutualExclude := 0;
	SpecialInfo := PInf;
	GadgetID := 0;
	UserData := nil;
	end;
MProp := PGad;
end;

Function MString (Var Initial: String; MaxCh,DispCh,X,Y: Short) : GadgetPtr;

	{ Allocates and returns a pointer to a string gadget. DispCh
	  determines how big, visually, the gadget will be. }

Var	SGad : GadgetPtr;
	SInf : StringInfoPtr;
Begin
new (SGad);
SInf := AllocMem (SizeOf (StringInfo), MEMF_PUBLIC);
With SInf^ do
	begin
	Buffer := Initial;
	UndoBuffer := StrDup(Initial);
	BufferPos := StrLen(Initial)+1;
	MaxChars := MaxCh;
	DispPos := 0;
	end;
With SGad^ do
	begin
	NextGadget := nil;
	LeftEdge := x;
	TopEdge := y;
	Width := DispCh*8+2;
	Height := 10;
	Flags := GADGHCOMP;
	Activation := GADGIMMEDIATE + RELVERIFY;
	GadgetType := STRGADGET;
	GadgetRender := PlainBorder (-1,-1,DispCh*8+2+1,11+1,1);
	SelectRender := nil;
	GadgetText := nil;
	MutualExclude := 0;
	SpecialInfo := SInf;
	GadgetID := 0;
	UserData := nil;
	end;
MString := SGad;
end;

Function MInt ( var Initial: String;
		LI: Integer;
		MaxCh,DispCh,X,Y: Short) : GadgetPtr;

	{ Allocates and returns a pointer to an Long Integer gadget. }

Var	SGad : GadgetPtr;
	SInf : StringInfoPtr;
Begin
new (SGad);
SInf := AllocMem (SizeOf (StringInfo), MEMF_PUBLIC);
With SInf^ do
	begin
	Buffer := Initial;
	UndoBuffer := StrDup(Initial);
	BufferPos := StrLen(Initial)+1;
	MaxChars := MaxCh;
	DispPos := 0;
	LongInt := LI;
	end;
With SGad^ do
	begin
	NextGadget := nil;
	LeftEdge := x;
	TopEdge := y;
	Width := DispCh*8+2;
	Height := 10;
	Flags := GADGHCOMP;
	Activation := GADGIMMEDIATE + RELVERIFY + LONGINT;
	GadgetType := STRGADGET;
	GadgetRender := PlainBorder (-1,-1,DispCh*8+2+1,11+1,1);
	SelectRender := nil;
	GadgetText := nil;
	MutualExclude := 0;
	SpecialInfo := SInf;
	GadgetID := 0;
	UserData := nil;
	end;
MInt := SGad;
end;

Procedure RefAllGads (W : WindowPtr);

	{ Given a WindowPtr, refresh all gadgets in the window }

begin
RefreshGadgets (W^.FirstGadget,W,nil);
end;
Procedure RemAllGads (W : WindowPtr);

	{ Given a WindowPtr, remove all gadgets from the window }

Var G,H: GadgetPtr;
begin
G := W^.FirstGadget;
While G <> nil do
	begin
	H := G^.NextGadget;
	If (G^.GadgetType and SYSGADGET) = 0 then
		If RemoveGadget (W,G) <> -1 then;
	G := H;
	end;
end;
Procedure BorderProps (var Rig, Bot: GadgetPtr);

	{ Stick proportional gadgets on the borders of a window }

Var	PBotGad,PRigGad: GadgetPtr;
	PBotInf,PRigInf: PropInfoPtr;
begin
new(PBotGad);
new(PRigGad);
PBotInf := AllocMem (SizeOf (PropInfo), MEMF_PUBLIC);
PRigInf := AllocMem (SizeOf (PropInfo), MEMF_PUBLIC);
With PBotInf^ do
	begin
	Flags := AUTOKNOB + FREEHORIZ;
	HorizPot := 0;
	VertPot := 0;
	HorizBody := $FFFF;
	VertBody := $FFFF;
	end;
With PRigInf^ do
	begin
	Flags := AUTOKNOB + FREEVERT;
	HorizPot := 0;
	VertPot := 0;
	HorizBody := $FFFF;
	VertBody := $FFFF;
	end;

With PBotGad^ do
	begin
	NextGadget := nil;
	LeftEdge := 0;
	TopEdge := -8;		{bottom -8}
	Width := -16;		{Width of win -16}
	Height := 9;
	Flags := GADGHCOMP + GRELWIDTH + GRELBOTTOM;
	Activation := GADGIMMEDIATE + RELVERIFY + FOLLOWMOUSE + BOTTOMBORDER;
	GadgetType := PROPGADGET;
	GadgetRender := MImage (0,0,0);
	SelectRender := nil;
	GadgetText := nil;
	MutualExclude := 0;
	SpecialInfo := PBotInf;
	GadgetID := 0;
	UserData := nil;
	end;
With PRigGad^ do
	begin
	NextGadget := PBotGad;
	LeftEdge := -15;
	TopEdge := 10;
	Width := 16;
	Height := -18;
	Flags := GADGHCOMP + GRELHEIGHT + GRELRIGHT;
	Activation := GADGIMMEDIATE + RELVERIFY + FOLLOWMOUSE + RIGHTBORDER;
	GadgetType := PROPGADGET;
	GadgetRender := MImage (0,0,0);
	SelectRender := nil;
	GadgetText := nil;
	MutualExclude := 0;
	SpecialInfo := PRigInf;
	GadgetID := 0;
	UserData := nil;
	end;
Rig := PRigGad;
Bot := PBotGad;
end;

Procedure FreeIText (IT : IntuiTextPtr);

	{ Frees IntuiText recursively }

begin
if IT^.NextText <> nil then FreeIText (IT^.NextText);
Dispose (IT);
end;

Procedure FreeImage (Im : ImagePtr);

	{ Frees Images recursively }

begin
if Im^.NextImage <> nil then FreeImage (Im^.NextImage);
Dispose (Im);
end;

Procedure FreeBorder (Bd : BorderPtr);

	{ Frees Borders recursively }

begin
if Bd^.NextBorder <> nil then FreeBorder (Bd^.NextBorder);
FreeMem (Bd^.XY, Bd^.Count * 4);
Dispose (Bd);
end;

Procedure FreeGadget (Gg : GadgetPtr);

	{ Frees Gadgets recursively }

begin
if Gg^.NextGadget <> nil then FreeGadget (Gg^.NextGadget);
if Gg^.SpecialInfo <> nil then
    Case Gg^.GadgetType of
	BOOLGADGET	: FreeMem (Gg^.SpecialInfo, sizeof (BoolInfo));
	PROPGADGET	: FreeMem (Gg^.SpecialInfo, sizeof (PropInfo));
	STRGADGET	: FreeMem (Gg^.SpecialInfo, sizeof (StringInfo));
	end;
if Gg^.GadgetText <> nil then FreeIText (Gg^.GadgetText);
if (Gg^.Flags AND GADGIMAGE) = GADGIMAGE then
	begin
	if Gg^.GadgetRender <> nil then FreeImage (Gg^.GadgetRender);
	if Gg^.SelectRender <> nil then FreeImage (Gg^.SelectRender);
	end
	else
	begin
	if Gg^.GadgetRender <> nil then FreeBorder (Gg^.GadgetRender);
	if Gg^.SelectRender <> nil then FreeBorder (Gg^.SelectRender);
	end;
Dispose (Gg);
end;

Procedure BorderWindow (W : WindowPtr; Bent : BordType; Clr : Boolean);

Var BBIS	: BorderPtr;

begin
if Clr then SetRast (W^.RPort, 0);
BBIS := MBorder (0,0,W^.Width,W^.Height,2,1, Bent);
DrawBorder (R,BBIS,0,0);
FreeBorder (BBIS);
end;

Function OpenTheWindow(St:STRING; X1,Y1,X2,Y2,WinFlags,IDFlags:integer;
                       Gadgetp:GadgetPtr; s:Address) : WindowPtr;

	{ This one's Ho Chi Minh's. Opens up a generic window (saves
	  you from allocating a NewWindow structure.) }

var
    nw      : NewWindowPtr;
    w       : WindowPtr;
begin
    new(nw);
    with nw^ do
        begin
        LeftEdge := x1;
        TopEdge := y1;
        Width := x2;
        Height := y2;
        DetailPen := -1;
        BlockPen  := -1;
        IDCMPFlags := IdFlags;
        Flags := WinFlags;
        FirstGadget := GADGETp;
        CheckMark := nil;
        Title :=St; 
        Screen := s;
        BitMap := nil;
        MinWidth := -1;
        MaxWidth := -1;
        MinHeight := -1;
        MaxHeight := -1;
        if S = nil then WType := WBENCHSCREEN_f
                   else WType := CUSTOMSCREEN_f;
        end;
    w := OpenWindow(nw);
    dispose(nw);
    OpenTheWindow := w;
end;

Function CEFReq (var PN, FN, ActionGadgText, Header : String;
		oW: WindowPtr; LEd, TEd : Short; Bent: BordType) : Boolean;

	{ A File Requester, oooh! }

Var
	FileInfo : FileInfoBlock;
	FileListEntry : Array [0..80] of String;
	FileIsDir : Array [0..80] of Boolean;
	AbsMax : Short;
	Position : Short;

	FRG : Array [0..20] of GadgetPtr;

	I, j, LBSec, LBMic : Integer;
	Body, OldPot : Integer;

	RB, RB2 : BorderPtr;
	W : WindowPtr;
	R : RastPortPtr;

	IM : IntuiMessagePtr;
	M : IntuiMessage;

	KnobInfo : PropInfoPtr;

	Done, tCEFReq : Boolean;

	GH : GadgetPtr;

Const
	MaxFiles = 80;
	FNameLE = 8;
	BLine   = 6;
	FNameTE = 4 + BLine;
	TLength = 29;
	TPixelength = TLength * 8;
	PropHeight = 48;

	ScrollerGadget = 1;
	DriveGadget =	 3;
	StringyGadget =  4;
	ActionGadget =	 5;
	FNameGadget = 	 99;
	LFNameGadget = 	 FNameGadget + 7;

	parentString = "/ (Parent)";

Procedure MakeGadgets;

Begin
For I := 0 to 20 do FRG[I] := Nil;
for I := 0 to 7 do
	begin
	FRG[I] := MBoolean (nil, FNameLE, (FNameTE - BLine) + (I * 8),
			TPixelength, 8, None, Nowhere);
	FRG[I]^.GadgetID := FNameGadget + I;
	end;
FRG[8] := MBoolean (nil, FNameLE + TPixelength + 8, FNameTE - BLine,
			 16, 8, Bent, Up);
FRG[9] := MBoolean (nil, FNameLE + TPixelength + 8, FNameTE - BLine +
			 PropHeight + 8, 16, 8, Bent, Down);
FRG[10] := MProp (FNameLE + TPixelength + 8, FNameTE - BLine + 8,
		  16, PropHeight, Vertical);
KnobInfo := PropInfoPtr(FRG[10]^.SpecialInfo);
For I := 8 to 10 do FRG[I]^.GadgetID := ScrollerGadget;

FRG[11] := MBoolean (ActionGadgText, FNameLE + TPixelength + 8,
		FNameTE - BLine + PropHeight + 16 + 1, 68, 14, Bent, Nowhere);
FRG[12] := MBoolean ("Cancel", FNameLE + TPixelength + 8,
		FNameTE - BLine + PropHeight + 32, 68, 14, Bent, Nowhere);
For I := 11 to 12 do FRG[I]^.GadgetID := ActionGadget;

FRG[13] := MBoolean ("df0:", FNameLE + TPixelength + 32,
		FNameTE - BLine, 44, 14, Bent, Nowhere);
FRG[14] := DBoolean ("df1:", FNameLE + TPixelength + 32,
		FNameTE - BLine + 16, FRG[13]);
FRG[15] := DBoolean ("dh0:", FNameLE + TPixelength + 32,
		FNameTE - BLine + 32, FRG[13]);
FRG[16] := DBoolean ("ram:", FNameLE + TPixelength + 32,
		FNameTE - BLine + 48, FRG[13]);
For I := 13 to 16 do FRG[I]^.GadgetID := DriveGadget;

FRG[17] := MString (PN, 70, 24,	48, FNameTE - Bline + PropHeight + 20);
FRG[18] := MString (FN, 70, 24,	48, FNameTE - Bline + PropHeight + 34);
For I := 17 to 18 do FRG[I]^.GadgetID := StringyGadget;

for I := 1 to 18 do FRG[I-1]^.NextGadget := FRG[I];
end;

Function OpenFReq : Boolean;
Var S : Address; 
begin
if oW = nil then S := nil else S := oW^.WScreen;
MakeGadgets;
W := OpenTheWindow (nil,LEd,TEd,320,100,
		BORDERLESS + ACTIVATE + RMBTRAP,
		MOUSEBUTTONS_f + GADGETUP_f + MOUSEMOVE_f,
		FRG[0], S);
if W = nil then OpenFReq := FALSE;
R := W^.RPort;
RB := MBorder (0,0,W^.Width,W^.Height,2,1,bent);
RB2 := MBorder (2,1,TPixelength+7,64+3,2,1,bent);
SetWindowTitles (W,String(-1),Header);
DrawBorder (R,RB,0,0);
DrawBorder (R,RB2,0,0);
OpenFReq := TRUE;
end;

Procedure ClearList;

Begin
SetAPen (R, 0);
RectFill (R, FNameLE, FNameTE - BLine, FNameLE + TPixelength, FNameTE - BLine + 8 * 8 - 1);
end;

Procedure SortDir;

var	g :	string; { ha ha bit o' risqué humour there }
	i, c :	integer;
	b :	boolean;

begin
I := 0;
If AbsMax = 0 then return;
while i < (AbsMax-1) do
	begin
	c := stricmp (FileListEntry[i],FileListEntry[i+1]);
	if c > 0 then
		begin
		g := FileListEntry[i];
		FileListEntry[i] := FileListEntry[i+1];
		FileListEntry[i+1] := g;
		b := FileisDir[i];
		FileIsDir[i] := FileIsDir[i+1];
		FileIsDir[i+1] := b;
		i := 0;
		end else inc (i);
	end;
end;

Procedure RefStringy;

var	Sh, Sh2 : Short;
	NTP : StringInfoPtr;

begin
Sh := RemoveGadget (W, FRG[17]);
NTP := StringInfoPtr (FRG[17]^.specialInfo);
	NTP^.NumChars := StrLen (PN);
Sh := AddGadget (W, FRG[17], Sh);
Sh2 := RemoveGadget (W, FRG[18]);
NTP := StringInfoPtr (FRG[18]^.specialInfo);
	NTP^.NumChars := StrLen (FN);
Sh2 := AddGadget (W, FRG[18], Sh2);

RefreshGadgets (FRG[17], W, nil);
end;

Procedure DrawList(Start: Integer);

Var Gizmo, Lenny : Short;

Begin
  SetDrMd (R, JAM2);
  if AbsMax = 0 then
	begin
	Move (R, FNameLE, FNameTE);
	SetAPen (R, 2);
	GText (R, "(empty)", 7);
	GText (R, "                              ", Tlength - 7);
	end else
  for Gizmo := Start to Start+7 do
	begin
	if FileIsDir[Gizmo] then SetAPen (R, 3) else SetAPen (R, 2);
	Move (R, FNameLE, FNameTE + (Gizmo - Start) * 8);
	Lenny := StrLen (FileListEntry[Gizmo]);
	if Lenny > Tlength then Lenny := Tlength;
	if Gizmo <= (AbsMax-1) then
		GText (R, FileListEntry[Gizmo], Lenny);
	GText (R, "                              ", Tlength - Lenny);
	end;
End;

Function ListDir(dir : String): Short;

var
	MyLock : FileLock;
	I : Short;
	Ergo : Boolean;
	Chuck : String;

begin
AbsMax := 0;
  Mylock := Lock(dir, ACCESS_READ);
  if MyLock <> NiL then
    begin
    if Examine(MyLock, Adr(FileInfo)) then
      begin
      Ergo := FALSE;
      if not ExNext(MyLock, Adr(FileInfo)) then Ergo := TRUE;
      while not Ergo do
        begin
	Chuck := String(Adr(FileInfo.fib_FileName));
	StrCpy (FileListEntry[AbsMax],chuck);
	FileIsDir[AbsMax] := (FileInfo.fib_DirEntryType > 0);
	Inc (AbsMax);
	if not ExNext(MyLock, Adr(FileInfo)) then Ergo := TRUE else
	Ergo := (IoErr = Error_No_More_Entries) or (AbsMax > MAXFILES);
	end;
      UnLock(Mylock);
      end;
    end;
  if (strrpos(PN, ':')) <> (Strlen (PN) - 1) then
	begin
	StrCpy (FileListEntry[AbsMax], parentString);
	FileIsDir[AbsMax] := TRUE;
	Inc (AbsMax);
	end;
  ListDir := AbsMax;
end;

Procedure ScrollList(gad: GadgetPtr);

Var VertPot : Integer;

Begin

  If (Gad = FRG[9]) and (Position + 8 < AbsMax) then Inc (Position);
  If (Gad = FRG[8]) and (Position > 0) then Dec (Position);
  If (Gad = FRG[10]) and (AbsMax > 8) then
	begin
	Position := UShort(KnobInfo^.VertPot) div ($0000ffff div (AbsMax - 8));
	DrawList(Position);
	end
  else
  if (AbsMax > 8) then
	Begin
	VertPot := Abs (($0000ffff * Position) div (AbsMax - 8));
	ModifyProp(FRG[10], w, nil,
	  AUTOKNOB + FREEVERT, 0, VertPot, $ffff, KnobInfo^.VertBody);
	DrawList(Position);
	end;
End;

Procedure Parentage;

var	f : ^Array [0..80] of char;
	k : integer;

begin
f := Address(PN);
J := (Strlen(PN)-2);
k := StrRPos(PN, ':');
if k = -1 then return;
while J > K do
	begin
	if f^[j] = '/' then
		begin
		f^[j+1] := '\0';
		j := 0;
		end else dec(j);
	end;
if (j = k) and (j <> 0) then f^[j+1] := '\0';
end;

Procedure GetNewDir;

begin
AbsMax := ListDir (PN);
SortDir;
ClearList;
DrawList(0);
Position := 0;
if AbsMax > 8 then Body := (8 * $0000ffff) DIV AbsMax else Body := ($0000ffff);
ModifyProp(FRG[10], W, nil, KnobInfo^.Flags, 0, 0, $ffff, Body);
end;

Procedure FilesHandler;

begin
I := GH^.GadgetID - FNameGadget;
if I + position <= (AbsMax + 1) then
	if not FileIsDir [position + I] then
	begin
	if DoubleClick (LBSec,LBMic,M.Seconds,M.Micros) then
		begin
		tCEFReq := TRUE;
		Done := TRUE;
		end;
	LBSec := M.Seconds;
	LBMic := M.Micros;
	StrCpy (FN, FilelistEntry [position + i]);
	RefStringy;
	end
	else
	if strieq (FileListEntry [position + i], parentString) then
		begin
		Parentage;
		RefStringy;
		GetNewDir;
		end
		else
		begin
		StrCat (PN, FileListEntry [position + i]);
		StrCat (PN, "/");
		RefStringy;
		GetNewDir;
		end;
end;

Begin
OldPot := 0;
Done := FALSE;
LBSec := 0;
LBMic := 0;
AbsMax := 0;
if not OpenFReq then CEFReq := FALSE;
for i := 0 to maxfiles do FileListEntry[i] := AllocString (30);
GetNewDir;
repeat
repeat
	IM := IntuiMessagePtr(WaitPort(W^.UserPort));
	IM := IntuiMessagePtr(GetMsg(W^.UserPort));
until IM <> nil;
M := IM^;
ReplyMsg (MessagePtr(IM));
Case M.Class of
	GADGETUP_f : Begin
		GH := GadgetPtr (M.IAddress);
		Case GH^.GadgetID of
		ScrollerGadget : ScrollList (GH);
		DriveGadget :	 begin
				 StrCpy (PN, GH^.GadgetText^.IText);
				 RefStringy;
				 GetNewDir;
				 end;
		FNameGadget..LFNameGadget : FilesHandler;
		ActionGadget :  begin
				if GH = FRG[11] then begin tCEFReq := TRUE; Done := TRUE; end;
				if GH = FRG[12] then begin tCEFReq := FALSE; Done := TRUE; end;
				end;
		StringyGadget : if GH = FRG[17] then GetNewDir;
		end;
		end;
	MOUSEMOVE_f :	begin
		If (KnobInfo^.VertPot <> OldPot) then ScrollList (FRG[10]);
		OldPot := KnobInfo^.VertPot;
		end;
end;
Until Done;
Repeat IM := IntuiMessagePtr(GetMsg(W^.UserPort)); Until IM = nil;
CloseWindow (W);
FreeGadget (FRG[0]);
FreeBorder (RB);
FreeBorder (RB2);
CEFReq := tCEFReq;
end;

Procedure GetMenuNum (Var MP, IP, SP : Short; Code: Short);

begin
MP := (Code AND 31);
IP := ((Code Shr 5) AND 63);
SP := ((Code Shr 11) AND 31);
end;

Procedure PutMenuNum (MP, IP, SP : Short; Var Code: Short);

begin
Code :=	(MP AND 31) or
	((IP AND 63) Shl 5) or
	((SP AND 31) Shl 11);
end;
