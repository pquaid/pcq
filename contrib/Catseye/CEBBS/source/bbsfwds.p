procedure setvars;
	forward;
function getrank (ch : char) : byte;
	forward;
procedure emit(c : char);
	forward;
procedure emits(s : string);
	forward;
procedure sendchar(ch : char);
	forward;
procedure sendstring(s : string);
	Forward;
procedure sendnum(d : integer);
	Forward;
function readnum (def : string) : integer;
	Forward;
Procedure leave_feedback;
	Forward;
procedure mail_chute;
	Forward;
procedure login;
	Forward;
procedure send_file(filename : string; flags : short);
	Forward;
procedure chat_withem(sysop : short);
	Forward;
function readchar : char;
	Forward;
function check_carrier : boolean;
	Forward;
procedure readstring(st, def : string; number : integer; flags : short);
	Forward;
procedure check_userfile;
	Forward;
procedure show_userlist;
	Forward;
procedure join_bbs;
	Forward;
procedure main;
	Forward;
function read_message (num : short) : boolean;
	Forward;
Procedure save_message;
	Forward;
Procedure save_mail (userto : string; nombre : short);
	Forward;
Procedure closeup;
	Forward;
function enter_message : boolean;
	Forward;
procedure post_message;
	Forward;
procedure snoop (d : string);
	Forward;
procedure changerank (d : string);
	Forward;
procedure sysopq (d : string);
	Forward;
procedure q2;
	Forward;
procedure pre_read_message (num : short; var fstr : string;
			var MH : message_header);
	Forward;
function verify_message (num : short) : boolean;
	Forward;
procedure fwd_message;
	Forward;
procedure back_message;
	Forward;
function readoption (lowchar, hichar : char) : char;
	Forward;
Procedure SetDTR(setit : boolean);
	Forward;
Procedure purge_line;
	Forward;
function logoff : boolean;
	Forward;
Procedure loadindex;
	Forward;
Procedure saveindex;
	Forward;
Procedure SaveUser;
	Forward;
procedure tapreturn;
	Forward;
procedure sendrank (lev : short);
	Forward;
function verify_rank(lev : short) : boolean;
	Forward;
function verify_user (var d : string) : boolean;
	Forward;
Procedure exec_command (com : string);
	Forward;
procedure chat_request;
	Forward;
procedure jump_to_branch;
	Forward;
procedure obtain_time;
	Forward;
procedure list_branches;
	Forward;
procedure loadbbsdata;
	Forward;
Procedure sendprompt (s : string);
	Forward;
procedure word_wrap (s : string; cols : short);
	Forward;
procedure new_branch;
	Forward;
procedure time_info (var st : string; s : integer);
	Forward;
procedure scan_to (uto : string; dir : short);
	Forward;
procedure scan_re (uto : string; dir : short);
	Forward;
procedure hang_up;
	Forward;
procedure openmodem;
	Forward;