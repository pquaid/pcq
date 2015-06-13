Const

	NW : NewWindow = (0, 0, 640, 200, 0, 1,
	   VANILLAKEY_f + MENUPICK_f,
	   SMART_REFRESH + ACTIVATE + WINDOWDEPTH + WINDOWDRAG,
	   nil, nil, nil,
	   nil, nil, 100, 35, 640, 200, WBENCHSCREEN_f);

Procedure makeIntuiMenus;

begin
InitializeMenu (w);
NewMenu (version);
NewItem ("About            ", 'A');
NewItem ("Iconize          ", 'I');
NewItem ("Chat - Sysop     ", 'S');
NewItem ("Chat - Co-Sysop  ", 'C');
NewItem ("Leave chat       ", 'X');
NewItem ("Quit             ", 'Q');
AttachMenu;
end;
