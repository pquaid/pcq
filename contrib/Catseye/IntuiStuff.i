
{	IntuiStuff.I

	Provides a pretty simple way to access menus, menu items, and sub
	items, with shortcuts, IntuiText, and gadgets. See Menus.P for more
	information.
}

{$I "Include:Exec/Memory.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Graphics/Pens.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Libraries/Dos.i"}

Type	PropType = (Vertical,Horizontal,Both);
	CheckType= (NoChk,TogNoChk,TogCheck);
	BordType = (None,Plain,Techno,WBTechno);
	DirType  = (Nowhere,Left,Right,Up,Down);

{REQUIRED GLOBAL VARIABLES}

Var	MHeight,
	CurrMWid,
	CurrSIWid : Integer;

Function IText (Words : String; X,Y,ITColour,ITBackColour: Integer; Next : IntuiTextPtr) : IntuiTextPtr;
	External;
Function Shadow (Words : String; X,Y,Col1,Col2,BCol: Integer; Next: IntuiTextPtr): IntuiTextPtr;
	External;
Function MMenu (Title: String; LE: Short; FItem: MenuItemPtr) : MenuPtr;
	External;
Function MItem (Name : String; ShortCut : Char; CheckT: CheckType;
		VPos : Short; SubPtr: MenuItemPtr) : MenuItemPtr;
	External;
Function MSub (Name : String; ShortCut : Char; CheckT: CheckType;
	 	VPos : Short) : MenuItemPtr;
	External;
Function PlainBorder (x1,y1,wid,hite,col : Short) : BorderPtr;
	External;
Function TechnoBorder (x1,y1,wid,hite,col1,col2 : Short) : BorderPtr;
	External;
Function WBTechnoBorder (x1,y1,wid,hite,col1,col2 : Short) : BorderPtr;
	External;
Function MBorder (x1,y1,wid,hite,col1,col2: Short; BType: BordType)
	: BorderPtr;
	External;
Function MImage (x,y,col: short) : ImagePtr;
	External;
Function ArrowBord (X,Y,Wid,Hite,Col: Short; Dir: DirType) : BorderPtr;
	External;
Function MBoolean (Txt: String; x1,y1,wid,hite: Short;
			Tech :BordType; Arrw : DirType) : GadgetPtr;
	External;
Function DBoolean (Txt: String; x1,y1: Short; Old: GadgetPtr)
			: GadgetPtr;
	External;
Function MProp (x1,y1,wid,hite: Short; Align: PropType): GadgetPtr;
	External;
Function MString (Var Initial: String; MaxCh,DispCh,X,Y: Short) : GadgetPtr;
	External;
Function MInt ( var Initial: String; LI: Integer;
		MaxCh,DispCh,X,Y: Short) : GadgetPtr;
	External;
Procedure RefAllGads (W : WindowPtr);
	External;
Procedure RemAllGads (W : WindowPtr);
	External;
Procedure BorderProps (var Rig, Bot: GadgetPtr);
	External;
Function UShort (S : Short) : Integer;
	External;
Function CurPropPos (T : GadgetPtr; Sc : Integer; Way : PropType) : Integer;
	External;
Procedure SetPropPos (T : GadgetPtr; W : WindowPtr; Sc, Pos : Integer);
	External;
Procedure SetIntVal (T : GadgetPtr; W : WindowPtr; Vl : Integer);
	External;
Procedure Invert (R : RastPortPtr; B : GadgetPtr);
	External;
Procedure Destroy (R : RastPortPtr; B : GadgetPtr);
	External;
Procedure FreeIText (IT : IntuiTextPtr);
	External;
Procedure FreeImage (Im : ImagePtr);
	External;
Procedure FreeBorder (Bd : BorderPtr);
	External;
Procedure FreeGadget (Gg : GadgetPtr);
	External;
Procedure BorderWindow (W : WindowPtr; Bent : BordType; Clr : Boolean);
	External;
Function OpenTheWindow(St:STRING; X1,Y1,X2,Y2,WinFlags,IDFlags:integer;
                       Gadgetp:GadgetPtr; s:Address) : WindowPtr;
	External;
Function CEFReq (var PN, FN, ActionGadgText, Header : String;
		oW: WindowPtr; LEd, TEd : Short; Bent: BordType) : Boolean;
	External;
Procedure GetMenuNum (Var MP, IP, SP : Short; Code: Short);
	External;
Procedure PutMenuNum (MP, IP, SP : Short; Var Code: Short);
	External;
