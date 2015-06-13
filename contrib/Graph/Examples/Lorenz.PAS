program Lorenz;
{$I "include:GRAPH.i"}

const
  mode	= HiRes+Lace;
  w	= 2000; 	    { big display for high-quality hardcopy }
  h	= 2000;
  m	= 47;		    { scaling factors }
  n	= 30;

var
  ch	: char;

procedure PlotWorldPoint(x,y,z: real);
var
  px,py : short;
begin
  px := Round(w div 2 + x * m);
  py := Round(h - y * n);
  Plot(px,py);
end;

procedure LorenzAttractor;
var
  x,y,z : real;

procedure f;
const
  delta = 0.00005;
  a = 10.0;
  b = 28.0;
  c = 8.0/3.0;
var
  dx,dy,dz : real;
begin
  dx := a * (y - x);                { The differencial equations }
  dy := x * (b - z) - y;
  dz := x * y - c * z;
  x := x + delta * dx;
  y := y + delta * dy;
  z := z + delta * dz;
end;

begin
  x:=1; y:=1; z:=1;
  repeat
    f;
    PlotWorldPoint(x,z,y);          { simulate movement }
  until CheckBreak;
end;

begin
  AttachGraph;			    { You know that, don't you ? }
  InitGraph(w,h,1,mode);
  if GraphResult<>0 then begin
    writeln("Could not create display!");
    writeln("*** Program halted!");
    exit(20);
  end;
  SetRGBPalette(0,15,15,15);        { Black on white for printer }
  SetRGBPalette(1,0,0,0);
  writeln("Rendering Lorenz-Attractor!");
  write("Press Ctrl-C to finish rendering: ");
  LorenzAttractor;
  writeln("done!");
  repeat
    write("Wanna print display (y/n)? ");
    readln(ch);
  until (ch='y') or (ch='n');
  if ch='y' then begin
    write("HardCopy in progress...");
    PrintDisplay;		    { That's what we've been waiting for }
    writeln("finished!");
  end;
  CloseGraph;
end.


