{
	CRT.i for PCQ Pascal

	These routines are a simple attempt to mimic the some of the
    Turbo Pascal CRT routines.  See ConsoleTest.p for an example of 
    using these.
	Note that ConsoleSetPtr, the actual type returned by
    AttachConsole, is not defined here.  I wanted to implement it as sort
    of an opaque type.
	The source for these routines is under Runtime/Extras, in
    CRT.p and CRT2.p.
}

{$I "Include:Intuition/Intuition.i"}



{
    Initialize the CRT routines for a particular window.  This routine
    returns Nil if there is a problem, or a pointer to a record that
    stores the important information the rest of the routines require.

    AttachConsole must be called before any of the other routines.
}

Function AttachConsole(w : WindowPtr) : Address;
    External;


{
    Clear from the cursor position to the end of the line
}

Procedure ClrEOL(CRT : Address);
    External;


{
    Clear the text area of the window, and moves the cursor to 1,1
}

Procedure ClrScr(CRT : Address);
    External;


{
    Turn the console device's text cursor off.  Note that this is not
    the same as the mouse pointer.
}

Procedure CursOff(CRT : Address);
    External;


{
    Turn the text cursor on
}

Procedure CursOn(CRT : Address);
    External;


{
    Delete the line the cursor is on, moving all lines below it
    up one and clearing the bottom line.
}

Procedure DelLine(CRT : Address);
    External;

{
    Close the console device and free any memory allocated by the
    AttachConsole call.  Also, take care of any pending console IO.
    This routine must be called before the program terminates, and
    before the window is closed.
}

Procedure DetachConsole(CRT : Address);
    External;


{
    Move the text cursor to the specified column and row X,Y.
}

Procedure GotoXY(CRT : Address; x,y : Short);
    External;



{
    Insert a line at the current cursor position.  The current line
    and all those below it are moved down one.
}

Procedure InsLine(CRT : Address);
    External;



{
    Returns TRUE if there is a key waiting at the console
}

Function KeyPressed(CRT : Address) : Boolean;
    External;


{
    Return the maximum character column for the window
}

Function MaxX(CRT : Address) : Short;
    External;

{
    Return the maximum character row for the window
}

Function MaxY(CRT : Address) : Short;
    External;



{
    Wait for a key to be pressed, and return it.  CRT is a pointer to
    the CRT record returned by AttachConsole.  Note that the key will
    not automatically be displayed - you'll have to call WriteString
    or something.
}

Function ReadKey(CRT : Address) : Char;
    External;


{
    Set the foreground (text) pen number.  The actual color displayed
    depends on the color map in use for the screen, so you'll have
    to use SetRGB4 calls (or the equivalent) to get particular values.
}

Procedure TextColor(CRT : Address; t : Byte);
    External;



{
    Set the background color for the text.
}

Procedure TextBackground(CRT : Address; t : Byte);
    External;

{
    Return the current text cursor column
}

Function WhereX(CRT : Address) : Short;
    External;

{
    Return the current text cursor row
}

Function WhereY(CRT : Address) : Short;
    External;



{
    Write a string to the window through the console device.  The
    string can contain ANSI codes to change the pen colors, move
    the cursor, just about anything.
}

Procedure WriteString(CRT : Address; Str : String);
    External;
