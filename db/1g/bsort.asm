
INCLUDE    extenda.inc                   ; clipper makroi

DATASEG

CLpublic   <bupper, blower, btoe>

CLstatic   <string smallb "~`{}|">      ; mala Bos slova
CLstatic   <string bigb "^@[]\">        ; velika Bos slova
CLstatic   <string abc "ABC^]D\*EFGHIJKL*MN*OPRS[TUVZ@">
;AZBUKA              "ABVGD\E@ZIJKL*MN*OPRST]UFHC^*["
;ABECEDA             "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^"



;*
;*
;* DATUM: 11. 08. 1993.
;*
;* NAZIV: C = BUPPER (sttr)
;*
;* OPIS: UPPER sa BOS slovima
;*
;*
;*

CLfunc char BUPPER <char str>

CLcode
           push es                       ; sacuvaj registre
           push bp
           push si

           jmp begin

r_str      db 80 dup (0)                 ; radni bafer

begin:     les si, str                   ; es:si =adresa od str
           mov bx, 0                     ; obrada prvog simbnola

cikl:      mov al, es:[si+bx]          ; uzmi prvi simbol
           mov r_str [bx], al            ; upi{i u radni bafer
           or al, al                     ; ako je 0, kraj
           jz kraj

           cmp al, 'a'                   ; da li je simbol malo slovo
           jl b_letter
           cmp al, 'z'
           jg b_letter

           sub byte ptr r_str[bx], ' '   ; <kod slova>-32
           jmp next_char

b_letter:                               ; da li je simbol B slovo
           mov bp,0
tab:       mov al, byte ptr smallb[bp]         ; da li se poklapa sa malim B?
           or al, al                     ; kraj tabele?
           jz next_char
           cmp byte ptr r_str[bx], al    ; uporedi simbol sa tabelarnim
           jne next                      ; nije taj!

           mov al, byte ptr bigb[bp]           ; jeste, zamijeni ga velikim slovom
           mov byte ptr r_str[bx], al    ; ... i u bafer

next:      inc bp                        ; sljede}i simbol iz tabele
           jmp tab

next_char:                               ; analiziraj dalje ulazni string
           inc bx
           jmp cikl

kraj:      mov ax, seg r_str              ; ax:bx = adresa od r_str
           mov bx, offset r_str

           pop si
           pop bp
           pop es

CLret      AX BX                          ; return r_str


;*
;*
;* DATUM: 11. 08. 1993. GODINE
;*
;* NAZIV: C = BLower (str)
;*
;* OPIS: LOWER sa Bos slovima
;*
;*
;*

CLfunc char BLOWER <char str>

CLcode
           push es                     ; sacuvaj registre
           push bp

           les si, str                 ; uzmi adresu stringa
           mov bx, 0

cikl1:     mov al, es:[si+bx]          ; uzmi prvi simbol
           mov r_str[bx], al           ; upisi ga u radni bafer
           or al, al
           jz kraj1

           cmp al, 'A'                 ; da li je simbol veliko slovo
           jl B_letter1
           cmp al, 'Z'
           jg B_letter1

           add byte ptr r_str [bx], ' '; A --> a
           jmp next_char1

b_letter1:                            ; Da li je veliko B slovo?
           mov bp, 0
tab1:      mov al, byte ptr bigb [BP] ; Uzmi simbol iz tabele!
           or al, al                   ; Da li je kraj tabele?
           JE next_char1
           CMP BYTE PTR r_str [BX], AL ; Uporedi sa tek. simbolom
           jne next1

           MOV AL, BYTE PTR smallb[BP]; Suma - > sumica
           MOV byte ptr r_str[BX], al
next1:     INC BP                      ; Slijede}i simbol iz tabele
           JMP tab1

next_char1:
           INC BX                      ; Sljede}i simbol iz stringa
           JMP cikl1

kraj1:     MOV AX , SEG r_str          ; AX:BX = Adresa od r_str
           MOV BX, OFFSET r_str

           POP BP
           POP ES

CLret      AX BX                            ; RETURN R_STR



;*
;*
;* DATUM: 11. 08. 1993. godine
;*
;* NAZIV: c = BtoE (str)
;*
;* OPIS: Kodiranje reci iz B abecede
;*
;*
;*


CLfunc char BTOE <char str>

CLcode
           PUSH ES                     ; Sa~uvaj registre
           PUSH BP
           PUSH DX
           PUSH DI
           PUSH SI
           JMP  beg_btoe

beg_btoe:
           LES SI, str                 ; Adresa ulaznog stringa
           MOV BX, 0                   ; pokaziva~ na ulazni string
           MOV DI, 0                   ; pokaziva~ na izlazni string

get_chr:                               ; Uzmi ulazni simbol
           MOV AL, ES:[SI+BX]
           OR al,al
           JZ end_btoe                 ; Da li je kraj?

           MOV AH, ES:[SI+BX+1]        ; da nisu slova D@, LJ ILI NJ ?

           CMP AL, 'D'                 ; ----D@
           JNE lj
           CMP AH, '@'
           JNE lj
           MOV byte ptr r_str[DI], 'H'
           INC DI
           INC BX
           JMP end_tab

lj:        CMP AL, 'L'                 ; ----LJ
           JNE nj
           CMP AH, 'J'
           JNE nj
           MOV byte ptr r_str[DI], 'Q'
           INC DI
           INC BX
           JMP end_tab

nj:        CMP AL, 'N'                 ; ----NJ
           JNE cont
           CMP AH, 'J'
           JNE cont
           MOV byte ptr r_str[DI], 'T'
           INC DI
           INC BX
           JMP end_tab
                                       ; Tra`enje u B tabeli
cont:      MOV BP, 0                   ; pokaziva~ na tabelu

tab_loop:
           MOV AL, BYTE PTR abc[BP]    ; Uzmi simbol iz B tabele
           OR AL, AL                   ; Kraj tabele?
           JNE cont_tab

           MOV AL, ES:[SI+BX]          ; Nema ga u tabeli, prepi{i ga
           MOV BYTE PTR r_str[DI], AL
           INC DI
           JMP end_tab

cont_tab:
           CMP BYTE PTR ES:[SI+BX], AL ; Da li je simbol u tabeli?
           JNE next_tab                ; Nije

           MOV AX, BP                  ; Jeste, BP+'A' - > rezultat
           MOV BYTE PTR r_str[DI], AL
           ADD BYTE PTR r_str[DI], 'A'

           INC DI                      ; Sljede}i
           JMP end_tab

next_tab:
           INC BP
           JMP tab_loop

end_tab:
           INC BX
           JMP get_chr

end_btoe:
           MOV r_str[DI], 0            ; Kraj stringa
           MOV AX, SEG r_str           ; AX:BX=Adresa od R_STR
           MOV BX, OFFSET r_str

           POP SI                      ; Vrati registre
           POP DI
           POP DX
           POP BP
           POP ES

CLret      AX BX                      ; RETURN R_STR

           END

