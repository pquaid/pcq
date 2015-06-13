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

procedure ClearDevice;
begin
  if winptr=nil then return;
  Move(winptr^.RPort,0,0);
  SetRast(winptr^.RPort,winptr^.RPort^.BgPen);
end;

