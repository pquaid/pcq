Program External_Part_One;

{
	This program demonstrates how to use the External
procedure and function mechanism of PCQ.  This file contains
the main program (you can tell this because it begins with
the reserved word Program, whereas files of external program
will begin with the reserved word External).  Be sure to take
a look at Extern2.p to see how the other half works.

In order to put together this file, follow these steps:

1.  Compile the external file with a line like the following:

	Pascal Extern2.p Extern2.asm
	A68k Extern2.asm Extern2.o

2.  Compile the main program file:

	Pascal Extern1.p Extern1.asm
	A68k Extern1.asm Extern1.o

3.  Link both files:

	Blink Extern1.o Extern2.o to Extern library PCQ.lib

    This will create a file called Extern that contains the main
program, defined here, and the external procedure defined in Extern2.
Note that the main file must be listed first, but after that the order
doesn't matter.  For another example of a multiple-source-file program,
take a look at the source of the compiler itself.
}

    Procedure WriteMessage;
	External;

{   The preceding lines declare the procedure, and let the compiler know
    that the procedure is supposed to be defined in a different source
    file.  The compiler has no way of verifying that the external
    procedure actually exists, by the way.  The linker handles that part.
}

begin
    WriteMessage;
end.
