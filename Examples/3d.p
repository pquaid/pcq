Program ThreeDee;

{
	This program has been laying around for years.  I wrote
	it years ago, and I've translated it from C64 BASIC to
	Turbo Pascal on the PC to BASIC, Modula-2, F-BASIC, C
	and now Pascal on the Amiga.

	The process described above accounts for the odd structure
	(or lack of it) in the program itself.  It has at least one
	significant error (which I once found, in one version, but
	I can no longer find the correction), but I included it
	anyway as a demonstration of the double buffering stuff.
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Utils/DoubleBuffer.i"}
{$I "Include:Utils/DeadKeyConvert.i"}
{$I "Include:Exec/IO.i"}
{$I "Include:Devices/InputEvent.i"}
{$I "Include:Utils/ConsoleUtils.i"}
{$I "Include:Exec/Interrupts.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Graphics/Graphics.i"}
{$I "Include:Graphics/Pens.i"}

CONST
   outoff = 128.0;

TYPE
   PlayerInfo = RECORD
      X, Y, Z : REAL;
      Elevation,
      Angle,
      Tilt    : REAL;
   END;

   VertexInfo = RECORD
	OffX,
	OffY,
	OffZ,
	EffX,
	EffY,
	EffZ	: REAL;
	DisplayX,
	DisplayY	: Short;
	Connection	: ARRAY [1..3] OF Short;
   END;

   TruckInfo = RECORD
      X, Y, Z,
      RelX, RelY, RelZ,
      Elevation,
      Angle, Tilt : REAL;
   END;

VAR
    CX, CY, CZ,
    SX, SY, SZ		: REAL;
    TempX, TempY, TempZ	: REAL;
    Other, OPoint	: INTEGER;
    MyWindow		: WindowPtr;
    RP			: RastPortPtr;
    Term1, Term2, Term3,
    Term4, Term5, Term6,
    Term7, Term8	: REAL;
    QuitTheProgram	: Boolean;

Const
    Player : PlayerInfo = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

    Truck : TruckInfo = (0.0, 0.0, 200.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

    Vertex : Array [1..8] of VertexInfo =
       ((-10.0, 10.0, 25.0, 0.0, 0.0, 0.0, 0, 0, (2, 4, 8)),
	( 10.0, 10.0, 25.0, 0.0, 0.0, 0.0, 0, 0, (3, 7, 0)),
	( 10.0,-10.0, 25.0, 0.0, 0.0, 0.0, 0, 0, (4, 7, 0)),
	(-10.0,-10.0, 25.0, 0.0, 0.0, 0.0, 0, 0, (8, 0, 0)),
	(-10.0, 10.0,-25.0, 0.0, 0.0, 0.0, 0, 0, (0, 0, 0)),
	( 10.0, 10.0,-25.0, 0.0, 0.0, 0.0, 0, 0, (0, 0, 0)),
	( 10.0,-10.0,-25.0, 0.0, 0.0, 0.0, 0, 0, (8, 0, 0)),
	(-10.0,-10.0,-25.0, 0.0, 0.0, 0.0, 0, 0, (0, 0, 0)));

Procedure GetCommand;
var
    IM	: IntuiMessagePtr;
    Response	: Array [0..9] of Char;
    Len	: Integer;
BEGIN
    IM:= IntuiMessagePtr(WaitPort(MyWindow^.UserPort));
    IM := IntuiMessagePtr(GetMsg(MyWindow^.UserPort));
    Len := DeadKeyConvert(IM, Adr(Response), 10, Nil);
    ReplyMsg(MessagePtr(IM));
    if Len = 1 then
	QuitTheProgram := True
    else if Len = 2 then
	case Response[1] of
	  'A' : Truck.Z := Truck.Z + 5.0; { Up Arrow }
	  'B' : Truck.Z := Truck.Z - 5.0; { Down Arrow }
	  'C' : Truck.Angle := Truck.Angle + 0.08; { Right Arrow }
	  'D' : Truck.Angle := Truck.Angle - 0.08; { Left Arrow }
	  'T' : with Player do begin
		    Z := Z + cos(Angle) * 5.0; { Shift Up }
		    X := X + sin(Angle) * 5.0;
		end;
	  'S' : with Player do begin
		    Z := Z - cos(Angle) * 5.0; { Shift Down }
		    X := X - sin(Angle) * 5.0;
		end;
	else
	    DisplayBeep(Nil);
 	end
    else if Len = 3 then
	case Response[2] of
	  'A' : Player.Angle := Player.Angle + 0.08; { Shift Right }
	  '@' : Player.Angle := Player.Angle - 0.08; { Shift Left }
	else
	    DisplayBeep(Nil)
	end;
end;

Procedure OpenTheWindow;
var
    ns : NewScreen;
begin
    with ns do begin
	LeftEdge := 0;
	TopEdge  := 0;
	Width    := 640;
	Height   := 200;
	Depth    := 2;
	DetailPen := 3;
	BlockPen  := 2;
	ViewModes := 32768;
	SType     := CUSTOMSCREEN_f;
	Font      := nil;
	DefaultTitle := "";
	Gadgets   := nil;
	CustomBitMap := nil;
    end;
    MyWindow := OpenDoubleBuffer(Adr(ns));
    if MyWindow = Nil then
	Exit(20);
    ModifyIDCMP(MyWindow, RAWKEY_f);
end;

begin
    GfxBase:= OpenLibrary("graphics.library", 0);
    OpenTheWindow;
    OpenConsoleDevice;
    RP:= MyWindow^.RPort;
    SetAPen(RP, 1);

    QuitTheProgram := False;

    while not QuitTheProgram do begin

	{ Normalize relative to Player position }

	with Truck do begin
	    RelX:= X - Player.X;
	    RelY:= Y - Player.Y;
	    RelZ:= Z - Player.Z;
	end;

	{ Rotate to Player's point of view }

	with Player do begin
	    CX := cos(-Elevation);
	    CY := cos(-Angle);
	    CZ := cos(-Tilt);
	    SX := sin(-Elevation);
	    SY := sin(-Angle);
	    SZ := sin(-Tilt);
	end;
	with Truck do begin
	    TempX := RelX*(CY*CZ) - RelY*(CY*SZ) - RelZ*SY;
	    TempY := RelX*(CX*SZ - SX*SY*CZ) + RelY*(CX*CZ + SX*SY*SZ) -
			RelZ*(SX*CY);
	    TempZ := RelX*(SX*SZ + CX*SY*CZ) + RelY*(SX*CZ-CX*SY*SZ) +
			RelZ*CX*CY;
	    RelX:= TempX;
	    RelY:= TempY;
	    RelZ:= TempZ;
	end;

	if Truck.RelZ > 0.0 then begin { if it's in front of us }

	    { Get attitude }

	    with Truck do begin
		CX:= cos(-Elevation);
		CY:= cos(Angle - Player.Angle);
		CZ:= cos(-Tilt);
		SX:= sin(-Elevation);
		SY:= sin(Angle - Player.Angle);
		SZ:= sin(-Tilt);
	    end;

	{ Each point is rotated the same angles, so we'll figure
	  these once }

	    Term1:= CY*CZ;
	    Term2:= CY*SZ;
	    Term3:= CX*SZ - SX*SY*CZ;
	    Term4:= CX*CZ + SX*SY*SZ;
	    Term5:= SX*CY;
	    Term6:= SX*SZ + CX*SY*CZ;
	    Term7:= SX*CZ - CX*SY*SZ;
	    Term8:= CX*CY;

	{ Figure the coordinates of all the points, all at once }

	    For OPoint := 1 to 8 do
		with Vertex[OPoint] do begin

		    EffX := OffX * Term1 - OffY * Term2 - OffZ * SY + Truck.RelX;
		    EffY := OffX * Term3 + OffY * Term4 - OffZ * Term5 + Truck.RelY;
		    EffZ := OffX * Term6 + OffY * Term7 + OffZ * Term8 + Truck.RelZ;

		    if EffZ < 1.0 then
			EffZ := 1.0; { avoid blowups }

		    TempX := outoff * EffX / EffZ;
		    TempY := outoff * EffY / EffZ;

		    if TempX > 32000.0 then
			TempX:= 32000.0
		    else if TempX < -32000.0 then
			TempX:= -32000.0;
		    if TempY > 32000.0 then
			TempY:= 32000.0
		    else if TempY < -32000.0 then
			TempY:= -32000.0;

		    DisplayX := 320 + TRUNC(TempX);
		    DisplayY := 100 + (TRUNC(TempY) div 2)
		end;

	    SetRast(RP, 0); { Clear background raster }

	{ Draw all the edges }

	    for OPoint:= 1 to 8 do
		with Vertex[OPoint] do
		    for Other:= 1 to 3 do
			if Connection[Other] > 0 then begin
			    Move(RP, DisplayX, DisplayY);
			    Draw(RP, Vertex[Connection[Other]].DisplayX,
					Vertex[Connection[Other]].DisplayY);
			end;

	end else { Behind, so erase it }
	    SetRast(RP, 0);

	SwapBuffers(MyWindow); { Actually display what we've done }
	GetCommand; { And get next position }
    end;
    CloseConsoleDevice;
    CloseDoubleBuffer(MyWindow);
    CloseLibrary(GfxBase);
end.
