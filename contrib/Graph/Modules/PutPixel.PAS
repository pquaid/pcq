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

procedure PutPixel(x,y: short; c: byte);
begin
  if winptr=nil then return;
  SetAPen(winptr^.RPort,c);
  WritePixel(winptr^.RPort,x,y);
end;

