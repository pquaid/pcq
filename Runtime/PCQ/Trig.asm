
	SECTION	PCQ_Runtime,CODE

        XREF    _p%MathBase
        XDEF    _p%sin
_p%sin
        move.l  4(sp),d0          ;x to d0
        move.l  _p%MathBase,a6
        move.l  #$C90FD941,d1     ;halfpi
        jsr     -72(a6)           ;sub
        bra.s   gotocos

        XDEF    _p%cos
_p%cos
        move.l  4(sp),d0          ;x to d0
        move.l  _p%MathBase,a6
gotocos move.l  d7,-(sp)
        move.l  d0,d7
        move.l  #$C90FD943,d1     ;twopi
        jsr     -42(a6)           ;cmp
        bge.s   cos_toobig
        btst    #7,d7             ;is x>=0?
        beq.s   cos_around
cos_toobig
        move.l  d7,d0
        move.l  #$C90FD943,d1     ;twopi
        jsr     -84(a6)           ;div
        jsr     -90(a6)           ;floor
        move.l  #$C90FD943,d1     ;twopi
        jsr     -78(a6)           ;mul
        move.l  d7,d1
        exg     d0,d1
        jsr     -72(a6)           ;sub
        move.l  d0,d7
cos_around
        move.l  d7,d0
        move.l  #$C90FD941,d1     ;halfpi
        jsr     -42(a6)           ;cmp
        bgt.s   cos_TwoQuad
        bsr.s   GetCos
        bra.s   cos_out
cos_TwoQuad
        move.l  d7,d0
        move.l  #$C90FD942,d1     ;pi
        jsr     -42(a6)           ;cmp
        bgt.s   cos_ThreeQuad
        move.l  #$C90FD942,d0     ;pi
        move.l  d7,d1
        jsr     -72(a6)           ;sub
        move.l  d0,d7
        bsr.s   GetCos
        bchg    #7,d0             ;neg
        bra.s   cos_out
cos_ThreeQuad
        move.l  d7,d0
        move.l  #$96CBE343,d1     ;threehalvespi
        jsr     -42(a6)           ;cmp
        bgt.s   cos_FourQuad
        move.l  d7,d0
        move.l  #$C90FD942,d1     ;pi
        jsr     -72(a6)           ;sub
        move.l  d0,d7
        bsr.s   GetCos
        bchg    #7,d0             ;neg
        bra.s   cos_out
cos_FourQuad
        move.l  #$C90FD943,d0     ;twopi
        move.l  d7,d1
        jsr     -72(a6)           ;sub
        move.l  d0,d7
        bsr.s   GetCos
cos_out     move.l  (sp)+,d7
        rts


GetCos                            ;1-(x^2)/2!+(x^4)/4!-(x^6)/6! almost
                                  ;1/6! adj to .00132934 to fit at halfpi
        move.l  d7,d0             ;d7 holds x
        move.l  d0,d1
        jsr     -78(a6)           ;mul
        move.l  d0,d7             ;d7 holds x^2
        move.l  #$AE3D41B7,d1     ;-1/6! almost
        jsr     -78(a6)           ;mul
        move.l  #$AAAAAB3C,d1     ;1/4!
        jsr     -66(a6)           ;add
        move.l  d7,d1
        jsr     -78(a6)           ;mul by x^2
        move.l  #$80000040,d1     ;d1 holds 1/2
        jsr     -72(a6)           ;sub
        move.l  d7,d1
        jsr     -78(a6)           ;mul by x^2
        move.l  #$80000041,d1     ;d1 holds 1
        jsr     -66(a6)           ;add
        rts

        XDEF    _p%tan
_p%tan
        move.l  4(sp),d0          ;x to d0
        move.l  _p%MathBase,a6
        move.l  d7,-(sp)
        move.l  d0,d7
        move.l  #$C90FD943,d1     ;twopi
        jsr     -42(a6)           ;cmp
        bge.s   tan_toobig
        btst    #7,d7             ;is x>=0?
        beq.s   tan_around
tan_toobig
        move.l  d7,d0
        move.l  #$C90FD943,d1     ;twopi
        jsr     -84(a6)           ;div
        jsr     -90(a6)           ;floor
        move.l  #$C90FD943,d1     ;twopi
        jsr     -78(a6)           ;mul
        move.l  d7,d1
        exg     d0,d1
        jsr     -72(a6)           ;sub
        move.l  d0,d7
tan_around
        move.l  d7,d0
        move.l  #$C90FD941,d1     ;halfpi
        jsr     -42(a6)           ;cmp
        bgt.s   tan_TwoQuad
        bsr.s     GetTan
        bra.s   tan_out
tan_TwoQuad
        move.l  d7,d0
        move.l  #$C90FD942,d1     ;pi
        jsr     -42(a6)           ;cmp
        bgt.s   tan_ThreeQuad
        move.l  #$C90FD942,d0     ;pi
        move.l  d7,d1
        jsr     -72(a6)           ;sub
        move.l  d0,d7
        bsr.s   GetTan
        bchg    #7,d0             ;neg
        bra.s   tan_out
tan_ThreeQuad
        move.l  d7,d0
        move.l  #$96CBE343,d1     ;threehalvespi
        jsr     -42(a6)           ;cmp
        bgt.s   tan_FourQuad
        move.l  d7,d0
        move.l  #$C90FD942,d1     ;pi
        jsr     -72(a6)           ;sub
        move.l  d0,d7
        bsr.s   GetTan
        bra.s   tan_out
tan_FourQuad
        move.l  #$C90FD943,d0     ;twopi
        move.l  d7,d1
        jsr     -72(a6)           ;sub
        move.l  d0,d7
        bsr.s   GetTan
        bchg    #7,d0             ;neg
tan_out     move.l  (sp)+,d7
        rts

GetTan
        move.l  d7,d0
        move.l  #$C90FD940,d1     ;fourthpi
        jsr     -42(a6)           ;cmp
        sgt     8(sp)             ;hibyte of x is flag for angle>fourthpi
        ble.s   tan_small
        move.l  #$C90FD941,d0     ;halfpi
        move.l  d7,d1
        jsr     -72(a6)           ;sub
        move.l  d0,d7

tan_small                         ;a4x^4+a3x^3+a2x^2+a1x  a0 assumed 0
        move.l  d7,d0             ;d7 holds x
        move.l  #$F9035B3F,d1     ;a4=.4863537
        jsr     -78(a6)           ;mul
        move.l  #$B912A13D,d1     ;a3=.09036756
        jsr     -72(a6)           ;sub   a3 is negative
        move.l  d7,d1
        jsr     -78(a6)           ;mul
        move.l  #$8F333C3E,d1     ;a2=.1398439
        jsr     -66(a6)           ;add
        move.l  d7,d1
        jsr     -78(a6)           ;mul
        move.l  #$FBC84240,d1     ;a1=.9835244
        jsr     -66(a6)           ;add
        move.l  d7,d1
        jsr     -78(a6)           ;mul
        tst.b   8(sp)             ;angle>fourthpi?
        beq.s   tan_small_out
        move.l  d0,d1
        beq.s   tan_huge          ;tangent of halfpi undefined
        move.l  #$80000041,d0
        jsr     -84(a6)           ;div       take reciprocal of tangent
tan_small_out
        rts
tan_huge
        move.l #$EE6B275E,d0      ;tan(halfpi)=999999936 which is huge enough
        bra.s  tan_small_out


        XDEF    _p%atn
_p%atn
        move.l  4(sp),d0          ;x to d0
        move.l  _p%MathBase,a6
        move.l  d7,-(sp)
        btst    #7,d0             ;is x>=0?
        sne     8(sp)             ;set flag for negative angle
        beq.s   atn_posang
        bchg    #7,d0             ;neg
atn_posang
        move.l  d0,d7
        move.l  #$80000041,d1     ; one
        jsr     -42(a6)           ;cmp
        sge     9(sp)             ;set flag for angle > fourthpi
        blt.s   GetAtn
        move.l  d7,d1
        move.l  #$80000041,d0
        jsr     -84(a6)           ;take reciprocal
        move.l  d0,d7
GetAtn                            ;a4x^4+a3x^3+a2x^2+a1x   a0 assumed 0
        move.l  d7,d0             ;d7 holds x
        move.l  #$8D38C03E,d1     ;a4=.1379118
        jsr     -78(a6)           ;mul
        move.l  #$AC901A3F,d1     ;a3=.3370369
        jsr     -72(a6)           ;sub   a3 is negative
        move.l  d7,d1
        jsr     -78(a6)           ;mul
        move.l  #$A4FC033B,d1     ;a2=.0201397
        jsr     -72(a6)           ;sub    a2 is negative
        move.l  d7,d1
        jsr     -78(a6)           ;mul
        move.l  #$8098CB41,d1     ;a1=1.004663
        jsr     -66(a6)           ;add
        move.l  d7,d1
        jsr     -78(a6)           ;mul
        tst.b   9(sp)             ;angle>fourthpi?
        beq.s   atn_pos
        move.l  d0,d1
        move.l  #$C90FD941,d0
        jsr     -72(a6)           ;sub

atn_pos tst.b    8(sp)
        beq.s   atn_out
        bchg    #7,d0             ;neg angle
atn_out move.l  (sp)+,d7
        rts
        end

