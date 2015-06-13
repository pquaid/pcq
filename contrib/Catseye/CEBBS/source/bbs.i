Const

	cripple : boolean = FALSE;

	{ The CrippleWare flag. If set to TRUE, the program will
	  compile in the demo mode. (It will only set itself up
	  locally.) }

	version : string = "CEBBS v1.11";

	NumData = 150;

	numbases = 26;

	Max_mail = 15;

	{ Prompt Prefs flags }

	pr_none		= 0;
	pr_menu		= 1;
	pr_branch	= 2;
	pr_msg		= 4;
	pr_time		= 8;
	pr_summary	= 16;

	{ Readstring flags }

	rs_none		= 0;
	rs_password	= 1;
	rs_field	= 2;
	rs_caps		= 4;
	rs_capfirsts	= 8;
	rs_nums		= 16;
	rs_noecho	= 32;
	rs_overboard	= 64;

	{ Send_file flags }

	sf_none		= 0;
	sf_noatcodes	= 1;
	sf_skiphead	= 2;

type

	ANSI = (Red, DkGray, LtRed, Blue, Magenta, LtBlue, Yellow,
		Green, Brown, LtGreen, LtMag, Cyan, Gray, LtCyan, White,
		Black, None);

	BBSMenu = (main_menu, message_menu, mail_menu, sysop_menu,
		text_menu, vote_menu, chat_menu, user_menu,
		prefs_menu, doors_menu, file_menu, prune_menu, stats_menu);

	Branchtype = (noecho, echomail, fidoecho, rno, zany);

	BBStype = record
		calls		: integer;
		lmsg,
		fmsg,
		nummsgs,
		maxmsgs		: array [1.. numbases] of integer;
		postrank,
		readrank,
		textrank,
		filerank	: array [1.. numbases] of byte;
		bt		: array [1.. numbases] of BranchType;
		name		: array [1.. numbases] of string;
		end;

const

	BTEnglish : array [noecho..zany] of string =
		("Local",
		 "Echo",
		 "FIDOnet Echo",
		 "Real names only",
		 "fUnKy");

	ANSIenglish : array ['A'..'D'] of string =
		("No ANSI",
		 "ANSI cursor only",
		 "Monochrome ANSI",
		 "Colour ANSI");

	ANSIcolourenglish : array [Red..None] of string =
		("   Red   ",
		 "Dk. Grey ",
		 " Lt. Red ",
		 "   Blue  ",
		 " Magenta ",
		 "Lt. Blue ",
		 "  Yellow ",
		 "  Green  ",
                 "  Brown  ",
                 "Lt. Green",
                 "Lt. Mag. ",
                 "   Cyan  ",
                 "   Grey  ",
                 "Lt. Cyan ",
                 "  White  ",
                 "  Black  ",
                 "   None  ");

	Protoenglish : array ['A'..'F'] of string =
		("XModem",
		 "XModem CRC",
		 "XModem - 1K",
		 "YModem",
		 "YModem - 1K",
		 "ZModem");

	mprompt : array [main_menu..stats_menu] of string =
		("Root Menu",
		 "Read Message",
		 "Read Mail",
		 "Sysop Access",
		 "Text Section",
		 "Voting Booth",
		 "Chat Menu",
		 "User Menu",
		 "Preferences",
		 "Doors Menu",
		 "File Xfer Menu",
		 "Prune Branch Menu",
		 "Stats Menu");

type
	Message_header = record
			num		: short;
			userto,
			poster,
			userfrom,
			re,
			blankline	: array [1..90] of char;
			s		: integer;
			end;

	user =	record
		handle,		{ User handle }
		name,		{ Real name }
		password	: array [1..25] of char; { user password }
		phone		: array [1..15] of char; { phone number }
		byear		: short;	{ year of birth (NI) }
		month,				{ month (NI) }
		day		: byte;		{ day (NI) }
		access		: byte;		{ rank/access level }
		animeacc,		{ obsolete }
		haveansi,		{ ANSI compat. (A/B/C/D) }
		xpert,			{ XPert mode (Y/N) }
		linenoise,		{ obsolete }
		proto,			{ Protocol (A-F(?)) }
		IBMchars,		{ IBM characters (Y/N) }
		cols,			{ cols (use ord()) }
		rows,			{ rows (use ord()) }
		filter,			{ non-ASCII filter (Y/N) }
		cls		: char; { clear screens? (Y'N) }
		calls,			{ number of calls }
		posts		: short;{ number of posts }
		Kul,			{ kilobytes uploaded }
		Kdl		: integer;	{ downloaded }
		Ful,			{ files uploaded }
		Fdl		: short;	{ downloaded }
		Space		: short;	{ space taken up (?!) }
		pad		: array [1..10] of short;
					{ padding so we don't get hurt }
		S		: Integer;	{ last call at S seconds }
		last		: array [1..26] of integer;
					{ last message read for each branch }
		end;

	prefs = record
		back,
		normal,
		prompt,
		branch,
		name,
		field,
		key,
		alert,
		rank,
		delim	: ANSI;
		ANSIpad : array [1..11] of ANSI;
		msgfmt,
		pr	: byte;
		macro	: array [1..80] of char;
		_	: char;			{ obsolete }
		disable	: array [1..numbases] of boolean;
		cls	: char;
		end;

	bbs_file = record
		name,
		comment,
		uploader	: string;
		num_dls		: short;
		S		: integer;
		end;

	Event_Type = (ET_None, ET_Time_Up, ET_FIDO_Time);

	bbs_event = record
		ET	: Event_Type;
		S	: integer;
		next	: ^bbs_event;	{ I doubt I'll need it but... }
		end;

	bbs_eventptr	= ^bbs_event;

var
	ReadSer_Req,				{ Talking to the modem }
	WriteSer_Req	: IOExtSerPtr;
	rs_in, rs_out	: Array [0..1] of char;	{ characters from modem }
	CIA_ptr		: CIAPtr;		{ to get CD/TR }
	WriteReq	: IOStdReqPtr;		{ Write to the console }
	WritePort	: MsgPortPtr;

	globalchar	: char;		{ last char read from modem/console }

	local,				{ local log-in }
	full,				{ full screen? }
	abort,				{ abort pending whatnot }
	online,				{ external call }
	usermask,			{ user cannot type when this is on }
	rc				{ looks cool when yer tipsy }
			: boolean;

	CurUser		: User;		{ user who's currently logged in }
	Curbranch	: char;		{ the current branch }
	Curmessage	: integer;	{ the current message }
	CurMail		: short;	{             mail }
	mess		: string;	{ message text }

	MH_Read,
	MH_Post,
	MH_MailRead,
	MH_MailPost	: Message_Header;	{ various message headers }

	BBSData		: array [1..numdata] of string;
				{ holds the text data for prompts and such }
	BBSinfo		: BBStype;
				{ hold ALL th important data (msgs, etc) }
	S		: ScreenPtr;		{ our screen (could be WB) }
	W		: WindowPtr;		{ our window }
	IM		: IntuiMessagePtr;	{ our intuition message }

	lastuser	: array [0..30] of char; { last user to log on }
	scratch		: array [0..80] of char; { what they said ... }

	results,
	results2	: array [1..100] of char; { voting booth stuffs }

	ff		: ^byte;	{ ff points to the CIA chip }

	curpr		: prefs;	{ current prefs }
	curmenu		: BBSmenu;	{ current menu }
