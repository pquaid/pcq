*
*    Exp.asm
*
*    This file implements the exponent function (e raised to the x)
*    Like the trig functions and ln(), this was sent to me by
*    Martin Combs.
*

	SECTION	PCQ_Runtime,CODE

         XREF     _p%MathBase

         XDEF     _p%exp
_p%exp
         move.l   4(sp),d0         ; get x
         bne.s   next
         move.l   #$8000003F,d0
next         movem.l  d3-d7,-(sp)
         move.l   _p%MathBase,a6
         move.l   d0,d7            ;save x
         btst     #7,d0
         beq.s    posexp
         bchg     #7,d0
posexp   move.l   d0,d5            ; store abs(x)
         move.l   #$A5C8B445,d1    ; d1 holds ln(999999999)
         move.l   d1,d6            ; save it
         jsr      -42(a6)          ; cmp
         blt.s    expsmall
         move.l   d6,d5            ; 999999999 is maximum output
expsmall move.l   d5,d0
         move.l   d5,d6            ; save new abs(x)
         jsr      -30(a6)          ; Fix
         move.l   d0,d5            ; d5 holds integer part
         jsr      -36(a6)          ; Float(Fix)
         move.l   d0,d1
         move.l   d6,d0
         jsr      -72(a6)          ; sub   get fractional part
         move.l   d0,d4            ; save it
         move.l   #$8E883A3D,d1    ; a4=.06959577
         jsr      -78(a6)          ; mul
         move.l   #$8F0F883E,d1    ; a3=.13970769
         jsr      -66(a6)          ; add
         move.l   d4,d1
         jsr      -78(a6)          ; mul
         move.l   #$82AF4540,d1    ; a2=.51048687
         jsr      -66(a6)          ; add
         move.l   d4,d1
         jsr      -78(a6)          ; mul
         move.l   #$FF9D2340,d1    ; a1=.99849147
         jsr      -66(a6)          ; add
         move.l   d4,d1
         jsr      -78(a6)          ; mul
         move.l   #$80000041,d1    ; a0=1
         jsr      -66(a6)          ; add    d0 holds exp(fraction)
         move.l   #$ADF85442,d3    ; d3 holds float(e)
         tst.l    d5               ; is integer part zero?
         beq.s    exp0
         subq.l   #1,d5            ; for dbra
expback  move.l   d3,d1            ; d1 holds e
         jsr      -78(a6)          ; mul
         dbra     d5,expback
exp0     btst     #7,d7
         beq.s    expout
         move.l   d0,d1
         move.l   #$80000041,d0
         jsr      -84(a6)          ; div    take reciprocal if input < 0
expout   movem.l  (sp)+,d3-d7
         rts
         end



