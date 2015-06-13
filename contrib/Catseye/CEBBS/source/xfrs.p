{
***
***   XFRS.P
***
***   Chris Pressey Sept 23 AD 1991
***
***   Uses :
***   XPRGate <device> <unit> <baud> <xpr library> <init string> <R|S> <files>
***
}

procedure upload (filespec : string);

const
	xprrecieve : array ['A'..'F'] of string =
       (" xprxmodem.library T0,C0,K0 r ",
	" xprxmodem.library T0,C1,K0 r ",
	" xprxmodem.library T0,C1,K1 r ",
	" xprymodem.library B0,C0,K0,OT: r ",
	" xprymodem.library B0,C1,K1,OT: r ",
	" xprzmodem.library T?,OR,B1,AN,DN,KN,SN,RN,PT: r ram:");

var
	com	: string;

begin
strcpy (com, "XPRGate serial.device 0 ");
strcat (com, "1200");
strcat (com, xprrecieve [curuser.proto]);
strcat (com, filespec);
closemodem;
exec_command (com);
openmodem;
end;

procedure download (filespec : string);

const
	xprsend : array ['A'..'F'] of string =
       (" xprxmodem.library T0,C0,K0 s ",
	" xprxmodem.library T0,C1,K0 s ",
	" xprxmodem.library T0,C1,K1 s ",
	" xprymodem.library B0,C0,K0 s ",
	" xprymodem.library B0,C1,K1 s ",
	" xprzmodem.library T?,OR,B1,AN,DN,SN s ");

var
	com	: string;

begin
strcpy (com, "XPRGate serial.device 0 ");
strcat (com, "1200");
strcat (com, xprsend [curuser.proto]);
strcat (com, filespec);
closemodem;
exec_command (com);
openmodem;
end;
