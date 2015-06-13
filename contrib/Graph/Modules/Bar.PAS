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

procedure Bar(x0,y0,x1,y1: short);
var
  xp0,yp0,xp1,yp1 : short;
begin
  if winptr=nil then return;
  if x0<x1 then begin
    xp0:=x0;
    xp1:=x1;
  end else begin
    xp0:=x1;
    xp1:=x0;
  end;
  if y0<y1 then begin
    yp0:=y0;
    yp1:=y1;
  end else begin
    yp0:=y1;
    yp1:=y0;
  end;
  RectFill(winptr^.RPort,xp0,yp0,xp1,yp1);
end;


