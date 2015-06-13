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

function GetMaxY: short;
begin
  if winptr=nil then
    GetMaxY:=0
  else
    GetMaxY:=pred(winptr^.Height);
end;

