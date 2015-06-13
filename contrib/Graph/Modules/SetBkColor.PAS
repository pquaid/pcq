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

procedure SetBkColor(c: byte);
begin
  if winptr<>nil then SetBPen(winptr^.RPort,c);
end;

