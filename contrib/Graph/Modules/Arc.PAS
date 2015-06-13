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

{$SP}
var
  ArcCx,ArcCy,ArcCxs,ArcCys,ArcCxe,ArcCye: short;

type
  ArcCoordsType = record
    x,y,xs,ys,xe,ye : short;
  end;

{$SX}
procedure Arc(x,y,w1,w2,r: short);
var
  w,ew,dw : real;
begin
  if r<1 then return;
  dw:=ArcTan(1/r);
  w:=(w1 mod 360)*3.14159265/180; ew:=(w2 mod 360)*3.14159265/180;
  if w>=ew then ew:=ew+2*3.14159265;
  ArcCx:=x; ArcCy:=y;
  ArcCxs:=x+Round(r*cos(w)); ArcCys:=y-Round(r*sin(w));
  while w<ew do begin
    ArcCxe:=x+Round(r*cos(w)); ArcCye:=y-Round(r*sin(w));
    WritePixel(winptr^.RPort,ArcCxe,ArcCye);
    w:=w+dw;
  end
end;

procedure GetArcCoords(var Coords: ArcCoordsType);
begin
  with Coords do begin
    x:=ArcCx; y:=ArcCy;
    xs:=ArcCxs; ys:=ArcCys;
    xe:=ArcCxe; ye:=ArcCye;
  end;
end;


