program GraphTest;
{$I "include:Graph.i"}

const
  TestText = "GRAPH - Test!";

var
  C1,C2,C3,C4 : ArcCoordsType;	{ defined in GRAPH.i }
  n	      : byte;

procedure ArcLine(C1,C2: ArcCoordsType);
begin
  Line(C1.Xstart,C1.Ystart,C2.Xend,C2.Yend);
end;

begin
  AttachGraph;			    { This must be called first1 }
  InitGraph(320,256,4,LoRes);       { a simple display           }
  if GraphResult<>0 then exit(20);  { All right ?                }
  SetBkColor(Blue);
  ClearDevice;			    { Paint background blue	 }
  Arc(40,40,90,180,30);
  GetArcCoords(C1);
  Arc(GetMaxX-40,40,0,90,30);       { draw some 'Arcs'           }
  GetArcCoords(C2);
  Arc(GetMaxX-40,GetMaxY-40,270,0,30);
  GetArcCoords(C3);
  Arc(40,GetMaxY-40,180,270,30);
  GetArcCoords(C4);
  ArcLine(C1,C2);                   { connect them by lines      }
  ArcLine(C2,C3);
  ArcLine(C3,C4);
  ArcLine(C4,C1);
  for n:=0 to 15 do begin	    { some other functions ...	 }
    SetColor(n);
    Bar(50+n*(GetMaxX-50*2)/16,60,50+n*(GetMaxX-50*2)/16-10,100);
  end;
  SetColor(LightRed);
  Rect(100,150,GetMaxX-100,200);
  SetColor(LightMagenta);
  Circle(GetMaxX div 2, GetMaxY div 2,100);
  SetColor(LightCyan);
  for n:=5 to 10 do
    Ellipse(GetMaxX div 2,180,n*3,45-n*3);
  SetColor(LightBlue);
  SetBkColor(Red);
  OutTextXY((GetMaxX-GTextLength(TestText)) div 2,
	    GTextHeight(TestText),TestText);
  writeln("Current display data:");
  writeln("  MaxX     : ",GetMaxX);
  writeln("  MaxY     : ",GetmaxY);
  writeln("  MaxColor : ",GetMaxColor);
  writeln("  Pen pos. : (",GetX,";",GetY,")  color=",GetPixel(GetX,GetY));
  writeln("  APen     : ",GetColor);
  writeln("  BPen     : ",GetBkColor);
  writeln; writeln("Press [RETURN] to quit");
  readln;
  CloseGraph;			    { That's it! }
end.


