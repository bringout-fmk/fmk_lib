title    SETTIME.ASM
page     ,132
;*
;* Program Name | SETTIME.ASM                                                *
;*       Author | Gregory B. Besch                                           *
;*      Created | 9/29/1988 at 22:41                                         *
;*      Purpose | Set the computer's system time.                            *
;*       Syntax | expL = settime(expC)                                       *
;*              | where: expC is the time to set, in the same format         *
;*              |        returned by Clipper's time() function.              *
;*              |                                                            *
;*      Example | error = settime("22:41:01")                                *
;*      Returns | expL  - .f. = no error, time changed successfully.         *
;*              |         .t. = error encountered, time not changed.         *
;*              |                                                            *
;*      Version | Clipper Summer '87                                         *
;*     Revision | 1.0    Last Revised: 9/29/1988  @ 22:41                    *
;* ------------------------------------------------------------------------- *
;*   Copyright (C) 1988 by Gregory B. Besch                                  *
;*   Released to the public domain 9/30/88.                                  *
;*

public   SETTIME

extrn    __PARINFO:far                             ; Clipper's Parm Info Svc
extrn    __PARC:far                                ; Clipper's Char 'getter'
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
         SYSTIME        db    8 dup(0)
         SYSHRS         db    0
         SYSMIN         db    0
         SYSSEC         db    0

DATASG   ENDS


; =======[ CODE ]=========================================================== ;
;
_PROG    SEGMENT  BYTE  'CODE'
         ASSUME   CS:_PROG,DS:DGROUP

SETTIME  PROC     FAR
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
Parm1:   mov      ax,1                    ; parm number 1:  Time
         push     ax                      ; pass to ParInfo on stack
         call     __PARINFO               ; ask ParInfo what type
         add      sp,2                    ; restore stack
         cmp      ax,CHARACTER            ; is 1st parm Character?
         je       Get1st                  ; if so, press on
         mov      ax,1                    ; if not, set ax = .t.
         jmp      Exit                    ;  and exit
Get1st:  mov      ax,1                    ; 1st parm:  Time
         push     ax                      ; pass to ParInfo on stack
         call     __PARC                  ; call Clipper's character getter
         add      sp,2                    ; restore stack

xsetup:  push     ds                      ; save data seg
         mov      ds,dx                   ; transfer string segment ptr to es
         mov      si,ax                   ; transfer string offset ptr to di
         pop      es                      ; load data segment into es
         lea      di,SYSTIME              ; load variable offset into di
         mov      cx,8                    ; cx = 8 byte string size
         cld
xfer:    rep      movsb                   ; move system date

convert: push     es                      ; transfer data segment back to ds
         pop      ds                      ;  via stack
         lea      si,SYSTIME              ; point es:si to SYSTIME
         mov      cx,2                    ; count = 2 bytes for hour
         mov      dx,0                    ; starting value of zero
         call     DEC2BIN                 ; convert hour to binary
         mov      [SYSHRS],dl             ; save converted hour
         inc      si                      ; bump si past colon separator
         mov      cx,2                    ; count = 2 bytes for minutes
         mov      dx,0                    ; starting value of zero
         call     DEC2BIN                 ; convert minutes to binary
         mov      [SYSMIN],dl             ; save converted minutes
         inc      si                      ; bump si past colon separator
         mov      cx,2                    ; count = 2 bytes for seconds
         mov      dx,0                    ; starting value of zero
         call     DEC2BIN                 ; convert seconds to binary
         mov      [SYSSEC],dl             ; save converted seconds
         
timeset: mov      ah,2Dh                  ; DOS Set Time service
         mov      ch,[SYSHRS]             ; system hour
         mov      cl,[SYSMIN]             ; system minutes
         mov      dh,[SYSSEC]             ; system seconds
         mov      dl,0                    ; hundredths of seconds
         int      21h                     ; call DOS to set time
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

SETTIME  ENDP

_PROG    ENDS                             ; End of segment
         END

