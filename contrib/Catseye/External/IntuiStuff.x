{

	IntuiStuff.X for PCQ Pascal

	Cat'sEye

	External file for IntuiStuff.i. For documentation on how to make
	IntuiStuff.lib (the intuition part of CE.lib,) see "MakeLib"
	"GfxStuff.x" "DosStuff.x" "CE.x"

}

Type	PropType = (Vertical,Horizontal,Both);
	CheckType= (NoChk,TogNoChk,TogCheck);
	BordType = (None,Plain,Techno,WBTechno,LowTechno);
	DirType  = (Nowhere,Left,Right,Up,Down);

Function IText (Words : String; X,Y,ITColour,ITBackColour: Integer;
		Next : IntuiTextPtr) : IntuiTextPtr;

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

Function Shadow (Words : String; X,Y,Col1,Col2,BCol: Integer;
		Next: IntuiTextPtr): IntuiTextPtr;

	{ Allocates and returns a pointer to shadowed IntuiText. Col2
	  should be darker than Col1. }

var	ITP, ITQ: IntuiTextPtr;

begin
ITQ := IText (Words,X,Y,Col1,BCol,Next);
ITP := IText (Words,X-1,Y+1,Col2,BCol,ITQ);
Shadow := ITP;
end;

Function MMenu (Title: String; LE: Short;
		FItem: MenuItemPtr; var CMW : Short) : MenuPtr;

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
CMW := 0;
end;

Function MItem (Name : String; ShortCut : Char; CheckT: CheckType;
		VPos : Short; SubPtr: MenuItemPtr; MH : Short;
		Var CMW : Short) : MenuItemPtr;

	{ Allocates and returns a pointer to a MenuItem. }

Var	MYPtr	: MenuItemPtr;
	ItIt	: IntuiTextPtr;

begin
new (MyPtr);
ItIt := IText (name,0,1,0,1,nil);
if IntuiTextLength(ItIt) > CMW then CMW := IntuiTextLength(ItIt);
with MyPtr^ do
	begin
	NextItem	:= nil;
	LeftEdge	:= 0;
	TopEdge		:= VPos * MH;
	Width		:= CMW;
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
	 	VPos : Short; MH : Short; Var CMW : Short) : MenuItemPtr;

	{ Allocates and returns a pointer to a SubItem. }

Var	MYPtr	: MenuItemPtr;

begin
new (MyPtr);
with MyPtr^ do
	begin
	NextItem	:= Nil;
	LeftEdge	:= CMW div 3 * 2;
	TopEdge		:= VPos * MH + MH div 2;
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

Function LowTechnoBorder (x1,y1,wid,hite,col1,col2 : Short) : BorderPtr;

	{ TechnoBorder for a lowres noninterlaced screen. }

Var	D,E : BorderPtr;
	F,G : ^Array [1..6] of Short;
	I,x2,y2 : Short;

Begin
x2 := (x1 + wid)-1;
y2 := (y1 + hite)-1;
New (D);
New (E);
F := AllocMem (12, MEMF_PUBLIC);
G := AllocMem (12, MEMF_PUBLIC);
F^[1] := x1;
F^[2] := y1;
F^[3] := x2;
F^[4] := y1;
F^[5] := x2;
F^[6] := y2;
G^[1] := x1;
G^[2] := y1;
G^[3] := x1;
G^[4] := y2;
G^[5] := x2-1;
G^[6] := y2;
With D^ do
	begin
	LeftEdge := x1;
	TopEdge := y1;
	FrontPen := col1;
	BackPen := 0;
	DrawMode := JAM1;
	Count := 3;
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
	Count := 3;
	XY := G;
	NextBorder := D;
	end;
LowTechnoBorder := E;
end;

Function MBorder (x1,y1,wid,hite,col1,col2: Short; BType: BordType)
	: BorderPtr;

begin
Case BType of
	None	: MBorder := nil;
	Plain	: MBorder := PlainBorder (x1,y1,wid,hite,col1);
	Techno	: MBorder := TechnoBorder (x1,y1,wid,hite,col1,col2);
	WBTechno: MBorder := WBTechnoBorder (x1,y1,wid,hite,col1,col2);
	LowTechno: MBorder := LowTechnoBorder (x1,y1,wid,hite,col1,col2);
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

	{ NB.	"Sc" is usually the TOTAL NUMBER of things diplayed.
		"Pos" is from 0 - Sc.
		Size is MaxPot / (Sc+1) }
 
Function CurPropPos (T : GadgetPtr; Sc : Integer; Way : PropType) : Integer;

	{ Returns a number 0-Sc reflecting the position of the prop T }

Var F : PropInfoPtr;

Begin
F := PropInfoPtr(T^.SpecialInfo);
if Way = Vertical then
	CurPropPos := UShort (F^.VertPot) * UShort (Sc) div $0000FFFF else
	CurPropPos := UShort (F^.HorizPot) * UShort (Sc) div $0000ffff;
End;

Procedure SetPropPos (T : GadgetPtr; W : WindowPtr; Sc, Pos : Integer;
	Way : PropType);

	{ Sets prop T to position Pos on a scale of 0-Sc
	  Sets prop T to size 1/(sc+1) }

Var	NhBody, NhPot	: Integer;
	F		: PropInfoPtr;

Begin
F := PropInfoPtr(T^.SpecialInfo);
NhBody := $0000FFFF DIV (Sc + 1);
NhPot  := $0000FFFF * Pos DIV Sc;
if Way = Horizontal then
	ModifyProp (T, W, nil, F^.Flags, NHPOT, $FFFF, NHBODY, $FFFF) else
	ModifyProp (T, W, nil, F^.Flags, $FFFF, NHPOT, $FFFF, NHBODY);
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

Procedure SetStrGad (T : GadgetPtr; W : WindowPtr; K : String);

	{ Sets string gadget T to K and refreshes the gadget }

Var	F	: StringInfoPtr;

Begin
F := StringInfoPtr(T^.SpecialInfo);
With F^ do
	begin
	NumChars := strlen (K);
	BufferPos := strlen (k) + 1;
	StrCpy (String(Buffer), K);
	end;
RefreshGList (T, W, nil, 1);
End;

Procedure CompGadget (R : RastPortPtr; B : GadgetPtr);

	{ Inverts the given gadget, as if it is highlighted. }

begin
SetDrMd (R, COMPLEMENT);
RectFill (R,B^.LeftEdge,B^.TopEdge,
		B^.LeftEdge + B^.Width - 1,
		B^.TopEdge + B^.Height - 1);
end;

Procedure EraseGadget (R : RastPortPtr; B : GadgetPtr);

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

Function MProp (x1,y1,wid,hite: Short; Align: PropType; Sc, Pos : Short)
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
		Vertical :
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

Function MString (Initial: String; MaxCh,DispCh,X,Y: Short) : GadgetPtr;

	{ Allocates and returns a pointer to a string gadget. DispCh
	  determines how big, visually, the gadget will be. }

Var	SGad : GadgetPtr;
	SInf : StringInfoPtr;
Begin
new (SGad);
SInf := AllocMem (SizeOf (StringInfo), MEMF_PUBLIC);
With SInf^ do
	begin
	Buffer := StrDup(Initial);
	UndoBuffer := StrDup(Initial);
	BufferPos := StrLen(Initial)+1;
	MaxChars := MaxCh;
	NumChars := StrLen(Initial);
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

Function MInt ( Initial: String;
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
	Buffer := StrDup(Initial);
	UndoBuffer := StrDup(Initial);
	BufferPos := StrLen(Initial)+1;
	MaxChars := MaxCh;
	NumChars := StrLen(Initial);
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
DrawBorder (W^.RPort,BBIS,0,0);
FreeBorder (BBIS);
end;

Function OpenTheWindow(
	St			: String;
	X1,Y1,
	X2,Y2,
	WinFlags,IDFlags	: integer;
	Gadgetp			: GadgetPtr;
	s			: ScreenPtr) : WindowPtr;

	{ This one's Ho Chi Minh's. Opens up a generic window (saves
	  you from allocating a NewWindow structure.) }

var
	nw	: NewWindowPtr;
	w	: WindowPtr;
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

Function OpenTheScreen(
	St			: String;
	Wid,Hite,Dep,VM		: integer) : ScreenPtr;

var	ns	: NewScreenPtr;
	S	: ScreenPtr;

begin
new(ns);
with ns^ do begin
	LeftEdge := 0;
	TopEdge  := 0;
	Width    := Wid;
	Height   := Hite;
	Depth    := Dep;
	DetailPen := 0;
	BlockPen  := 1;
	ViewModes := VM;
	SType     := CUSTOMSCREEN_f;
	Font      := Nil;
	DefaultTitle := St;
	Gadgets   := nil;
	CustomBitMap := nil;
    end;
s := OpenScreen(ns);
dispose(ns);
OpenTheScreen := s;
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
