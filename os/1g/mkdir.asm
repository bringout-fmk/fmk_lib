INCLUDE    extenda.inc                   ; clipper makroi

CLpublic   <mkdir>

;*
;* Ernad  '94.
;* NAZIV: C = MKDIR (sttr)
;*

CLfunc int MKDIR  <char str>

CLcode
           push es                       ; sacuvaj registre
           push bp
           push ds
           push dx

           Mov       AH,39h             ; DOS service-create direktorij
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
