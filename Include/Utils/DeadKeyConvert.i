
{
	DeadKeyConvert.i

	This simply declares the DeadKeyConvert function, used to "cook"
   raw keystrokes (from Intuition).  Look at the ROM Kernel Manual and
   the Enhancer Manual for more info.
	The object code is in PCQ.lib, and the source is in Runtime/Extras.
	You will need to call OpenConsoleDevice (defined in ConsoleUtils.i)
    before you use this function, since DeadKeyConvert calls RawKeyConvert.
}

{$I "Include:Intuition/Intuition.i"}

{
	If you are using this function without using Intuition.i, which
would seem to be rare, I would suggest changing the Type of "msg" to
Address or MessagePtr, or whatever is appropriate.  That way you don't
have to include Intuition.i if you don't want to.
}

Function DeadKeyConvert(msg : IntuiMessagePtr; Buffer : String;
			BufSize : Integer; KeyMap : Address) : Integer;
    External;

