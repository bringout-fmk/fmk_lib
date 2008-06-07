INCLUDE    extenda.inc                   ; clipper makroi

CLpublic   <rmdir>

;*
;* Ernad  '94.
;* NAZIV: C = RMDIR (sttr)
;*

CLfunc int RMDIR  <char str>

CLcode
           push es                       ; sacuvaj registre
           push bp
           push ds
           push dx

           Mov       AH,3Ah             ; DOS remove direktorij
           lds       dx, str
           int       21h

           jnc filax

           jmp kraj

filax:     mov ax,0

kraj:      pop dx
           pop ds
           pop bp
           pop es

CLret      AX

           END
