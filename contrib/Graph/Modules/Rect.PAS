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

procedure Rect(x0,y0,x1,y1: short); { simple Rectangle }
begin
  if winptr=nil then return;
  Move(winptr^.RPort,x0,y0);
  Draw(winptr^.RPort,x1,y0);
  Draw(winptr^.RPort,x1,y1);
  Draw(winptr^.RPort,x0,y1);
  Draw(winptr^.RPort,x0,y0);
end;

