title    SETDATE.ASM
page     ,132
;*
;* Program Name | SETDATE.ASM                                                *
;*       Author | Gregory B. Besch                                           *
;*      Created | 9/29/1988 at 22:41                                         *
;*      Purpose | Set the computer's system date                             *
;*       Syntax | expL = setdate(expD)                                       *
;*              | where: expD is the date to set                             *
;*              |                                                            *
;*      Example | error = setdate(ctod("09/29/88"))                          *
;*      Returns | expL  - .f. = no error, date changed successfully.         *
;*              |         .t. = error encountered, date not changed.         *
;*              |                                                            *
;*      Version | Clipper Summer '87                                         *
;*     Revision | 1.0    Last Revised: 9/29/1988  @ 22:41                    *
;* ------------------------------------------------------------------------- *
;*   Copyright (C) 1988 by Gregory B. Besch                                  *
;*   Released to the public domain 9/30/88.                                  *
;*

public   SETDATE

extrn    __PARINFO:far                             ; Clipper's Parm Info Svc
extrn    __PARDS:far                               ; Clipper's Date 'getter'
extrn    __RETL:far                                ; Clipper's Logical return

; =======[ EQUATES ]======================================================== ;
         UNDEFINED      EQU   0
         CHARACTER      EQU   1
         NUMERIC        EQU   2
         LOGICAL        EQU   4
         DATE           EQU   8
         BY_REFERENCE   EQU   32
         MEMO           EQU   65

; =======[ DATA ]=========================================================== ;
DGROUP   GROUP    DATASG                           ; Clipper's Data Segment
         DATASG   SEGMENT   PUBLIC    '_DATA'

         ; ----------------------------------------------------------------- ;
         ; Storage                                                           ;
         ; ----------------------------------------------------------------- ;
         SYSDATE        db    DATE dup(0)
         SYSYEAR        dw    0
         SYSMON         db    0
         SYSDAY         db    0

DATASG   ENDS


; =======[ CODE ]=========================================================== ;
;
_PROG    SEGMENT  BYTE  'CODE'
         ASSUME   CS:_PROG,DS:DGROUP

SETDATE  PROC     FAR
         ; ----------------------------------------------------------------- ;
         ; Save registers                                                    ;
         ; ----------------------------------------------------------------- ;
         push     bp
         mov      bp,sp                   ; Establish addressability to stack
         push     ds
         push     es
         push     si
         push     di

         ; ----------------------------------------------------------------- ;
         ; Get parameters                                                    ;
         ; ----------------------------------------------------------------- ;
;---------------------
;  Debugger breakpoint
;         db       0CCh
;---------------------
Parm1:   mov      ax,1                    ; parm number 1:  Date
         push     ax                      ; pass to ParInfo on stack
         call     __PARINFO               ; ask ParInfo what type
         add      sp,2                    ; restore stack
         cmp      ax,DATE                 ; is 1st parm date?
         je       Get1st                  ; if so, press on
         mov      ax,1                    ; if not, set ax = .t.
         jmp      Exit                    ;  and exit
Get1st:  mov      ax,1                    ; 1st parm:  Date
         push     ax                      ; pass to ParInfo on stack
         call     __PARDS                 ; call Clipper's character getter
         add      sp,2                    ; restore stack

xsetup:  push     ds                      ; save data seg
         mov      ds,dx                   ; transfer string segment ptr to es
         mov      si,ax                   ; transfer string offset ptr to di
         pop      es                      ; load data segment into es
         lea      di,SYSDATE              ; load variable offset into di
         mov      cx,8                    ; cx = 8 byte max string size
         cld
xfer:    rep      movsb                   ; move system date

convert: push     es                      ; transfer data segment back to ds
         pop      ds                      ;  via stack
         lea      si,SYSDATE              ; point es:si to SYSDATE
         mov      cx,4                    ; count = 4 bytes for year
         mov      dx,0                    ; starting value of zero
         call     DEC2BIN                 ; convert year to binary
         mov      [SYSYEAR],dx            ; save converted year
         mov      cx,2                    ; count = 2 bytes for month
         mov      dx,0                    ; starting value of zero
         call     DEC2BIN                 ; convert month to binary
         mov      [SYSMON],dl             ; save converted month
         mov      cx,2                    ; count = 2 bytes for day
         mov      dx,0                    ; starting value of zero
         call     DEC2BIN                 ; convert day to binary
         mov      [SYSDAY],dl             ; save converted day
         
dateset: mov      ah,2Bh                  ; DOS Set Date service
         mov      dh,[SYSMON]             ; system month
         mov      dl,[SYSDAY]             ; system day
         mov      cx,[SYSYEAR]            ; system year
         int      21h                     ; call DOS to set date
         mov      ah,0                    ; zero ah for return

exit:    pop      di                      ; restore registers
         pop      si
         pop      es
         pop      ds
         pop      bp

         push     ax                      ; push return code on stack
         call     __RETL                  ; and return it to clipper
         add      sp,2                    ; restore stack
         ret                              ; bye bye

DEC2BIN  PROC     NEAR
GetDigit:push     cx
         lodsb                            ; Get a digit
         sub      al,30h                  ; convert to binary
         cbw                              ; convert to word
         push     ax                      ; save it temporarily
         mov      ax,dx                   ; get current value
         mov      cx,10                   ; multiplier
         mul      cx                      ; adjust for place value
         mov      dx,ax                   ; move it back to dx
         pop      ax                      ; retrieve current digit
         add      dx,ax                   ; add it to cumulative value
         pop      cx                      ; restore digit count
         loop     GetDigit                ; and get next digit
         ret
DEC2BIN  ENDP

SETDATE  ENDP

_PROG    ENDS                             ; End of segment
         END
