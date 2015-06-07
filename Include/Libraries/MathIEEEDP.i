{
	MathIEEEDP.i for PCQ Pascal

	Note: PCQ Pascal does not support double precision math, so the
	definitions in this file would be the same as those in MathFFP.i

	The first set of routines are accessed through
	MathIEEEDoubBasBase, whereas the latter set of stubs are
	called through the MathIEEEDoubTransBase.
}

Type

{  This declaration is meaningless except in using the routines below.
   x and y will not have significant values.  If double precision
   math ever becomes a part of PCQ Pascal, this will go. }

    Double = record
	x, y : Real;
    end;


Var
    MathIEEEDoubBasBase	: Address;
    MathIEEEDoubTransBase : Address;

Procedure IEEEDPAbs(y : Double; VAR result : Double);
    External;

Procedure IEEEDPAdd(x, y : Double; VAR result : Double);
    External;

Procedure IEEEDPCeil(x : Double; VAR result : Double);
    External;

Function IEEEDPCmp(x, y : Double) : Short;
    External;

Procedure IEEEDPDiv(x, y : Double; VAR result : Double);
    External;

Function IEEEDPFix(x : Double) : Integer;
    External;

Procedure IEEEDPFloor(x : Double; VAR result : Double);
    External;

Procedure IEEEDPFlt(x : Integer; VAR result : Double);
    External;

Procedure IEEEDPMul(x, y : Double; VAR result : Double);
    External;

Procedure IEEEDPNeg(x : Double; VAR result : Double);
    External;

Procedure IEEEDPSub(x, y : Double; VAR result : Double);
    External;

Function IEEEDPTst(x : Double) : Short;
    External;

{   The following routines require that MathIEEEDoubTransBase be
    initialized through a call like:
	MathIEEEDoubTransBase := OpenLibrary("mathieeedoubtrans.library"...)
}

Procedure IEEEDPAcos(x : Double; VAR result : Double);
    External;

Procedure IEEEDPAsin(x : Double; VAR result : Double);
    External;

Procedure IEEEDPAtan(x : Double; VAR result : Double);
    External;

Procedure IEEEDPCos(x : Double; VAR result : Double);
    External;

Procedure IEEEDPCosh(x : Double; VAR result : Double);
    External;

Procedure IEEEDPExp(x : Double; VAR result : Double);
    External;

Procedure IEEEDPFieee(x : Real; VAR result : Double);
    External;
	{ Note: x is NOT a PCQ real value, but a single precision
	  IEEE real value. }

Procedure IEEEDPLog(x : Double; VAR result : Double);
    External;

Procedure IEEEDPLog10(x : Double; VAR result : Double);
    External;

Procedure IEEEDPPow(x, y : Double; VAR result : Double);
    External;

Procedure IEEEDPSin(x : Double; VAR result : Double);
    External;

Procedure IEEEDPSincos(x : Double; VAR cosine, sine : Double);
    External;

Procedure IEEEDPSinh(x : Double; VAR result : Double);
    External;

Procedure IEEEDPSqrt(x : Double; VAR result : Double);
    External;

Procedure IEEEDPTan(x : Double; VAR result : Double);
    External;

Procedure IEEEDPTanh(x : Double; VAR result : Double);
    External;

Function IEEEDPTieee(x : Double) : Real;
    External;
	{ Note: this returns a single precision IEEE floating
		point number, not the Motorola Fast Floating Point
		values used by PCQ Pascal }

