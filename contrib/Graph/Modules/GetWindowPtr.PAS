external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:intuition/Screens.i"}

{$SX}
var
  winptr : ^window;

function GetWindowPtr: address;
begin
  GetWindowPtr:=winptr;
end;

