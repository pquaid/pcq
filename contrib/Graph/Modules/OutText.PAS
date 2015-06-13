external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:intuition/Screens.i"}
{$I "INCLUDE:graphics/Pens.i"}
{$I "INCLUDE:Utils/StringLib.i"}


{$SX}
var
  scrptr : ^screen;
  winptr : ^window;

procedure OutText(txt: string);
begin
  if winptr<>nil then GText(winptr^.RPort,txt,strlen(txt));
end;

