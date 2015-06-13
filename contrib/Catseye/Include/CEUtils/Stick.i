{

	Stick.I for PCQ Pascal

	Cat'sEye

	To H-E-Double Hockey Sticks with multitasking! I am FED UP
	with the gameport.device! I have decided to skip that
	entirely, and, inspired by Dave Jones' Menace, I present...
}

{$I "Include:Exec/Exec.i"}
{$I "Include:Hardware/Custom.i"}
{$I "Include:CEUtils/CETypes.i"}

Procedure ReadStick (var jx, jy : Short; var trig : boolean);
	External;

	{ jx, jy become delta values (-1,0,1) for an object as
	  if it were on a computer screen (not cartesian plane -
	  the y is inverted.) trig becomes TRUE if the fire button
	  is pressed. NB this is only for port 2 - the non-mouse
	  port. }
