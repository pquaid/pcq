procedure Show_menu;

begin
case curmenu of
	main_menu : if ord(curuser.cols) < 80 then
		send_file("BBStxt:main_menu.txt", sf_none)
		else send_file ("BBStxt:main_menu80.txt", sf_none);
	text_menu : send_file("BBStxt:text_menu.txt", sf_none);
	vote_menu : send_file("BBStxt:vote_menu.txt", sf_none);
	sysop_menu : send_file("BBStxt:sysop_menu.txt", sf_none);
	user_menu : send_file("BBStxt:user_menu.txt", sf_none);
	chat_menu : send_file("BBStxt:chat_menu.txt", sf_none);
	stats_menu : send_file("BBStxt:stats_menu.txt", sf_none);
	prefs_menu : send_file("BBStxt:prefs_menu.txt", sf_none);
	doors_menu : send_file("BBStxt:doors_menu.txt", sf_none);
	file_menu : send_file("BBStxt:file_menu.txt", sf_none);
	prune_menu : send_file("BBStxt:prune_menu.txt", sf_none);
	stats_menu : send_file("BBStxt:stats_menu.txt", sf_none);
	mail_menu : send_file("BBStxt:mail_menu.txt", sf_none);
	message_menu : send_file("BBStxt:message_menu.txt", sf_none);
	end;
end;

procedure help_file;

begin
	case curmenu of
		main_menu : send_file("BBStxt:main_help.txt", sf_none);
		text_menu : send_file("BBStxt:text_help.txt", sf_none);
		vote_menu : send_file("BBStxt:vote_help.txt", sf_none);
		sysop_menu : send_file("BBStxt:sysop_help.txt", sf_none);
		chat_menu : send_file("BBStxt:user_help.txt", sf_none);
		user_menu : send_file("BBStxt:chat_help.txt", sf_none);
		stats_menu : send_file("BBStxt:stats_help.txt", sf_none);
		prefs_menu : send_file("BBStxt:prefs_help.txt", sf_none);
		doors_menu : send_file("BBStxt:doors_help.txt", sf_none);
		file_menu : send_file("BBStxt:file_help.txt", sf_none);
		prune_menu : send_file("BBStxt:prune_help.txt", sf_none);
		mail_menu : send_file("BBStxt:mail_help.txt", sf_none);
		message_menu : send_file("BBStxt:mess_help.txt", sf_none);
	end;
end;
