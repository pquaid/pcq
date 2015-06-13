external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:graphics/RastPort.i"}

{$SX}
var
  winptr : ^window;

function GetX: short;
begin
  if winptr<>nil then GetX:=winptr^.RPort^.cp_x
  else GetX:=0;
end;


