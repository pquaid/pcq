Program ShowVA;

{
    This program is a simple example of using a variable
    number of parameters along with the va_start and va_arg
    routines.
}


{ If we want to use unnamed arguments, we'll need to use the	}
{ C interface.  Thus the following directive:			}
{$C+}


{   The WriteAll routine requires at least one argument, an	}
{   Integer that tells us how many arguments have been passed.	}
{   This integer can be from 0 to any number.			}


Procedure WriteAll(Number : Integer; ... );
var
    AP : Address;  { This will be our Argument Pointer variable }
    i  : Integer;
begin
    va_start(AP);  { Initialize AP }

	{ va_arg will return the current item, and advance AP	}

    for i := 1 to Number do
	Writeln(va_arg(AP,Integer));
end;


{  This routine shows that you don't have to use integers - you	}
{  can use any simple type.					}

Procedure WriteChars(Number : Integer ... );
var
    AP : Address;
    i  : Integer;
begin
    va_start(AP);
    for i := 1 to Number do
	Writeln(va_arg(AP,Char));
end;

begin
    WriteAll(0);			{ Writes nothing }
    WriteAll(0,1,2,3,4,5,6,7,8,9);	{ Also writes nothing }
    WriteAll(4,100000,100001,100002,100003);
    WriteAll(1,MaxInt);

    { Note that we can mix types, as in this case, but the	}
    { compiler will not complain.  Therefore you need to be	}
    { very careful.						}

    WriteChars(4,'A','B',67,'D');
end.

