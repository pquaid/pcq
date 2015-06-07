External;

{
    BuildMenu.i (of PCQ Pascal)

    These routines provide a simplified interface to the Amiga's
menu system similar to the one in AmigaBASIC, as I recall.  The
price you pay for this situation is, of course, flexibility, but
for many menu systems the plain text will suffice.

    In order to use these routines, first create a window somehow.
Then call InitializeMenu, passing your valid window pointer.
Remember, the window must be open already.
    Then, call NewMenu("Menu Name") with any name you like in order
to set up your first menu.  Then call NewItem("name", 'N') for each
menu item you want to create.  You must call NewMenu before you
call NewItem, and if you don't want a keyboard equivalent of the
menu item, pass in '\0' (null).
    If you want sub-items atached to your menu item, you can call
NewSubItem with the same parameters as NewItem.  Note that you have
to call NewItem at least once before you can call NewSubItem.
    Also note that the order is significant.  If you switch the order
of two menu item definitions, for example, they will appear in the
opposite order in the menu.  Also, all menu items hang off the most
recently defined menu.  Finally, note that these routines define only
one menu strip at a time.

    Once you've got all that done, you call AttachMenu to allow the
user to see and use the menu strip.  Then you'll have to monitor the
IDCMP port of the window (window^.UserPort) for MENUPICK_f messages,
which you can decifer with MenuNum() and ItemNum().  See the Intuition
manual for details.
    If you want to remove the menu from the window, you can call
DetachMenu, but as long as you don't free the memory (see below) you
can reattach the menu later by calling AttachMenu again.  You can also
ghost various parts of the menu using OnMenu() and OffMenu(), but
you'll have to see the Intuition manual to explain how.
    To free up the memory associated with a menu you can call
DisposeMenu.  If you haven't detached your menu the machine will
crash, sooner or later.  You don't have to free the memory, since
the termination code will do it for you.
}

{$I "Include:Intuition/Intuition.i" for IntuiText }
{$I "Include:Graphics/RastPort.i" for the RP definition }
{$I "Include:Graphics/Text.i" for the TextAttr stuff }
{$I "Include:Utils/StringLib.i" for allocate and deallocate }

{$SP}

const
    FirstMenu   : MenuPtr = Nil;
    CurrentMenu : MenuPtr = Nil;
    CurrentItem : MenuItemPtr = Nil;
    CurrentSub  : MenuItemPtr = Nil;
    MenuWindow	: WindowPtr = Nil;

var
    WindowTextAttr : TextAttr;

{$SX}

Procedure DisposeMenu;

    Procedure DisposeMenuItem(m : MenuItemPtr);
    var
	it : IntuiTextPtr;
    begin
	if m <> Nil then begin
	    DisposeMenuItem(m^.NextItem);
	    DisposeMenuItem(m^.SubItem);
	    it := m^.ItemFill;
	    if it <> nil then begin
		FreeString(it^.IText);
		Dispose(it);
	    end;
	    Dispose(m);
	end;
    end;

    Procedure DisposeMenuRec(m : MenuPtr);
    begin
	if m <> Nil then begin
	    DisposeMenuItem(m^.FirstItem);
	    DisposeMenuRec(m^.NextMenu);
	    FreeString(m^.MenuName);
	    Dispose(m);
	end;
    end;

begin
    DisposeMenuRec(FirstMenu);
    FirstMenu := Nil;
    CurrentMenu := Nil;
    CurrentItem := Nil;
    CurrentSub  := Nil;
end;

Procedure InitializeMenu(w : WindowPtr);
var
    rp : RastPortPtr;
    tf : TextFontPtr;
begin
    MenuWindow := w;
    rp := w^.RPort;
    tf := rp^.Font;
    with tf^ do
	with WindowTextAttr do begin
	    ta_Name  := "";
	    ta_YSize := tf_YSize;
	    ta_Style := tf_Style;
	    ta_Flags := tf_Flags;
	end;
    if FirstMenu <> Nil then
	DisposeMenu;
    FirstMenu := Nil;
    CurrentMenu := Nil;
    CurrentItem := Nil;
end;

Procedure NewMenu(str : String);
var
    m : MenuPtr;
    it : IntuiText;
begin
    new(m);
    with it do begin { So we can get the width }
	LeftEdge := 0;
	TopEdge  := 0;
	ITextFont := Adr(WindowTextAttr);
	IText    := str;
	NextText := Nil;
    end;
    with m^ do begin
	if CurrentMenu = Nil then begin
	    FirstMenu := m;
	    LeftEdge := 5;
	end else begin
	    LeftEdge := CurrentMenu^.LeftEdge + CurrentMenu^.Width + 10;
	    CurrentMenu^.NextMenu := m;
	end;
	CurrentMenu := m;
	NextMenu := Nil;
	TopEdge  := 1;
        Width    := IntuiTextLength(Adr(it)) + 8;
	Height   := WindowTextAttr.ta_YSize + 2;
        Flags    := MenuEnabled;
        MenuName := strdup(str);
	FirstItem := Nil;
    end;
    CurrentItem := Nil;
    CurrentSub  := Nil;
end;

Procedure NewItem(name : String; comm : Char);
var
    mi : MenuItemPtr;
    it : IntuiTextPtr;
begin
    New(it);
    New(mi);
    with it^ do begin
	FrontPen := 3;
	BackPen  := 2;
	DrawMode := 2;
	LeftEdge := 4;
	TopEdge  := 1;
	ITextFont := Nil;
	IText    := strdup(name);
	NextText := Nil;
    end;
    with mi^ do begin
	NextItem := Nil;
	LeftEdge := 5;
	Width    := IntuiTextLength(it) + 10;
	Height   := WindowTextAttr.ta_YSize + 2;
	Flags    := ItemText + ItemEnabled + HighComp;
	if comm <> '\0' then begin
	    Flags := Flags + CommSeq;
	    Command := comm;
	    Width := Width + CommWidth + 10;
	end;
	MutualExclude := 0;
	ItemFill := it;
	SelectFill := Nil;
	SubItem  := Nil;
	NextSelect := 0;
	if CurrentItem = Nil then begin
	    TopEdge := 1;
	    CurrentMenu^.FirstItem := mi;
	end else begin
	    TopEdge := CurrentItem^.TopEdge + WindowTextAttr.ta_YSize + 4;
	    CurrentItem^.NextItem := mi;
	end;
	CurrentItem := mi;
    end;
    CurrentSub := Nil;
end;

Procedure NewSubItem(name : String; comm : Char);
var
    mi : MenuItemPtr;
    it : IntuiTextPtr;
begin
    New(it);
    New(mi);
    with it^ do begin
	FrontPen := 3;
	BackPen  := 2;
	DrawMode := 2;
	LeftEdge := 4;
	TopEdge  := 1;
	ITextFont := Nil;
	IText    := strdup(name);
	NextText := Nil;
    end;
    with mi^ do begin
	NextItem := Nil;
	Width    := IntuiTextLength(it) + 10;
	Height   := WindowTextAttr.ta_YSize + 2;
	Flags    := ItemText + ItemEnabled + HighComp;
	if comm <> '\0' then begin
	    Flags := Flags + CommSeq;
	    Command := comm;
	    Width := Width + CommWidth + 10;
	end;
	MutualExclude := 0;
	ItemFill := it;
	SelectFill := Nil;
	SubItem  := Nil;
	NextSelect := 0;
	if CurrentSub = Nil then begin
	    TopEdge := 1;
	    LeftEdge := (CurrentItem^.LeftEdge + CurrentItem^.Width) - 10;
	    CurrentItem^.SubItem := mi;
	end else begin
	    TopEdge := CurrentSub^.TopEdge + WindowTextAttr.ta_YSize + 2;
	    LeftEdge := CurrentSub^.LeftEdge;
	    CurrentSub^.NextItem := mi;
	end;
	CurrentSub := mi;
    end;
end;

Procedure AttachMenu;
var
    ignore : Boolean;
begin
    ignore := SetMenuStrip(MenuWindow, FirstMenu);
end;

Procedure DetachMenu;
begin
    ClearMenuStrip(MenuWindow);
end;
