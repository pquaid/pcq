program M_J_sets;
{$I "INCLUDE:GRAPH.i"}
{$I "INCLUDE:Utils/StringLib.i"}

type
  complex = record
    Re,Im : real;
  end;

var
  filename  : string;
  IsM	    : boolean;
  min,max,c : complex;

procedure Quit(msg: string);
begin
  writeln(msg);
  CloseGraph;
  exit;
end;

function Ask(question: string; opt1,opt2: char): boolean;
var
  ch : char;
begin
  repeat
    write(question);
    readln(ch);
    ch:=ToUpper(ch);
  until (ch=opt1) or (ch=opt2);
  Ask:=ch=opt1;
end;

procedure UserInput;

procedure ReadComplex(name: string; var z: complex);
begin
  write("Re(",name,")=");
  readln(z.Re);
  write("Im(",name,")=");
  readln(z.Im);
end;

procedure CheckInput;
begin
  if (min.Re>=max.Re) or (min.Im>=max.Im) then begin
    writeln("Error in input!");
    writeln("Minimum MUST be smaller then maximum!");
    writeln("Why do you think it is called 'Minimum'?");
    Quit("*** Program halted!");
  end;
end;

begin
  IsM:=Ask("Wanna create M or J set (M/J)? ",'M','J');
  if IsM then begin
    ReadComplex("cmin",min);
    ReadComplex("cmax",max);
  end else begin
    ReadComplex("zmin",min);
    ReadComplex("zmax",max);
    ReadComplex("c",c);
  end;
  CheckInput;
end;

procedure MakeFractal;
var
  z	: complex;
  dx,dy : real;
  x,y,
  Mx,My : short;

function iterate: byte; { z -> z²+c; }
			{ z²=(a+bi)²=a²-b²+2abi; }
var
  r	: real;
  count : byte;

begin
  count:=0;
  repeat
    r := z.Re;
    z.Re := sqr(z.Re) - sqr(z.Im) + c.Re;
    z.Im := 2 * r * z.Im + c.Im;
    inc(count);
  until (count = 31) or (sqr(z.Re) + sqr(z.Im) > 4);
  if count=31 then iterate:=0 else iterate:=count;
end;

begin
  Mx := GetMaxX; My := GetMaxY;
  dx := (max.Re - min.Re) / succ(Mx);   { scale }
  dy := (max.Im - min.Im) / succ(My);

  for y:=0 to My do begin
    if IsM then c.Im := min.Im + y * dy;
    for x:=0 to Mx do begin
      if IsM then begin
	c.Re := min.Re + x * dx;
	z.Re:=0; z.Im:=0;
      end else begin
	z.Re := min.Re + x * dx;
	z.Im := min.Im + y * dy;
      end;
      PutPixel(x,y,iterate);
      if CheckBreak then Quit("User break!");
    end;
  end;

end;

procedure SavePicture;
begin
  if Ask("Wanna save image (y/n)? ",'Y','N') then begin
    write("Filename: ");
    readln(filename);
    write("Writing data...");
    if SaveDisplay(filename)=0 then
      writeln("done!")
    else
      writeln("Error apeared! - Data lost!");
  end;
end;

procedure InitColors;
var
  n : byte;
begin
  for n:= 1 to	7 do SetRGBPalette(n,0,0,n+8);
  for n:= 8 to 15 do SetRGBPalette(n,n,0,15);
  for n:=16 to 23 do SetRGBPalette(n,15,0,23-n);
  for n:=24 to 31 do SetRGBPalette(n,38-n,0,38-n);
end;

begin
  AttachGraph;
  InitGraph(320,256,5,LoRes);
  if GraphResult<>0 then begin
    writeln("Error! Could not get a display!");
    writeln("*** Program halted!");
    exit(20);
  end;
  filename:=AllocString(255);
  SetVisualPage(WBPage);
  InitColors;
  writeln;
  writeln("Construction-kit for M and J sets");
  writeln("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
  UserInput;
  write("Rendering in progress...");
  SetVisualPage(0);
  MakeFractal;
  SetVisualPage(WBPage);
  writeln("done!");
  SavePicture;
  Quit("bye!");
end.


