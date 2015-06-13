
{	IntuiStuff.I for PCQ Pascal

	Cat'sEye

	Provides a pretty simple way to access menus, menu items, and sub
	items, with shortcuts, IntuiText, and gadgets. See IntuiStuff.X
	for more information.
}

{$I "Include:Exec/Memory.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Graphics/Pens.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Libraries/Dos.i"}

Type	PropType = (Vertical,Horizontal,Both);
	CheckType= (NoChk,TogNoChk,TogCheck);
	BordType = (None,Plain,Techno,WBTechno,LowTechno);
	DirType  = (Nowhere,Left,Right,Up,Down);

Function UShort (S : Short) : Integer;
	External;
