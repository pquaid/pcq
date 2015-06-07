Program WhereFrom;

{$I "Include:Libraries/DOS.i"}

type
    FileRec = record
	Handle	: FileHandle;
	Next	: ^FileRec;
	Buffer	: Address;
	Current	: Address;
	Last	: Address;	
	Max	: Address;
	RecSize	: Integer;
	Interactive : Boolean;
	EOF	: Boolean;
	Access	: Short;
    end;

begin
    if IsInteractive(FileRec(Input).Handle) then
	writeln('Input is coming from the console.')
    else
	writeln('Input is comming from a file.');
end.

