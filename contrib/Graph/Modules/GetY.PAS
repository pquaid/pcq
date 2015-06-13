external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:graphics/RastPort.i"}

{$SX}
var
  winptr : ^window;

function GetY: short;
begin
  if winptr<>nil then GetY:=winptr^.RPort^.cp_y
  else GetY:=0;
end;


