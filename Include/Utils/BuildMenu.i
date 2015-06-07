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
    You must detach your menu before closing the window.

    The source code for these routines is under Runtime/Extras

}

{$I "Include:Intuition/Intuition.i" for WindowPtr }

Procedure DisposeMenu;
    External;
{
    Free the memory used by the menu strip.  Be sure the menu
    is not currently displayed, or havoc will ensue.
}

Procedure InitializeMenu(w : WindowPtr);
    External;
{
    Set up the BuildMenu system will some useful defaults.  w must
    point to a valid, open window.
}

Procedure NewMenu(str : String);
    External;
{
    Add a new menu to the menu strip.  You must call InitializeMenu
    before this, and you must call this at least once before you call
    NewItem or NewSub.
}

Procedure NewItem(name : String; comm : Char);
    External;
{
    Add an item to the previously defined menu.  You must call
    NewMenu before you call this.  'name' is the text to print
    in the box, and 'comm' is the keyboard equivalent.  If there
    isn't a keyboard equivalent, use '\0' (zero byte).

    If you pad out all the menu item names to the same number of
    characters (using spaces at the end), the user will have an
    easier time using the menu.
}

Procedure NewSubItem(name : String; comm : Char);
    External;
{
    Add a sub-menu to the current menu item.  You must call NewItem
before you call this.  The parameters and caveats are the same as
NewItem.
}

Procedure AttachMenu;
    External;
{
    Attach the menu strip you've been designing to the window you
    specified in your call to InitializeMenu.  This hands the structure
    over to Intuition, which does all the real work.
}

Procedure DetachMenu;
    External;
{
    Remove the menu from the window.  This doesn't deallocate the memory
    or anything traumatic like that.  You can, in fact, reattach the menu
    later by calling AttachMenu.  In order to block the user's access to
    the menu it is generally better to use OnMenu() and OffMenu(),
    especially when you only want to block a few items.

    You must call this routine before closing a window.
}
