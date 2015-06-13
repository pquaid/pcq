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

function GetMaxColor: short;
begin
  if scrptr=nil then
    GetMaxColor:=0
  else if (scrptr^.SViewPort.Modes and $80)<>0 then GetMaxColor:=63
  else if (scrptr^.SViewPort.Modes and $800)<>0 then GetMaxColor:=4095
  else GetMaxColor:=pred(2 shl scrptr^.SBitMap.depth);
end;

