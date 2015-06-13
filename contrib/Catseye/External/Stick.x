{

	Stick.X for PCQ Pascal

	Cat'sEye

	To H-E-Double Hockey Sticks with multitasking! I am FED UP
	with the gameport.device! I have decided to skip that
	entirely, and, inspired by Dave Jones' Menace, I present...
}

{$I "Include:Exec/Exec.i"}
{$I "Include:Hardware/Custom.i"}
{$I "Include:CEUtils/CETypes.i"}

Procedure ReadStick (var jx, jy : Short; var trig : boolean);

	{ jx, jy become delta values (-1,0,1) for an object as
	  if it were on a computer screen (not cartesian plane -
	  the y is inverted.) trig becomes TRUE if the fire button
	  is pressed. NB this is only for port 2 - the non-mouse
	  port. }

var	d			: Short;
	C			: CustomPtr;
	B			: BytePtr;

begin
C := Address ($DFF000);		{ C points to the custom chips }
B := Address ($BFE001);		{ B points to CIA A }
d := C^.joy1dat;
jx := 0;
jy := 0;

{
	lsl.w	#1,d0
	lsl.w	#1,d1
	eor.w	d2,d1
	eor.w	d3,d0
}

if (d and $0100 shl 1 xor (d and $0200)) <> 0 then
	jy := -1;
if (d and $0001 shl 1 xor (d and $0002)) <> 0 then
	jy := 1;
if (d and $0002) <> 0 then
	jx := 1;
if (d and $0200) <> 0 then
	jx := -1;
trig := (B^ and 128) <> 128;
end;
