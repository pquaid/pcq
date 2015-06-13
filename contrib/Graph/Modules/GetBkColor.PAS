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

function GetBkColor: byte;
begin
  if winptr<>nil then GetBkColor:=winptr^.RPort^.BgPen
  else GetBkColor:=0;
end;

