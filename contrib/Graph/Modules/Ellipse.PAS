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

procedure Ellipse(x,y,r1,r2: short);
begin
  if winptr<>nil then DrawEllipse(winptr^.RPort,x,y,r1,r2);
end;


