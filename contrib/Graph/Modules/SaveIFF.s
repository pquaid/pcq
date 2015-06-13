	opt	o+,ow-,l+
	
	incdir	"asm:include/"
	include	"Offsets20.i"
	

CALL	MACRO
	jsr	_LVO\1(a6)
	ENDM
	
	XDEF	_SaveIFF


BMHDlen	equ	$14
MEMSIZE	equ	1024

memerr	equ	1
fileerr	equ	2

* program segment for saving IFF-files

* d0 = int SaveIFF(a0 = *filename, a1 = *screen);
* function SaveIFF(a0: ^filename; a1: ^screen): d0: integer;
*
* Result:  0 = Ok; File writen without any error;
*          1 = Error; Not enough memory to create IFF;
*          2 = Error; Could not write data (disk full, write error ect);
*              d1 contains IoErr;
*
* doesn`t use 2.0 functions jet
* requires dosbase in a6
* residentable

scr	equr	a3
file	equr	d7
mem	equr	d6
res	equr	d5
io	equr	d4

bitmap	equ	$b8
rport	equ	$54
vport	equ	$2c

unmode	equ	$2!$100!$2000!$4000

	SECTION	"routine",CODE

_SaveIFF
	movem.l	a2-a6/d2-d7,-(sp)
	move.l	a6,a5
	moveq	#0,res
	moveq	#0,io
	move.l	a1,scr
	move.l	a0,d1
	move.l	#1006,d2
	CALL	Open
	move.l	d0,file
	bne.s	SIOpenOk
	CALL	IoErr
	move.l	d0,io
	moveq	#fileerr,res
	bra	SIdone
SIOpenOk
	move.l	#MEMSIZE,d0
	move.l	#$10001,d1
	move.l	$4.w,a6
	CALL	AllocMem
	move.l	d0,mem
	bne.s	SIMemOk
	moveq	#memerr,res
	bra	SIclose
SIMemOk
	move.l	mem,a0
	move.l	#"FORM",(a0)+
	lea.l	bitmap(scr),a1
	move.w	(a1)+,d0	;bytes per row
	move.w	(a1)+,d1	;rows
	mulu	d0,d1
	moveq	#0,d0
	move.b	1(a1),d0	;depth
	bsr	LongMulu	;d1=bitplane size
	move.l	d1,a4
	lea.l	vport(scr),a1
	move.l	$4(a1),a1	;ColorMap
	move.l	a1,a2
	moveq	#0,d0
	move.w	$2(a1),d0	;Count
	mulu	#3,d0		;RGB
	move.l	d0,d3
	add.l	d0,d1
	add.l	#4+8+8+4+8+8+BMHDlen,d1	;"ILBM"+"CMAP"\0+"CMAG"\0+SizeOf(CMAG)
					;"BODY"\0+"BMHD"\0+SizeOf(BMHD)
	move.l	d1,(a0)+
	move.l	#"ILBM",(a0)+
	move.l	#"BMHD",(a0)+
	move.l	#BMHDlen,(a0)+
	move.w	$c(scr),(a0)+	;BMHDw
	move.w	$e(scr),(a0)+	;BMHDh
	clr.l	(a0)+		;BMHDx,MMHDy
	lea.l	bitmap(scr),a1
	move.b	$5(a1),(a0)+	;depth
	clr.b	(a0)+		;masking
	clr.l	(a0)+		;compression,pad,transparent
	lea.l	vport(scr),a1
	move.w	$20(a1),d0
	move.b	#44,(a0)
	btst	#15,d0
	beq.s	SIxdone
	move.b	#22,(a0)
SIxdone
	addq.l	#1,a0
	move.b	#44,(a0)
	btst	#4,d0
	beq.s	SIydone		;Just for Std-Aspect and PAL
	move.b	#22,(a0)
SIydone
	addq.l	#1,a0
	move.w	$c(scr),(a0)+
	move.w	$e(scr),(a0)+
	move.l	#"CMAP",(a0)+
	move.l	d3,(a0)+
	move.w	$2(a2),d0
	subq.w	#1,d0
	bmi.s	SIcolorsdone
	move.l	$4(a2),a1
SIcopycolors
	moveq	#2,d3
	move.w	(a1)+,d1
SICopyRGB
	move.w	d1,d2
	and.w	#$0f00,d2
	lsl.w	#4,d1
	lsr.w	#4,d2
	move.b	d2,(a0)
	lsr.w	#4,d2
	or.b	d2,(a0)+
	dbra	d3,SICopyRGB
	dbra	d0,SIcopycolors
SIcolorsdone
	move.l	#"CAMG",(a0)+
	move.l	#4,(a0)+
	lea.l	vport(scr),a1
	moveq	#0,d0
	move.w	$20(a1),d0
	or.w	#unmode,d0
	eor.w	#unmode,d0
	move.l	d0,(a0)+
	move.l	#"BODY",(a0)+
	move.l	a4,(a0)+
	sub.l	mem,a0
	move.l	a0,d3
	move.l	mem,d2
	move.l	d7,d1
	move.l	a5,a6
	CALL	Write
	cmp.l	d0,d3
	beq.s	SIPart1done
	moveq	#fileerr,res
	bra.s	SIFree
SIPart1done
	movem.l	d4-d6,-(sp)
	lea.l	bitmap(scr),a4
	move.w	(a4),d3		;X
	bmi.s	SIPart2done
	move.w	$2(a4),d5	;Y
	subq.w	#1,d5
	bmi.s	SIPart2done
	moveq	#0,d4
SICopyPlane
	lea.l	$8(a4),a2	;planes
	moveq	#0,d6
	move.b	$5(a4),d6	;depth
	subq.l	#1,d6
	bmi.s	SIPart2done
SICopyLine
	move.l	(a2)+,a0
	add.l	d4,a0
	move.l	d7,d1
	move.l	a0,d2
	CALL	Write
	cmp.l	d0,d3
	bne.s	SIPart2done
	dbra	d6,SICopyLine
	add.l	d3,d4
	dbra	d5,SICopyPlane
SIPart2done
	movem.l	(sp)+,d4-d6
SIFree
	move.l	mem,a1
	move.l	#MEMSIZE,d0
	move.l	$4.w,a6
	CALL	FreeMem
SIclose
	move.l	d7,d1
	move.l	a5,a6
	CALL	Close
SIdone
	move.l	res,d0
	move.l	io,d1
	movem.l (sp)+,a2-a6/d2-d7
	rts

LongMulu
	movem.l	d2/d3,-(sp)
	move.l	d0,d2
	move.l	d1,d3
	swap	d2
	swap	d3
	mulu	d1,d2
	mulu	d0,d3
	mulu	d1,d0
	add.w	d3,d2
	swap	d2
	clr.w	d2
	add.l	d2,d0
	move.l	d0,d1
	movem.l	(sp)+,d2/d3
	rts

	END

