external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:intuition/Screens.i"}

{$SX}
var
  scrptr : ^screen;
  winptr : ^window;

function GetMaxX: short;
begin
  if winptr=nil then
    GetMaxX:=0
  else
    GetMaxX:=pred(winptr^.Width);
end;

