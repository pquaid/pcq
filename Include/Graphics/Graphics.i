{
	Graphics.i of PCQ Pascal

	This is not a standard Amiga include file.  Its only
	purpose, in fact, is to declare the GfxBase variable,
	which is used throughout the runtime library whenever
	you call a graphics.library routine.  You can just as
	easily declare a variable of exactly the same name in
	your source code, by the way.

	The original Graphics.i of PCQ Pascal corresponds to
	roughly these files:

		Graphics/RastPort.i
		Graphics/Regions.i
		Graphics/Pens.i

	The older Graphics.i file declared all the graphics.library
	routines supported by PCQ.lib, so you would also have to
	include various other files to get all of them.
}

var
    GfxBase	: Address;

