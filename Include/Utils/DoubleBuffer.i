{
	DoubleBuffer.i

	These routines provide a very simple double buffer
	mechanism, mainly by being a bit inflexible with the
	choice of screens and windows.

	The first thing to do is to set up a NewScreen structure,
	just like you would do for OpenScreen.  This can be any
	sort of screen.  Then call OpenDoubleBuffer, which will
	return a pointer to a full-screen, borderless backdrop
	window, or Nil if something went wrong.

	If you write into the window's RastPort, it won't be
	visible until you call SwapBuffers.  By the way, you
	can always write into the same RastPort - you don't
	need to reinitialize after SwapBuffers.  All the
	buffer swapping takes place at the level of BitMaps,
	so it's transparent to RastPorts.

	When you have finished, call CloseDoubleBuffer.  If you
	close the window and screen seperately it might crash
	(I'm not sure), but you'll definitely lose memory.

	The source for these routines is in Runtime/Extras,
	and the Object code is in PCQ.lib.  Take a look at the
	source for an explanation how this works.

	One last point: GfxBase must be open before you call
			OpenDoubleBuffer.  But if it wasn't
			open, why would you need doublebuffers?
}

{$I "Include:Intuition/Intuition.i"}

Function OpenDoubleBuffer(ns : NewScreenPtr) : WindowPtr;
    External;

Procedure SwapBuffers(w : WindowPtr);
    External;

Procedure CloseDoubleBuffer(w : WindowPtr);
    External;

