Program ShellAC;

{$I "Include:Exec/Exec.i"}
{$I "Include:Exec/Memory.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}

var	W,
	ShellW		: WindowPtr;
	BPn,
	DPn,
	NHt,
	NWd		: Short;
	NX,
	NY		: Short;
	Hp, Vp,
	HSz, VSz	: Short;
	afp		: ^Array[0..1024] of char;
	i		: Integer;

const NW: NewWindow =
	(0,0,10,10,-1,-1,0,0,nil,nil,nil,nil,nil,50,0,50,0,WBENCHSCREEN_f);

procedure Title;

begin
WriteLn ('ShellAC V1.01 - Fool around with your Shell or CLI window!\n');
WriteLn ('        V1.0  November 17th AD 1990 by Cat\'sEye');
WriteLn ('        V1.01 March 4th AD 1991 by Cat\'sEye\n');
end;

procedure Usage;

begin
WriteLn ('Usage : ShellAC <BlockPen><DetailPen> {h/x}\n');
WriteLn ('      <BlockPen> : Colour for drawing borders');
WriteLn ('     <DetailPen> : Colour for drawing title bar');
WriteLn ('Note : leave no space between the two digits. EG, use');
WriteLn ('ShellAC 01 to reset the window colours.');
WriteLn ('ShellAC automatically destroys the window limits.');
Exit (0);
end;

Begin
Title;
afp := Address(CommandLine);
i := 0;
while isspace(afp^[i]) do inc(i);
DPn := ord (afp^[i]) - $30;
if (DPn < 0) or (DPn > 9) then
	begin
	WriteLn ('ERROR : 1st parameter out of range');
	Usage;
	end;
inc (i);
BPn := ord (afp^[i]) - $30;
if (BPn < 0) or (BPn > 9) then
	begin
	WriteLn ('ERROR : 2nd parameter out of range');
	Usage;
	end;
W := OpenWindow (Adr(NW));
if w = nil then exit (20);
ShellW := W^.Parent;
CloseWindow(W);
ShellW^.BlockPen := BPn;
ShellW^.DetailPen := DPn;
ShellW^.MinWidth := 1;
ShellW^.MinHeight := 1;
RefreshWindowFrame (ShellW);
end.
