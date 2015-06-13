external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:intuition/Screens.i"}

{$SX}
var
  scrptr : ^screen;

function GetScreenPtr: address;
begin
  GetScreenPtr:=scrptr;
end;

