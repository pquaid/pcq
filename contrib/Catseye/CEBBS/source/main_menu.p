{

***********************************************************
**  CEBBS MENU PROCESSOR        by: Chris A. Pressey     **
**  based upon						 **
**  MAIN MENU PROCESSOR         by: David R. Stromberger **
**  main_menu.p                 date:  2-25-89           **
***********************************************************

}

procedure main;

var
	temp,
	temp2,
	i			: integer;
	hangup			: boolean;
	ct,
	ct2			: char;
	ts,
	b,
	g,
	h,
	fstring,
	gstring			: String;

	Procedure global_menu;

	begin
	case ct of
		'?': begin
			if (toupper(curuser.xpert) = 'Y') then show_menu;
			if (curmenu = message_menu) and (curuser.xpert <> 'Y') then show_menu;
		     end;
		'H': help_file;
		'Q': begin
			if curmenu <> main_menu then
				curmenu := main_menu;
		     end;
		'J': begin
			jump_to_branch;
			if curuser.xpert <> 'Y' then tapreturn;
			if curmenu = message_menu then
				begin
				if not read_message(curmessage) then;
				end;
		     end;
		end;
	end;

	procedure mm;

	begin
	case ct of
		'C': curmenu := chat_menu;
		'T': if verify_rank(10) then curmenu := text_menu;
		'G': begin
			saveuser;
			hangup := LogOff;
			end;
		'U': show_userlist;
		'E': if verify_rank (10) then post_message;
		'P': if verify_rank (10) then
			begin
			if curuser.access < 200 then
				branch_stats else
				curmenu := prune_menu;
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'R': begin
			curmenu := message_menu;
			curmessage := curuser.last[cb] + 1;
			if curmessage > bbsinfo.lmsg[cb] then dec (curmessage);
			if not read_message(curmessage) then;
			end;
		'A': if read_my_mail then
			begin
			curmail := 0;
			get_next_mail;
			curmenu := mail_menu;
			end;
		'M': if verify_rank (10) then mail_chute;
		'Y': curmenu := stats_menu;
		'D': if verify_rank (10) then
			begin
			send_file ("BBSTXT:door_menu.txt", sf_none);
			sendstring ("\n\nSorry, all doors nailed shut.\n\n");
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'V': if verify_rank (10) then curmenu := vote_menu;
		'S': if verify_rank(255) then curmenu := sysop_menu else
			begin
			sendstring (bbsdata[17]);
			readstring (ts, "none", 30, rs_password);
			sendstring ("\n");
			if strieq (ts, bbsdata[22]) then
				curmenu := sysop_menu else
				sendstring (bbsdata[54]);
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'L': leave_feedback;
		'O': obtain_time;
		'B': list_branches;
		'F': if verify_rank (100) then curmenu := file_menu;
		end;
	end;

	procedure cm;

	begin
	case ct of
		'C':	begin
			sendstring ("\nPaging...\n");
			strcpy (fstring, "say Yo Cat's Eye. ");
			strcat (fstring, adr(curuser.handle));
			strcat (fstring, " wants to babble at you");
			exec_command (fstring);
			end;
		'S':	begin
			sendstring ("\nPaging...\n");
			strcpy (fstring, "say Hile Shrapnel. ");
			strcat (fstring, adr(curuser.handle));
			strcat (fstring, " wants to talk to you");
			exec_command (fstring);
			end;
		'A':	begin
			sendstring ("\nPaging...\n");
			strcpy (fstring, "say Yo, guys, ");
			strcat (fstring, adr(curuser.handle));
			strcat (fstring, " wants to chat");
			exec_command (fstring);
			end;
		end;
	end;

	procedure pm;

	begin
	case ct of
		'V':	begin
			branch_stats;
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'T': with bbsinfo do
			begin
			sendstring ("Branch type : ");
			sendstring (BTEnglish[bt[cb]]);
			sendstring ("\n(L)ocal (E)cho (F)IDO (R)NO f(U)nKy > ");
			ct := readoption ('A','Z');
			sendstring ("\n");
			case ct of
				'L' : bt[cb] := noecho;
				'E' : bt[cb] := echomail;
				'F' : bt[cb] := fidoecho;
				'R' : bt[cb] := rno;
				'U' : bt[cb] := zany;
				else bt[cb] := noecho;
				end;
			saveindex;
			end;
		'N':	begin
			sendstring ("Name of branch : '");
			sendstring (bbsinfo.name[cb]);
			sendstring ("'\nNew name > ");
			readstring (gstring, bbsinfo.name[cb], 40, rs_field);
			strcpy (bbsinfo.name[cb], gstring);
			saveindex;
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'A':	prune ("Access Level > ", bbsinfo.readrank[cb]);
		'P':	prune ("Posting Access Level > ", bbsinfo.postrank[cb]);
		'X':	prune ("Text File Access Level > ", bbsinfo.textrank[cb]);
		'F':	prune ("File Xfers Access Level > ", bbsinfo.filerank[cb]);
		end;
	end;

	procedure fm;

	const

		liststring
		: string = "FILES:A -s -w0";

	begin
	liststring[6] := curbranch;
	case ct of
		'D':	begin
			sendstring ("File name ? ");
			readstring (ts, "none", 30, rs_field + rs_caps);
			download (ts);
			end;
		'U':	begin
			sendstring ("File name ? ");
			readstring (ts, "none", 30, rs_field + rs_caps);
			upload (ts);
			end;
		'L':	begin
			if SList (liststring, "%N  %C%R") then;
			end;
		end;
	end;

	procedure tm;

	const

		liststring
		: string = "TXT:A -s -w0";

	begin
	liststring[4] := curbranch;
	case ct of
		'R':	begin
			sendstring (bbsdata[92]);
			readstring (gstring, "", 4, rs_nums);
			if strlen (gstring) <> 0 then
				begin
				strcpy (fstring, "TXT:1/");
				fstring [4] := curbranch;
				strcat (fstring, gstring);
				clear_terminal;
				send_file (fstring, sf_none);
				end;
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'L':	begin
			clear_terminal;
			sendstring (bbsdata[98]);
			if SList (liststring, "%N. %C%R") then;
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		end;
	end;

begin
fstring := AllocString (90);
gstring := AllocString (90);
g := allocstring (25);
h := allocstring (25);
ts := allocstring (50);
hangup := false;

werein;

while(not hangup) do
    begin
    if (toupper(curuser.xpert) <> 'Y') then show_menu;
    sendprompt (mprompt[curmenu]);
    ct := toupper(readoption ('A','Z'));
    sendstring("\n");
    case curmenu of
	main_menu : mm;
	chat_menu : cm;
	prune_menu : pm;
	file_menu : fm;
	text_menu : tm;
	vote_menu : case ct of
		'N': begin
		     loadresults (bbsdata [2]);
			results2 := results;
		     loadresults (adr(curuser.handle));
		     for i := 1 to 100 do
			if (results[i] = '@') and (results2[i] <> '@') then
			begin
			strcpy (fstring, "type >ram:vl VOTE:00*");
			fstring [18] := char(i div 10 + ord('0'));
			fstring [19] := char(i mod 10 + ord('0'));
			exec_command (fstring);
			clear_terminal;
			poll ("RAM:vl");
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		     end;
		'V':	begin
			sendstring (bbsdata[100]);
			readstring (gstring, "01", 4, rs_nums);
			strcpy (fstring, "type >T:vl VOTE:");
			strcat (fstring, gstring);
			exec_command (fstring);
			clear_terminal;
			poll ("T:vl");
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'R':	begin
			sendstring (bbsdata[104]);
			readstring (gstring, "01", 4, rs_nums);
			strcpy (fstring, "type >t:vl VOTE:");
			strcat (fstring, gstring);
			clear_terminal;
			exec_command (fstring);
			seeresults((ord(gstring[0])-ord('0')) * 10 + (ord(gstring[1])-ord('0')), "RAM:vl");
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'L':	begin
			sendchar (char(12));
			sendstring (bbsdata[99]);
			if SList ("VOTE: -s -w0", "%N. %C%R") then;
			sendstring("\n");
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'S': if verify_rank(255) then
			begin
			sendstring ("Who > ");
			readstring (fstring, adr(curuser.handle), 50, rs_field + rs_caps);
			snoop_results (fstring);
			end;
		'A': if verify_rank(255) then add_poll;
		end;
	sysop_menu : case ct of
		'R':	begin
			sendstring (bbsdata[92]);
			readstring (gstring, "x", 80, rs_none);
			send_file(gstring, sf_noatcodes);
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'X':	begin
			sendstring (bbsdata[93]);
			readstring (gstring, "x", 80, rs_none);
			exec_command (gstring);
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'K':	begin
			sendstring (bbsdata[94]);
			readstring (gstring, "", 80, rs_none);
			if not deletefile(gstring) then
				sendstring (bbsdata[45]) else
				sendstring (bbsdata[46]);
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'S':	begin
			sendstring (bbsdata[95]);
			readstring (gstring, adr(curuser.handle), 80, rs_caps);
			snoop (gstring);
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'A':	begin
			sendstring (bbsdata[96]);
			readstring (gstring, adr(curuser.handle), 80, rs_caps);
			snoop (gstring);
			changerank (gstring);
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'U':	begin
			user_lister;
			show_userlist;
			end;
		end;
	stats_menu : case ct of
		'A' :	begin
			changeansi;
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'T' :	begin
			changeprotocol;
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'C' :	begin
			changecols;
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'I' : begin
			clear_terminal;
			send_file ("BBSTXT:userstats1.txt", sf_none);
			curuser.ibmchars := readoption ('Y','N');
			end;
		'F' : begin
			clear_terminal;
			send_file ("BBSTXT:userstats2.txt", sf_none);
			curuser.filter := readoption ('Y','N');
			end;
		'X' : begin
			if (toupper(curuser.xpert) = 'Y') then
				curuser.xpert := 'N' else
				curuser.xpert := 'Y';
			if (toupper(curuser.xpert) = 'Y') then
				sendstring (bbsdata[86]) else
				sendstring (bbsdata[87]);
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		'V' : begin
			snoop (adr(curuser.handle));
			if curuser.xpert <> 'Y' then tapreturn;
			end;			
		'P' : begin
			sendstring (bbsdata[88]);
			readstring (g, adr(curuser.password), 25, rs_field);
			sendstring ("\n");
			sendstring (bbsdata[89]);
			readstring (h, adr(curuser.password), 25, rs_password);
			sendstring ("\n");
			if strieq (g, h) then
				begin
				sendstring (bbsdata[90]);
				strcpy (adr(curuser.password), g);
				end else
				begin
				sendstring (bbsdata[91]);
				end;
			if curuser.xpert <> 'Y' then tapreturn;
			end;
		end;
	mail_menu :
		begin
			case ct of
				'E': mail_chute;
				'A': if read_mail (curmail) then;
				'K': begin
					kill_mail (curmail);
					get_next_mail;
					{ if no more mail then exit }
					end;
				'R': mail_reply;
				'N': begin
					get_next_mail;
					if read_mail (curmail) then;
					end;
				'B': begin
					get_prev_mail;
					if read_mail (curmail) then;
					end;
				end;
		end;
	message_menu :
		begin
		if curmessage > curuser.last[cb] then
			curuser.last[cb] := curmessage;
		case ct of
			'E': post_message;
			'N',' ','\0','\n','\r': begin
						abort := false;
						fwd_message;
						if abort then curmenu := main_menu;
						end;
			'B': back_message;
			'A': if not read_message (curmessage) then;
			'R': reply_to_message;
			'K': kill_message (curmessage);
			'G': with bbsinfo do
				begin
				sendstring (bbsdata[111]);
				curmessage := readnum ("9999");
				if curmessage > lmsg[cb] then curmessage := lmsg[cb];
				if curmessage < fmsg[cb] then curmessage := fmsg[cb];
				if not read_message (curmessage) then;
				end;
			'M': scan_to (adr(curuser.handle), 1);
			'T': scan_re (adr(MH_Read.re), 1);
			'U': scan_re (adr(MH_Read.re), -1);
			end;
		end;
	end;
    global_menu;
    if not check_carrier then
	begin
	hangup := true;
	emits ("***\n");
	end;
   end;
SetVars;
freestring (ts);
SetWindowTitles(w, version, version);
if local then closeup;
end;
