external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:intuition/Screens.i"}
{$I "INCLUDE:graphics/Pens.i"}
{$I "INCLUDE:graphics/Rastport.i"}

{$SX}
var
  scrptr : ^screen;
  winptr : ^window;

procedure MoveRel(x,y: short);
begin
  if winptr<>nil then
    Move(winptr^.RPort,winptr^.RPort^.cp_x+x,winptr^.RPort^.cp_y+y);
end;

