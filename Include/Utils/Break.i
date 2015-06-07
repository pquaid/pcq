{
	Break.i for PCQ Pascal

	Declares CheckBreak, a function that tells you whether the
	user pressed Ctrl-C (under some circumstances, anyway).
	The source for this routine is under Runtime/Extras.
}

Function CheckBreak : Boolean;
    External;

	{ Returns TRUE if the user has struck Ctrl-C }

