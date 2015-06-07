PROGRAM Mand;

{
	Mandel.p is a Mandelbrot display program written by
	Ralph Seguin, and included in the PCQ distribution with
	his permission.  I don't know what the real and imaginary
	components represent, but the following values produce a
	reasonable image:
		Real component 	: 0.2
		Imaginary comp	: 0.15
		Zoom size	: 0.5
		Iterations	: more than, say, 40
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Graphics/Graphics.i"}
{$I "Include:Graphics/Pens.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Graphics/View.i"}
{$I "Include:Utils/Break.i"}
{$I "Include:Utils/DateTools.i"}

VAR
   H,V: INTEGER;        { Horizontal and vertical looping coordinates. }
   K: INTEGER;          { Generic looping interger from Hell.  FOR K rules! }
   W: WindowPtr;        { A pointer to our custom window after creation. }
   S: Address;        { A pointer to our custom defined screen. }
   RP: RastPortPtr;     { a pointer to a rastport structure (record) so we can do plotting in a rastport (window). }
   CR,CI,T: REAL;       { Current real and imaginary and a temp real. }
   ZR,ZI: REAL;         { Z-real and imaginary coordinates. }
   B: BOOLEAN;          { Generic boolean from hell for loop breaking. }
   MaxIter: INTEGER;    { Maximum number of iterations to perform. }
   RealC,ImgC,Zoom: REAL;   { Coordinates for corner and zoom box size. }
   HoriF,VertF: REAL;     { Horizontal and Vertical Factors. }




PROCEDURE CleanExit(St:STRING; RC:INTEGER);

BEGIN
   IF (W <> NIL) THEN
      CloseWindow(W);

   IF (S <> NIL) THEN
      CloseScreen(S);

   IF (GfxBase <> NIL) THEN
      CloseLibrary(GfxBase);

   WRITELN(St);
   Exit(RC);
END;   { CleanExit() }




PROCEDURE SetColors;

VAR
   K: INTEGER;
   VP: ADDRESS;

BEGIN
   VP := ViewPortAddress(W);

   FOR K := 0 TO 31 DO
      SetRGB4(VP,K,K DIV 2,K MOD 2, K MOD 11);   { Set color K to R,G,B values. }

END;


PROCEDURE Init;

CONST
   NW: NewWindow = (0,19,320,380,1,7,CLOSEWINDOW_f,
                    WINDOWDRAG+WINDOWCLOSE+SMART_REFRESH+BORDERLESS+ACTIVATE,
                    NIL,NIL,"<-- Click me to stop",NIL,NIL,0,0,0,0,CUSTOMSCREEN_f);

   NS: NewScreen = (0,0,320,400,5,1,7,4,CUSTOMSCREEN_f,NIL,
                    "SmallMandel, by Ralph Seguin, ESC Inc.",
                    NIL,NIL);    { Our NewScreen structure }


BEGIN { Init }
   GfxBase := OpenLibrary("graphics.library",0);   { Open up the graphics.library. }
{ The graphics.library contains routines to do all the basic graphics, lines, }
{ circles, etc.  If you plan to use any of these, it is necessary to open this }
{ Always remember to close a library after you are finished using it, otherwise }
{ you will make the system unsafe. }


   IF (GfxBase = NIL) THEN
      CleanExit("Mandel: Couldn't open graphics.library!",20);

   S := OpenScreen(Adr(NS));

   IF (S = NIL) THEN
      CleanExit("Unable to open screen.",5);

   NW.Screen := S;   { We can't assign this dynamically }
   W := OpenWindow(Adr(NW));

   IF (W = NIL) THEN
      CleanExit("Unable to open window.",5);

   SetColors;
   RP := W^.RPort;   { Get a pointer to the rastport for the window we opened. }
{ A rastport is required to do any sort of graphics rendering. }

END;  { Init }


var
    StartTime,
    EndTime : DateDescription;

    Msg : MessagePtr;

BEGIN   { Main }

   WRITELN("       MandelHell 0.15, by Ralph Seguin.");
   WRITELN;
   WRITE("Enter real component: ");
   READLN(RealC);
   WRITE("Enter imaginary component: ");
   READLN(ImgC);
   WRITE("Enter zoom size: ");
   READLN(Zoom);
   WRITE("Maximum iteration count: ");
   READLN(MaxIter);
   Init;   { Initialize globals }
   HoriF := Zoom / 320.0;
   VertF := Zoom / 380.0;

   TimeDesc(StartTime);

   FOR V := 12 TO 380 DO BEGIN
      CI := ImgC + VertF * Float(V);

      FOR H := 1 TO 320 DO BEGIN

         CR := HoriF * Float(H) + RealC;
         ZR := 0.0;
         ZI := 0.0;
         B := TRUE;
         K := 1;

         WHILE ((K <= MaxIter) AND B) DO BEGIN

            T := ZR;
            ZR := Sqr(ZR) - Sqr(ZI) + CR;
            ZI := 2.0 * T * ZI + CI;
            K := SUCC(K);

            IF (Sqr(ZR) + Sqr(ZI) >= 4.0) THEN
               B := FALSE;

         END;   { WHILE (K <= 100 AND B) }

         IF (K < MaxIter) THEN
            SetAPen(RP,K MOD 31 + 1)
         ELSE
            SetAPen(RP,0);

         WritePixel(RP,H,V);
      END;   { FOR H := 1 TO 100 }

      IF (CheckBreak() OR (GetMsg(W^.UserPort) <> NIL)) THEN BEGIN
         WHILE (GetMsg(W^.UserPort) <> NIL) DO ;
         CleanExit("Have a nice day.",0);
      END;

   END;   { FOR V := 1 TO 80 }

   Msg := WaitPort(W^.UserPort);
   repeat
       Msg := GetMsg(W^.UserPort);
       if Msg <> Nil then
           ReplyMsg(Msg);
   until Msg = Nil;
   CleanExit("",0);
END.
