{

	CEFReq.i -	Cat'sEye File Requester for PCQ Pascal

	Call this routine to get someone's file choice. It DOESN'T work
	very well at present but I'm WORKING on it.

	see DosStuff.i
}

{$I "Include:CEUtils/IntuiStuff.i"}

Function CEFReq (var PN,		{ path name } 
		FN,			{ file name }
		ActionGadgText,		{ such as "Open," "Save," "Delete" }
		Header		: String;	{ ScreenTitle text }
		oS		: ScreenPtr;	{ Screen requester is on }
		LEd,				{ Left, top edge }
		TEd		: Short;
		Bent		: BordType)	{ Techno/Plain, etc. }
	: Boolean;

	External;
