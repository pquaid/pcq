External;

{

	CE.X for PCQ Pascal

	Cat'sEye

	External file for making CE.lib, which comprises all of
	IntuiStuff.lib, DosStuff.lib and GfxStuff.lib.

	To make libs:CE.lib, make sure you CD to the directory
	CE.X is in, and execute "MakeLib CE." Make sure:

		1) GfxStuff.i, IntuiStuff.i &c. have all
			the correct headers for the stuff in here
		2) Pascal, A68k, BLink are in your c: (or change
			the MakeLib script)

	These procedures are going to be like cheese - they will improve
	with time. NB that they are not all perfect especially the
	file requester! Toy with it, but don't take it for granted!

	The majority of CE.lib requires
		Var GfxBase : Address;
		GfxBase := OpenLibrary ("graphics.library");

}

{$I "Include:Exec/Memory.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Graphics/Pens.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Libraries/Dos.i"}
{$I "Include:CEUtils/CETypes.i"}
{$I "Include:CEUtils/IFF.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Graphics/RastPort.i"}
{$I "Include:Graphics/View.i"}

{$I "Include:CEUtils/DosStuff.X"}
{$I "Include:CEUtils/GfxStuff.X"}
{$I "Include:CEUtils/IntuiStuff.X"}
{$I "Include:CEUtils/Stick.X"}
