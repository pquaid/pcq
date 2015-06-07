External;

{
	Extern2.p

	This is the external part of Extern1.p, which demonstrates
the external file mechanism of PCQ Pascal.  Be sure to read Extern1.p,
which has the information about how to compile and link the program.

	The following procedure is exported by this file.  Meanwhile
Extern1.p tries to import WriteMessage.  When the linker gets a hold
of this amicable arrangement it will resolve their needs and hopefully
all the files will be satisfied.
}

Procedure WriteMessage;
begin
    Writeln('From the External File');
end;

