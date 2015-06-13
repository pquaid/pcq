	opt	o+,ow-,l+
   
	incdir	"asm:include/"
	include	"Offsets20.i"

CALL	MACRO
	jsr	_LVO\1(a6)
	ENDM

 	XDEF	_HardCopy

_HardCopy
	move.l	4(sp),a0
	movem.l	d1/d2,-(sp)
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	jsr	HardCopy
	movem.l	(sp)+,d1/d2
	rts

* Offsets for IORequest
	rsreset
std	rs.b	28
command	rs.w	1
ioflags	rs.b	1
error	rs.b	1
rast	rs.l	1
cmap	rs.l	1
modes32	rs.w	1
modes	rs.w	1
Sx	rs.w	1
Sy	rs.w	1
Swidth	rs.w	1
Sheight	rs.w	1
Pwidth	rs.l	1
Pheight	rs.l	1
flags	rs.w	1
iosize	rs.l	0

	SECTION	"routine",CODE

HardCopy ;(a0=^screen, d0=flags, d1=Pwidth, d2=Pheight): d0=Error
	;(if d1 or d2 = 0 = Default)
	;(residentable, requires OS2.0)
	movem.l	a5/a6/d2-d7,-(sp)
	move.l	a0,a5	;scrptr
	move.l	d2,d4	;Pheigth
	move.l	d1,d3	;Pwidth
	move.l	d0,d2	;flags
	moveq	#0,d7	;RCode
	move.l	$4.w,a6
	cmp.w	#36,$14(a6)
	bge.s	HCOS20Ok
	moveq	#-1,d7
	bra	HCexit
HCOS20Ok
	CALL	CreateMsgPort
	move.l	d0,d6
	bne.s	HCPortOk
	moveq	#-1,d7
	bra	HCexit
HCPortOk
	move.l	d6,a0
	moveq	#iosize,d0
	CALL	CreateIORequest
	move.l	d0,d5
	bne.s	IOReqOk
	moveq	#-1,d7
	bra	HCKillPort
IOReqOk
	move.l	d5,a1
	move.w	#11,command(a1)
	lea.l	$54(a5),a0  ;Rastport
	move.l	a0,rast(a1)
	lea.l	$2c(a5),a0  ;Viewport
	move.l	$04(a0),cmap(a1)
	move.w	$20(a0),modes(a1)
	clr.w	Sx(a1)
	clr.w	Sy(a1)
	move.w	$0c(a5),Swidth(a1)
	move.w	$0e(a5),Sheight(a1)
	move.l	d3,Pwidth(a1)
	move.l	d4,Pheight(a1)
	move.w	d2,flags(a1)

	lea.l	HCprtname,a0
	moveq	#0,d0
	moveq	#0,d1
	CALL	OpenDevice
	move.l	d0,d7
	bne.s	HCKillIOReq
	move.l	d5,a1
	CALL	DoIO
	move.l	d0,d7
	move.l	d5,a1
	CALL	CloseDevice

HCKillIOReq
	move.l	d5,a0
	CALL	DeleteIORequest
HCKillPort
	move.l	d6,a0
	CALL	DeleteMsgPort
HCexit
	move.l	d7,d0
	movem.l	(sp)+,a5/a6/d2-d7
	rts

	SECTION	"const",DATA
HCprtname
	dc.b	"printer.device",0
	cnop	0,2
	
	END

