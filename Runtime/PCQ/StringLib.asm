*
*       Strings.asm of PCQ Pascal
*       Copyright 1989 Patrick Quaid
*
* Since PCQ strings are similar to C strings, these
*       routines are similar in operation and name to the
*       standard C stuff.
*

        XREF    _p%new
        XREF    _p%dispose

        SECTION StringLib,CODE

        XDEF    _isupper
_isupper
        move.w  4(sp),d0
isup_   cmp.b   #'A',d0
        blt.s   1$
        cmp.b   #'Z',d0
        bgt.s   1$
        moveq   #-1,d0
        rts
1$
        moveq   #0,d0
        rts

        XDEF    _islower
_islower
        move.w  4(sp),d0
islo_   cmp.b   #'a',d0
        blt.s   1$
        cmp.b   #'z',d0
        bgt.s   1$
        moveq   #-1,d0
        rts
1$
        moveq   #0,d0
        rts

        XDEF    _isalnum
_isalnum
        move.w  4(sp),d1
        cmp.b   #'0',d1
        blt.s   notalfa
        cmp.b   #'9',d1
        ble.s   isalfa
        bra.s   inalfa

        XDEF    _isalpha
_isalpha
        move.w  4(sp),d1
inalfa  cmpi.b  #'A',d1
        blt.s   notalfa
        cmpi.b  #'Z',d1
        bgt.s   maybealfa
isalfa   moveq   #-1,d0      ;upper case
        rts
maybealfa  cmpi.b  #'a',d1
        blt.s   notalfa
        cmpi.b  #'z',d1
        ble	isalfa          ;lower case
notalfa  moveq   #0,d0
        rts

        XDEF    _isdigit
_isdigit
        move.w  4(sp),d0
isdig_  cmp.b   #'0',d0
        blt.s   1$
        cmp.b   #'9',d0
        bgt.s   1$
        moveq   #-1,d0
        rts
1$
        moveq   #0,d0
        rts

        XDEF    _isspace
_isspace
        move.w  4(sp),d0
        cmpi.b   #' ',d0
        beq.s   1$
        cmpi.b   #10,d0
        beq.s   1$
        cmpi.b   #13,d0
        beq.s   1$
        cmpi.b   #9,d0
        beq.s   1$
        cmpi.b   #12,d0
        beq.s   1$
        moveq   #0,d0
        rts
1$
        moveq     #-1,d0
        rts

        XDEF    _toupper
_toupper
        move.w  4(sp),d0
toup_   cmpi.b   #'a',d0
        blt.s   1$
        cmpi.b   #'z',d0
        bgt.s   1$
        and.b   #%11011111,d0
1$      rts

        XDEF    _tolower
_tolower
        move.w  4(sp),d0
tolo_   cmp.b   #'A',d0
        blt.s   1$
        cmp.b   #'Z',d0
        bgt.s   1$
        or.b    #%00100000,d0
1$      rts

        XDEF    _streq
_streq:
        movem.l  4(sp),a0/a1
1$:
        cmpm.b   (a0)+,(a1)+
        bne.s   2$
        tst.b    -1(a1)
        bne     1$
        moveq   #-1,d0
        rts
2$:
        moveq   #0,d0
        rts

          XDEF  _strieq
_strieq   movem.l  4(sp),a0/a1
          bra.s    instrieq
ieqloop   tst.b    -1(a0)
          beq.s    ieqtrue
instrieq  move.b   (a0)+,d0
          move.b   (a1)+,d1
          sub.b    d0,d1
          beq.s    ieqloop
          cmpi.b   #32,d1
          beq.s    ieqpos32
          cmpi.b   #-32,d1
          beq.s    ieqneg32
ieqfalse  moveq    #0,d0
          rts
ieqpos32  cmpi.b   #'A',d0
          blt.s    ieqfalse
          cmpi.b   #'Z',d0
          bgt.s    ieqfalse
          bra.s    ieqloop
ieqneg32  cmpi.b   #'a',d0
          blt.s    ieqfalse
          cmpi.b   #'z',d0
          bgt.s    ieqfalse
          bra.s    ieqloop
ieqtrue   moveq    #-1,d0
          rts

        XDEF    _strneq
_strneq:
        movem.l  6(sp),a0/a1
        move.w  4(sp),d1
        subq.w  #1,d1
1$:
        cmpm.b  (a0)+,(a1)+
        bne.s   2$
        tst.b   -1(a1)
	beq	3$
        dbeq     d1,1$
3$      moveq   #-1,d0
        rts
2$:
        moveq   #0,d0
        rts

          XDEF  _strnieq
_strnieq  movem.l  6(sp),a0/a1
          bra.s    instrnieq
nieqloop   tst.b    -1(a0)
          beq.s    nieqtrue
          subq.w   #1,4(sp)
          beq.s    nieqtrue
instrnieq  move.b   (a0)+,d0
          move.b   (a1)+,d1
          sub.b    d0,d1
          beq.s    nieqloop
          cmpi.b   #32,d1
          beq.s    nieqpos32
          cmpi.b   #-32,d1
          beq.s    nieqneg32
nieqfalse  moveq    #0,d0
          rts
nieqpos32  cmpi.b   #'A',d0
          blt.s    nieqfalse
          cmpi.b   #'Z',d0
          bgt.s    nieqfalse
          bra.s    nieqloop
nieqneg32  cmpi.b   #'a',d0
          blt.s    nieqfalse
          cmpi.b   #'z',d0
          bgt.s    nieqfalse
          bra.s    nieqloop
nieqtrue  moveq    #-1,d0
          rts

        XDEF    _strcmp
_strcmp:
        movem.l  4(sp),a0/a1
1$:
        cmpm.b   (a0)+,(a1)+
        bne.s   2$
        tst.b   -1(a0)
        bne.s   1$
2$      move.b  -1(a1),d0
        sub.b   -1(a0),d0
        ext.w   d0
        ext.l   d0
        rts

        XDEF    _stricmp
_stricmp   movem.l  4(sp),a0/a1
          bra.s    instricmp
icmploop   tst.b    -1(a0)
          beq.s    icmptrue
instricmp  move.b   (a1)+,d0
          move.b   (a0)+,d1
          sub.b    d0,d1
          beq.s    icmploop
          cmpi.b   #32,d1
          beq.s    icmppos32
          cmpi.b   #-32,d1
          beq.s    icmpneg32
icmpfalse  cmpi.b  #'a',d0
          blt.s    notlower1
          cmpi.b   #'z',d0
          bgt.s    notlower1
          andi.b   #%11011111,d0
notlower1 move.b   -1(a0),d1
          cmpi.b   #'a',d1
          blt.s    notlower2
          cmpi.b   #'z',d1
          bgt.s    notlower2
          andi.b   #%11011111,d1
notlower2 sub.b    d1,d0
          ext.w    d0
          ext.l    d0
          rts
icmppos32  cmpi.b   #'A',d0
          blt.s    icmpfalse
          cmpi.b   #'Z',d0
          bgt.s    icmpfalse
          bra.s    icmploop
icmpneg32  cmpi.b   #'a',d0
          blt.s    icmpfalse
          cmpi.b   #'z',d0
          bgt.s    icmpfalse
          bra.s    icmploop
icmptrue   moveq    #0,d0
          rts


        XDEF    _strncmp
_strncmp:
        movem.l  6(sp),a0/a1
        move.w  4(sp),d1
        subq.w  #1,d1
1$:
        cmpm.b  (a0)+,(a1)+
        bne.s   2$
        tst.b   -1(a0)
        dbeq    d1,1$
        moveq   #0,d0
        rts
2$      move.b  -1(a1),d0
        sub.b   -1(a0),d0
        ext.w   d0
        ext.l   d0
        rts

        XDEF    _strnicmp
_strnicmp:
          movem.l  6(sp),a0/a1
          bra.s    instrnicmp
nicmploop   tst.b    -1(a0)
          beq.s    nicmptrue
          subq.w   #1,4(sp)
          beq.s    nicmptrue
instrnicmp  move.b   (a1)+,d0
          move.b   (a0)+,d1
          sub.b    d0,d1
          beq.s    nicmploop
          cmpi.b   #32,d1
          beq.s    nicmppos32
          cmpi.b   #-32,d1
          beq.s    nicmpneg32
nicmpfalse  cmpi.b  #'a',d0
          blt.s    nnotlower1
          cmpi.b   #'z',d0
          bgt.s    nnotlower1
          andi.b   #%11011111,d0
nnotlower1 move.b   -1(a0),d1
          cmpi.b   #'a',d1
          blt.s    nnotlower2
          cmpi.b   #'z',d1
          bgt.s    nnotlower2
          andi.b   #%11011111,d1
nnotlower2 sub.b    d1,d0
          ext.w    d0
          ext.l    d0
          rts
nicmppos32  cmpi.b   #'A',d0
          blt.s    nicmpfalse
          cmpi.b   #'Z',d0
          bgt.s    nicmpfalse
          bra.s    nicmploop
nicmpneg32  cmpi.b   #'a',d0
          blt.s    nicmpfalse
          cmpi.b   #'z',d0
          bgt.s    nicmpfalse
          bra.s    nicmploop
nicmptrue   moveq    #0,d0
          rts

        XDEF    _strlen
_strlen:
         move.l  4(sp),a0
         moveq   #-1,d0
_in_strlen
         tst.b   (a0)+
         dbeq    d0,_in_strlen
         not.l   d0
         rts

        XDEF    _strcpy
_strcpy
        movem.l  4(sp),a0/a1
1$
        move.b  (a0)+,(a1)+
        bne     1$
        rts

        XDEF    _strncpy
_strncpy
        movem.l  6(sp),a0/a1
        move.w  4(sp),d1
	ble.s	2$
        subq.w  #1,d1
1$
        move.b  (a0)+,(a1)+
        dbeq    d1,1$
        beq.s   3$
2$      move.b  #0,(a1)
3$      rts

        XDEF    _strcat
_strcat
        movem.l  4(sp),a0/a1
1$      move.b  (a1)+,d0
        bne     1$
        subq.l  #1,a1
2$
        move.b  (a0)+,(a1)+
        bne     2$
        rts

        XDEF    _strncat
_strncat
        movem.l  6(sp),a0/a1
        move.w  4(sp),d1
	ble.s	3$
        subq.w  #1,d1
1$      tst.b   (a1)+
        bne     1$
        subq.l  #1,a1
2$
        move.b  (a0)+,(a1)+
        dbeq    d1,2$
        beq.s   3$
        move.b  #0,(a1)
3$      rts

        XDEF    _strpos
_strpos
        movea.l 6(sp),a0
        move.w  4(sp),d1
        moveq   #-1,d0
1$      tst.b   (a0)
        beq.s   2$
        cmp.b   (a0)+,d1
        dbeq    d0,1$
        not.l   d0
        rts
2$      moveq  #-1,d0
        rts


        XDEF    _strrpos
_strrpos
        movea.l 6(sp),a0
        move.w  4(sp),d1
        moveq   #-1,d0
1$      tst.b   (a0)+
        dbeq    d0,1$
        not.l   d0
2$      cmp.b   -(a0),d1
        dbeq    d0,2$
        ext.l   d0
        rts

        XDEF    _Hash
_Hash
        move.l  4(sp),-(sp)
        bsr     _strlen
        addq.w  #4,sp
        move.l  4(sp),a0
        moveq   #0,d1
1$
        move.b  (a0)+,d1
        beq.s   3$
        cmp.b   #'a',d1
        blt.s   2$
        cmp.b   #'z',d1
        bgt.s   2$
        and.b   #%11011111,d1
2$      mulu    #13,d0
        add.w   d1,d0
        and.w   #$07ff,d0
        bra     1$
3$      rts

        XDEF    _AllocString
_AllocString:
        move.l  4(sp),d0
        jsr     _p%new
        rts

        XDEF    _FreeString
_FreeString:
        move.l  4(sp),d0
        jsr     _p%dispose
        rts

        XDEF    _strdup
_strdup
         move.l  4(sp),a0
         moveq   #-1,d0
_in_strdup
         tst.b   (a0)+
         dbeq    d0,_in_strdup
         not.l   d0
        addq.l  #1,d0           ; add one for null byte
        jsr     _p%new          ; try to allocate
        beq.s   2$              ; if it failed, continue
        move.l  d0,a1           ; get new mem address
        move.l  4(sp),a0        ; and old string address
1$
        move.b  (a0)+,(a1)+     ;added
        bne     1$              ; if not finished, loop
2$      rts                     ; return

        END
