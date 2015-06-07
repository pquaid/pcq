*
*    Ln.asm
*
*    This function, which was sent to me by Martin Combs, implements
*    the natural log function.
*

	SECTION	PCQ_Runtime,CODE

         XREF     _p%MathBase

         XDEF     _p%ln
_p%ln
         move.l   4(sp),d0         ; get x
         bne.s    not0
         rts                       ; need error message
not0     btst     #7,d0
         beq.s    notneg
         rts                       ; another error message
notneg   movem.l  d6-d7,-(sp)
         move.l   _p%MathBase,a6
         moveq    #0,d6
         move.b   d0,d6            ; save exponent in excess $40 form
         andi.l   #$FFFFFF00,d0    ; strip off exponent
         ori.l    #$40,d0          ; x is mantissa;  give x a zero exponent
         move.l   d0,d7            ; store x
         move.l   #$E12FB6C0,d1    ; a4=-.8796343
         jsr      -78(a6)          ; mul   a4*x
         move.l   #$DF98E142,d1    ; a3=3.493706
         jsr      -66(a6)          ; add    a4*x+a3
         move.l   d7,d1
         jsr      -78(a6)          ; mul     x(a4*x+a3)
         move.l   #$B8ED93C3,d1    ; a2=-5.779001
         jsr      -66(a6)          ; add
         move.l   d7,d1
         jsr      -78(a6)          ; mul    x(x(a4*x+a3)+a2)
         move.l   #$B2DEAC43,d1    ; a1=5.589682
         jsr      -66(a6)          ; add
         move.l   d7,d1
         jsr      -78(a6)          ; mul    x(x(x(a4*x+a3)+a2)+a1)
         move.l   #$9B30B1C2,d1    ; a0=-2.424847
         jsr      -66(a6)          ; add
         exg      d0,d6            ; d0 gets exponent; d6 gets ln(mantissa)
         sub.l    #$40,d0          ; exponent without excess $40
         jsr      -36(a6)          ; convert exponent to float
         move.l   #$B1721940,d1    ; ln 2=.6931472
         jsr      -78(a6)          ; mul
         move.l   d6,d1
         jsr      -66(a6)          ; add ln(mantissa) and exponent*ln2
         movem.l  (sp)+,d6-d7
         rts
         end



