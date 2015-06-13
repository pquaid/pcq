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

function GetColor: byte;
begin
  if winptr<>nil then GetColor:=winptr^.RPort^.FgPen
  else GetColor:=0;
end;

