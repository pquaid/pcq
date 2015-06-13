external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:intuition/Screens.i"}
{$I "INCLUDE:graphics/Pens.i"}

{$SX}
var
  scrptr : ^screen;
  winptr : ^window;

function GetPixel(x,y: short): integer;
begin
  if winptr<>nil then GetPixel:=ReadPixel(winptr^.RPort,x,y);
end;

