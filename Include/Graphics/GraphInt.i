{
	GraphInt.i for PCQ Pascal
}

{$I "Include:Exec/Nodes.i"}

type

{ structure used by AddTOFTask }

    Isrvstr = record
	is_Node	: Node;
	Iptr	: ^Isrvstr;	{ passed to srvr by os }
	code	: Address;
	ccode	: Address;
	Carg	: Integer;
    end;
    IsrvstrPtr = ^Isrvstr;

