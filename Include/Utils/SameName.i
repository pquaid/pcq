{
	SameName.i

	This include file contains only one function: SameName.
This routine implements the simplest parts of AmigaDOS pattern matching.
At this point that's just the  # and ? operators, plus the single quote ',
which you place before a # or ? meant to be matched literaly.  Check out
the AmigaDOS books for more information.
	The source for this is in Runtime/Extras, and the object code
is in PCQ.lib
}


Function SameName(Mask, Target : String) : Boolean;
    External;

