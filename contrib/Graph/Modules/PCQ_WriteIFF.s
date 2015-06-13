
   
   XREF  _SaveIFF
   XREF  _p%DOSBase
   
   XDEF  _WriteIFF

_WriteIFF
   move.l   8(sp),a0   ;name
   move.l   4(sp),a1 ;screen
   move.l   a6,-(sp)
   move.l   _p%DOSBase,a6
   jsr   _SaveIFF
   movem.l  (sp)+,a6
   rts
   end

