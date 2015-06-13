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

procedure SetRGBPalette(n: short; r,g,b: byte);
begin
  if winptr<>nil then SetRGB4(ViewPortAddress(winptr),n,r,g,b);
end;

