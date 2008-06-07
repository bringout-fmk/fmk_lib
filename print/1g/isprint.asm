;  Filename: ISPRINT.ASM
;  Program.: Clipper Extended Library
;  Authors.: Tom Rettig and Brian Russell, modified by Leonard Zerman
;  Date....: November 1, 1985
;  Notice..: Placed in the public domain by Tom Rettig Associates.
;  Notes...: Works for parallel printers only.
;
;
;      ISPRINTER() ::= True if the printer is online and ready
;
;------------------------------------------------------------------------------
;  ISPRINTER()
;  Syntax: ISPRINTER()
;  Return: Logical true if the printer is online and ready, otherwise false

         INCLUDE EXTENDA.INC

         CLpublic <ISPRINTER>

         CLfunc log ISPRINTER

         CLcode

         PUSH     AX
         PUSH     DX
         MOV      AH,2H          ; printer status function
         MOV      DX,0H          ; which printer to check
         INT      17H            ; read printer status

         XOR      BX,BX          ; false
         CMP      AH,90H         ; not busy or selected (90h = 10010000)
         JNE      RET_ISPRINTER  ; return false if other than above
         MOV      BX,1           ; true

RET_ISPRINTER:
         POP      DX
         POP      AX
         CLret    BX
;-----------------------------------------------------------------------------
         END
