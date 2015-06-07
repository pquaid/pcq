Program WhichFont;

{
 sample program that asks AvailFonts() to make a list of the fonts
 that are available and makes a list of them, then opens a separate
 window and prints a description of the various attributes that can
 be applied to the fonts, in the font itself.  Notice that not all
 fonts accept all attributes (garnet9 for example, won't underline)

 Also note, if you run this, that not all fonts are as easily readable
 in the various bold and italicized modes.... this rendering is done
 in a fixed manner by software and the fonts were not necessarily
 designed to accept it.  It is always best to have a font that has
 been designed with a bold or italic characteristic built-in rather
 than try to bold-ize or italicize and existing plain font.
}

{ Author:  Rob Peck  10/28/85  }
{ Converted to PCQ Pascal 2/7/90.  For how little it does, this
  program sure does use a lot of include files... }

{$I "Include:Graphics/Graphics.i"}
{$I "Include:Graphics/Text.i"}
{$I "Include:Graphics/Pens.i"}
{$I "Include:Libraries/DiskFont.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Interrupts.i"}
{$I "Include:Graphics/RastPort.i"}
{$I "Include:Libraries/DOS.i"}

Const
    AFTABLESIZE = 2000;

Var
    af  : AvailFontPtr;
    afh : AvailFontsHeaderPtr;

    tf  : TextFontPtr;
    ta  : TextAttr;

Const
    nw : NewWindow = (
	10, 10,        { starting position (left,top) }
	620,40,        { width, height }
	-1,-1,          { detailpen, blockpen }
	CLOSEWINDOW_f,  { flags for idcmp }
	WINDOWCLOSE + WINDOWDEPTH + WINDOWSIZING + WINDOWDRAG +
	SIMPLE_REFRESH + ACTIVATE + GIMMEZEROZERO,
			{ window gadget flags }
	Nil,              { pointer to 1st user gadget }
	Nil,           { pointer to user check }
	"Text Font Test", { title }
	Nil,           { pointer to window screen }
	Nil,           { pointer to super bitmap }
	100,45,         { min width, height }
	640,200,        { max width, height }
	WBENCHSCREEN_f);

Var
    w  : WindowPtr;
    rp : RastPortPtr;

Const
    text_styles : Array [0..6] of Short = (
	FS_NORMAL, FSF_UNDERLINED, FSF_ITALIC, FSF_BOLD, 
	FSF_ITALIC + FSF_BOLD, FSF_BOLD + FSF_UNDERLINED,
	FSF_ITALIC + FSF_BOLD + FSF_UNDERLINED);

     text_desc : Array [0..6] of String = (
	" Normal Text", " Underlined", " Italicized", " Bold", 
	" Bold Italics", " Bold Underlined", 
	" Bold Italic Underlined");

    text_length : Array [0..6] of Short = (12, 11, 11, 5, 13, 16, 23);

    pointsize  : Array [0..31] of String = (
	" 0"," 1"," 2"," 3"," 4"," 5"," 6"," 7"," 8"," 9",
	"10","11","12","13","14","15","16","17","18","19",
	"20","21","22","23","24","25","26","27","28","29",
	"30","31");

Var
    fontname	: Array [0..40] of Char;
    dummy	: Array [0..100] of Char; { provided for string length calculation }
    outst	: Array [0..100] of Char;
			{ build something to give to Text, see note in 
                         the program body about algorithmically
                         generated styles 
                         }

var
    fonttypes	: Byte;
    i,j,k,m	: Integer;
    afsize	: Short;
    style	: Short;
    sEnd	: Short; { Numerical position of end of string terminator }
    styleresult : Short;

Procedure Leave(r : Integer);
begin
    Exit(20);
end;

Function IsCopy(af : AvailFontPtr) : Boolean;
begin
    IsCopy := 	(((af^.af_Attr.ta_Flags and FPF_REMOVED) <> 0) or
		((af^.af_Attr.ta_Flags and FPF_REVPATH) <> 0) or
		(((af^.af_Type and AFF_MEMORY) <> 0) and
		((af^.af_Attr.ta_Flags and FPF_DISKFONT) <> 0)));

       { do nothing if font is removed, or if
	 font designed to be rendered rt->left
	 (simple example writes left to right)
	 or if font both on disk and in ram, 
	 don't list it twice. }

       { AvailFonts performs an AddFont to the system list;
	 if run twice, you get two entries, one of "af_Type 1" saying
	 that the font is memory resident, and the other of "af_Type 2"
	 saying the font is disk-based.  The third part of the 
	 if-statement lets you tell them apart if you are scanning
	 the list for unique elements;  it says "if its in memory and
	 it is from disk, then don't list it because you'll find another
	 entry in the table that says it is not in memory, but is on disk.
	 (Another task might have been using the font as well, creating
	 the same effect).
	}
end;

Begin
    DiskFontBase := OpenLibrary("diskfont.library",0);
    if DiskFontBase = Nil then
	leave(-4);
    GfxBase := OpenLibrary("graphics.library",0);
    if GfxBase = Nil then
	leave(-3);

    tf := Nil;        { no font currently selected }
    afsize := AFTABLESIZE;   { show how large a buffer is available }
    fonttypes := $ff;       { show us all font types }

    w := OpenWindow(Adr(nw));
    if w <> nil then begin
	rp := w^.RPort;

	afh := AvailFontsHeaderPtr(AllocString(afsize));

	Move(rp, 10, 20);
	GText(rp, "Searching for fonts",19);
	j := AvailFonts(afh, afsize, fonttypes);

	for m := 0 to 1 do begin
	    SetAPen(rp,1);

	    if m = 0 then
		SetDrMd(rp,JAM1)
	    else
		SetDrMd(rp,JAM1+INVERSVID);

        { now print a line that says what font and what style it is }

	    for j := 0 to Pred(afh^.afh_NumEntries) do begin
		af := Adr(afh^.afh_AF[j]);
		strcpy(String(Adr(FontName)), af^.af_Attr.ta_Name);
                        { copy name into build-name area }
                        { already has ".font" onto end of it }
		ta.ta_Name := String(Adr(fontname));
		ta.ta_YSize := af^.af_Attr.ta_YSize;     { ask for this size }
		ta.ta_Style := af^.af_Attr.ta_Style;     { ask for designed style }
		ta.ta_Flags := FPF_ROMFONT + FPF_DISKFONT +
				FPF_PROPORTIONAL + FPF_DESIGNED;
                { accept it from anywhere it exists }
		style := ta.ta_Style;

		if not IsCopy(af) then begin
		    tf := OpenDiskFont(Adr(ta));
		    if tf <> Nil then begin
			SetFont(rp, tf);
			for k := 0 to 6 do begin
			    style := text_styles[k];
			    styleresult := SetSoftStyle(rp,style,255);
			    SetRast(rp,0);   { erase any previous text }
			    Move(rp,10,20);  { move down a bit from the top }
			    strcpy(Adr(outst), af^.af_Attr.ta_Name);
			    strcat(Adr(outst), "  ");
			    strcat(Adr(outst), PointSize[af^.af_Attr.ta_YSize]);
			    strcat(Adr(outst), " Points, ");
			    strcat(Adr(outst), text_desc[k]);
			    GText(rp,Adr(outst),strlen(Adr(outst)));
	{
	Have to build the string before sending it out to
	text IF ALGORITHMICALLY GENERATING THE STYLE since 
	the kerning and spacing tables are based on the
	vanilla text, and not the algorithmically generated
	style.  If you send characters out individually,
	it is possible that the enclosing rectangle of
	a later character will chop off the trailing edge
	of a preceding character 
	}

	{ ************************************************** 
	  This alternate method, when in INVERSVID, exhibits the
	  problem described above.
 
			GText(rp,af^.af_Attr.taName,strlen(af^.af_Attr.taName));
			GText(rp,"  ",2);
			GText(rp,pointsize[af^.af_Attr.taYSize],2);
			GText(rp," Points, ",9);
        
			GText(rp,text_desc[k],text_length[k]);
	  **************************************************  } 

			    Delay(40);  { use the DOS time delay function 
					  specifies 60ths of a second }
			    if GetMsg(w^.UserPort) <> Nil then begin
				CloseFont(tf);
				Forbid;
				repeat until GetMsg(w^.UserPort) = Nil;
				CloseWindow(w);
				Permit;
				CloseLibrary(DiskfontBase);   
				CloseLibrary(GfxBase);
				exit(0);
			    end;
			end;
			CloseFont(tf); { close the old one }

       { NOTE: 
            Even though you close a font, it doesn't get unloaded
            Memory unless a font with a different name is specified
            for loading.  In this case, any font (except the topaz
            set) which has been closed can have its memory area
            freed and it will no longer be accessible.  If you close
            a font to go to a different point-size, it will NOT cause
            a disk-access.  
       
         ALSO NOTE:   
             Loading a font loads ALL of the point
             sizes contained in that font's directory!!!!
        }
		    end;
		end;
	    end;
	end;
	CloseWindow(w);
    end;
    CloseLibrary(DiskfontBase);   
    CloseLibrary(GfxBase);
end.
