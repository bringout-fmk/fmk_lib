; LPTSWAP.ASM
;
; by Ralph Davis
; modified by Rick Spence
;
; Placed in the public domain by Tom Rettig Associates, 10/22/1990.
;

         PUBLIC   LPTSWAP

;*
LPTSWAP_TEXT SEGMENT BYTE PUBLIC 'CODE'
         ASSUME   CS:LPTSWAP_TEXT
;----------------------------------------
LPTSWAP  PROC     FAR
         PUSH     BP 
         PUSH     SI
         PUSH     DI
         PUSH     DS
         PUSH     ES
         MOV      AX,40H   ; Point to system data segment
         MOV      DS,AX
         MOV      ES,AX
         MOV      SI,8     ; Point to address of LPT1
         MOV      DI,8
         CLD
         LODSW             ; Pick up LPT1 port address
         XCHG     AX,[SI]  ; SI now pointing to LPT2, exchange
         STOSW             ; DI points to LPT1
         POP      ES
         POP      DS
         POP      DI
         POP      SI
         POP      BP
         RET
LPTSWAP  ENDP
;------------------------------------
LPTSWAP_TEXT    ENDS
;*
         END

