*
*	Parameters.asm
*	    of PCQ Pascal
*
*	These routines handle the CommandLine.
*

	SECTION	Params,CODE

	XREF	_CommandLine
	XREF	_strcpy
	XREF	_p%WorkBenchMsg

SkipParam
	move.b	0(a0,d1.w),d0
	cmp.b	#'"',d0
	beq.s	4$
	cmp.b	#' ',d0
	ble.s	1$
	cmp.b	#127,d0
	bgt.s	1$
	addq.w	#1,d1
	bra.s	SkipParam
1$	rts
4$	addq.w	#1,d1
2$	move.b	0(a0,d1.w),d0
	beq.s	1$
	cmp.b	#'"',d0
	beq.s	3$
	addq.w	#1,d1
	bra.s	2$
3$	addq.w	#1,d1
	rts
	
NextParam
	move.b	0(a0,d1.w),d0
	beq.s	1$
	cmp.b	#' ',d0
	bgt.s	1$
	addq.w	#1,d1
	bra.s	NextParam
1$	rts

CopyParam
	move.l	8(sp),a1		; add offset of return address
	cmp.b	#'"',0(a0,d1.w)
	bne.s	JustChars
	addq.w	#1,d1
1$	move.b	0(a0,d1.w),d0
	beq.s	DoneCopying
	cmp.b	#'"',d0
	beq.s	DoneCopying
	cmp.b	#10,d0
	beq.s	DoneCopying
	move.b	d0,(a1)+
	addq.w	#1,d1
	bra.s	1$
JustChars
	move.b	0(a0,d1.w),d0
	cmp.b	#' ',d0
	ble.s	DoneCopying
	cmp.b	#127,d0
	bgt.s	DoneCopying
	move.b	d0,(a1)+
	addq.w	#1,d1
	bra.s	JustChars
DoneCopying
	move.b	#0,(a1)
	rts

*	Syntax:	GetParam(Number : Short; var S : string);

	XDEF	_GetParam
_GetParam
	move.l	_p%WorkBenchMsg,a0
	move.l	a0,d0			; to set flags
	bne	FromWorkbench
	move.w	#0,d1
	move.l	_CommandLine,a0
	bsr	NextParam
1$	cmp.w	#1,8(sp)
	beq	AtParam
	bsr	SkipParam
	bsr	NextParam
	subq.w	#1,8(sp)
	bra.s	1$
AtParam
	bsr	CopyParam
	rts
FromWorkbench
	move.l	28(a0),d0
	cmp.w	8(sp),d0
	ble.s	2$
	tst.w	8(sp)
	ble.s	2$
	move.l	36(a0),a0
	move.w	8(sp),d0
	ext.l	d0
	lsl.l	#3,d0
	adda.l	d0,a0
	move.l	4(a0),-(sp)
	move.l	8(sp),a0
	move.l	(a0),-(sp)
	jsr	_strcpy
	addq.l	#8,sp
	rts
2$	move.l	4(sp),a0
	move.b	#0,(a0)
	rts

	XDEF	_GetStartupMsg
_GetStartupMsg
	move.l	_p%WorkBenchMsg,d0
	rts

	END
