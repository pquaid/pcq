{
	MathTransUtils.i for PCQ Pascal

	A few routines to make using the MathTrans library
	a little easier.  OpenMathTrans attempts to open the
	library, and returns TRUE if nothing went wrong.
	CloseMathTrans is the same as CloseLibrary(...), but
	FlushMathTrans will close the library AND cause it to
	be removed from memory, if no one else is currently
	using it.
}


Function OpenMathTrans : Boolean;
    External;

Procedure CloseMathTrans;
    External;

Procedure FlushMathTrans;
    External;
