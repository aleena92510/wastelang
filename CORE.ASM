; ========================================
; Welcome to Wastelang
; Classic Direct Threaded FORTH written 
; in DEBUG.COM
; ========================================

; Output file name
n core.com
rcx FFFF
; [ENTRY POINT]
a 100 
cld
mov ah, 9
mov dx, 350 ; info text
int 21      ; write out info txt
mov sp, 200 ; SP = data stack
mov bp, 220 ; BP = return stack
mov si, 500 ; SI = Instruction Pointer (set to outer interpreter)
lodsw       ; Inner Interpreter (NEXT)
jmp ax

; The data stack goes down to 0, starts at 200h
; The return stack (2x16b) goes up, starts at 220h

a 240
; INPUT_INDEX
db 0

a 242
; INPUT BUFFER 80+2 byte long, first byte is the length of the buffer - ADDR=242h
; after reading from STDIN the 2nd byte contains the length of the actual input
db 50,0,D

a 294
; 80 byte long word name buffer 
db D

a 302
; STATE (0=INTERPRET, 1=COMPILE)
db 0 

a 304
; HERE
dw B00

a 306
; Last Defined Word
dw 4000

a 350
db "Welcome to Wastelang v0.1","$"

a 380
db "wastelng.com",0

a 400
; [Subroutine Enter]
mov [bp], si
add bp, 2
add ax, 6  ; skip "JMP 400" + nop
mov si, ax ; jumping back to the word
lodsw
jmp ax

a 500
; [Outer Interpreter]
;@loop:
  ;  WORD                          ; ( -- len a | 0 )
  dw 1C05
  ;  FIND                          ; ( len a -- IM? XT TRUE | a len FALSE )
  dw 1D05
  ;  BRANCH0  @unknown
  dw 1508,    20
  ;  SWAP, INVERT                  ; immediate?
  dw 1205, 1607                    
  ;  BRANCH0 @exec                 ; jump if immediate
  dw 1508,   12       
  ;  LIT   STATE @                 ; interpret mode?
  dw 1104, 302,  1902              
  ;  BRANCH0 @exec                 ; jump if we're interpret mode
  dw 1508,   08                  
  ;  ,                             ; compile
  dw 1B02
  ;  BRANCH @loop (-30)
  dw 1407,   ffe2
;@exec:  
  ;  EXEC
  dw 1705
  ;  BRANCH @loop (-36)
  dw 1407,  ffdc
;@unknown:
  ; >NUM                           ; ( num TRUE | FALSE )
  dw 1E05
  ;  BRANCH0 @NaN  
  dw 1508,   18  
  ;  LIT   STATE  @      
  dw 1104, 302,   1902
  ;  BRANCH0  @loop
  dw 1508,    ffcc
  ;  LIT   LIT   ,     ,          ; ( compile the number literal )  
  dw 1104, 1104, 1B02, 1B02
  ;  BRANCH @loop
  dw 1407,  ffc0
;@NaN:
  ;  LIT   3F  EMIT               ; emit error message
  dw 1104, 3F, 1005              
  ;  LIT   0  LIT   STATE !       ; switch back to interpret mode
  dw 1104, 0, 1104, 0302, 1A02
  ;  BRANCH  @loop
  dw 1407,   ffac
    
; ========================================
; Dictionary starts at 1000h
; ========================================

; [PRIMITIVE]
a 1000
db 4,"emit"
pop dx
mov ah, 02
int 21
lodsw
jmp ax

; [PRIMITIVE]
a 1100
db 3,"lit"
lodsw
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 1200
db 4,"swap"
pop ax
pop bx
push ax
push bx
lodsw
jmp ax

; [PRIMITIVE]
a 1300
db 3,"bye"
mov ah, 4C
xor al, al
int 21

; [PRIMITIVE]
a 1400
db 6,"branch"
add si, [si]
lodsw
jmp ax

; [PRIMITIVE]
a 1500
db 7,"branch0"
pop ax
test ax, ax
jz 1407       ; code_branch
lodsw         ; SKIP THE ADDRESS 
lodsw
jmp ax

; [PRIMITIVE]
a 1600
db 6,"invert"
pop ax
not ax        ; each 1 is set to 0, and each 0 is set to 1
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 1700
db 4,"exec"
pop ax
jmp ax

; [PRIMITIVE]
a 1800
db 4,"halt"
int 3
lodsw
jmp ax

; [PRIMITIVE]
a 1900
db 1,"@"
pop bx
mov ax, [bx]
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 1A00
db 1,"!"
pop di
pop ax
stosw
lodsw
jmp ax

; [PRIMITIVE]
a 1B00
db 1,","
mov bx, 304          ; 304 = var_here
mov di, [bx]         ; bx = here
pop ax               ; number to be written
stosw
mov [bx], di
lodsw
jmp ax

; [WORD]    ( -- len adr )
a 1C00
db 4,"word"
nop
mov bx, 400 ; ENTER WORD
jmp bx
;  LIT   0  future length of the world
dw 1104, 0
;  LIT   20
dw 1104, 20
;@word_trim:
;  DROP     drop placeholder/whitespace
dw 2A05
;  KEY
dw 3004
;  DUP   LIT   20  XOR   BRANCH0 @word_trim (-14) 
dw 2604, 1104, 20, 3104, 1508,  fff2
;  DUP   LIT   0A  XOR   BRANCH0 @word_trim (-26)
dw 2604, 1104, 0A, 3104, 1508,  ffe6
;  DUP   LIT   0D  XOR   BRANCH0 @word_trim (-38)
dw 2604, 1104, 0D, 3104, 1508,  ffda
;  DUP   LIT   09  XOR   BRANCH0 @word_trim (-50)
dw 2604, 1104, 09, 3104, 1508,  ffce
;@getchar:
; ( len chr  )
;  OVER  LIT   wbuf +     c!
dw 3305, 1104, 294, 2C02, 3203
; LIT    1  +     increse the length
dw 1104, 1, 2C02
;  KEY
dw 3004
;  DUP   LIT   20  XOR   BRANCH0 @end_of_word (+42)
dw 2604, 1104, 20, 3104, 1508, 2a
;  DUP   LIT   0A  XOR   BRANCH0 @end_of_word (+30)
dw 2604, 1104, 0A, 3104, 1508, 1e
;  DUP   LIT   0D  XOR   BRANCH0 @end_of_word (+18)
dw 2604, 1104, 0D, 3104, 1508, 12
;  DUP   LIT   09  XOR   BRANCH0 @end_of_word (+6)
dw 2604, 1104, 09, 3104, 1508, 06
;  BRANCH @getchar (-68)
dw 1407,  ffbc
;@end_of_word:
;  DROP  LIT   wbuf
dw 2A05, 1104, 294
;  exit
dw 2105

; [PRIMITIVE]        ( len adr -- IM? XT TRUE | adr len FALSE )
a 1D00
db 4,"find"
pop  dx              ; word to be found in dictionary
pop  ax              ; length of the word
push si              ; save Forth IP
mov  bx, [306]       ; last dictionary entriy is defined 
;@find_loop:
cmp  bx, 1000        ; first dictionary entry is defined at 1000h
jb   1D2A            ; @not_found
mov  cl, [bx]        ; lenght + imm. bit of word in dictionary
and  cx, 7F          ; clear the immediate bit
cmp  ax, cx          ; check length
jnz  1D24            ; @try_next_word
lea  si, [bx + 1]    ; name start
mov  di, dx
repz cmpsb
je   1D32            ; @found
;@try_next_word:
sub  bx, 100         ; step back to previous dictionary entry
jmp  1D0C            ; @find_loop
;@not_found:
pop  si              ; restore FORTH IP
push dx              ; word
push ax              ; len
push  0              ; NOT FOUND - FALSE
lodsw                ; NEXT
jmp  ax
;@found:
pop  si              ; restore FORTH IP
mov  ch, [bx]        ; length + imm. bit
sar  cx, 15          ; get the imm. bit
push cx              
add  bx, ax          ; advance with length
inc  bx
push bx              ; XT of the word
mov  ax, FFFF
push ax              ; FOUND - TRUE
lodsw                ; NEXT
jmp  ax

; [PRIMITIVE]           ( a len -- num TRUE | FALSE )
a 1E00
db 4,">num"             
pop  bx                 ; length
pop  di                 ; string
xor  cx, cx             ; result
push si                 ; save FORTH IP
mov  si, 1
cmp  byte [di], 2d      ; check is negativ
jnz  1E17               ; @tonum_loop
inc  di                 ; skip sign
dec  bx                 ; dec length
mov  si, FFFF           ; -1
;@tonum_loop:
xor  ax, ax
mov  al, [di + bx -1]  ; last digit
cmp  al, 30            ; character '0'
jb   1E3F              ; @tonum_nan
cmp  al, 39            ; character '9'
ja   1E3F              ; @tonum_nan
sub  al, 30            ; numeric value
mul  si                ; 
add  cx, ax            ; accumulate result
mov  ax, si
mov  dx, 0A            ; next power of 10
mul  dx
mov  si, ax
dec  bx
jnz  1E17              ; @tonum_loop
pop  si
push cx
mov  ax, FFFF
push ax                ; TRUE
lodsw                  ; NEXT
jmp  ax
;@tonum_nan:    
pop  si
push 0    
lodsw                  ; NEXT
jmp  ax

; [PRIMITIVE]   ( len a -- )
a 1F00
db 5,"mkhdr"    
pop  bx         ; word
pop  cx         ; len
push si       
mov  si, bx     ; word
mov  bx, 306    ; lastword@
mov  di, [bx]
add  di, 100    ; advance lastword
mov  [bx], di
mov  al, cl     ; store length of word
stosb
rep  movsb      ; copy word name
mov  bx, 304    ; advance dp/here
mov  [bx], di   ; 
pop  si
lodsw
jmp  ax

; [WORD] 
a 2000
db 81,";"
nop
mov bx, 400 ; ENTER WORD
jmp bx
; LIT    0  LIT   STATE !
dw 1104, 0, 1104, 0302, 1A02
; LIT    exit   ,
dw 1104, 2105,  1B02
; EXIT
dw 2105

; [PRIMITIVE]
a 2100
db 4,"exit"
sub bp, 2
mov si, [bp]
lodsw
jmp ax

; [WORD]
a 2200
db 1,":"
nop
mov bx, 400
jmp bx
;  WORD  MKHDR
dw 1C05, 1F06
dw 1104, BB90, 1B02
dw 1104, 0400, 1B02
; jmp bx
dw 1104, E3FF, 1B02
; LIT    1  LIT   STATE !
dw 1104, 1, 1104, 0302, 1A02
; EXIT
dw 2105

; [PRIMITIVE]
a 2300
db 9,"immediate"
mov di, [306] ; LAST_WORD
mov al, [di]
or al,  80
stosb
lodsw
jmp ax

; [PRIMITIVE]
a 2400
db 4,"here"
mov di, 304 ; here
mov ax, [di]
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 2500
db 1,"-"
pop bx
pop ax
sub ax, bx
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 2600
db 3,"dup"
mov bx, sp
mov ax, [bx]
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 2700
db 3,"rot"
pop cx
pop bx
pop ax
push bx
push cx
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 2800
db 1,"<"
xor ax, ax
pop bx
pop dx
cmp dx, bx
jnl 280D      ;@not_less
mov ax, FFFF
;@not_less:
push ax    
lodsw
jmp ax

; [PRIMITIVE]
a 2900
db 4,"/mod"
pop bx
pop ax
xor dx, dx
cwd
idiv bx
push dx
push ax
lodsw
jmp  ax

; [PRIMITIVE]
a 2A00
db 4,"drop"
pop  ax
lodsw
jmp ax

; [PRIMITIVE]
a 2B00
db 1,"*"
pop ax
pop bx
imul bx
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 2C00
db 1,"+"
pop ax
pop bx
add ax, bx
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 2D00
db 2,"or"
pop ax
pop bx
or ax, bx
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 2E00
db 3,"and"
pop ax
pop bx
and ax, bx
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 2F00
db 5,"depth"
mov ax, 200
mov bx, sp
sub ax, bx
shr ax, 1
push ax
lodsw
jmp ax

; [PRIMITIVE]       ( -- c )
a 3000
db 3,"key"          
push si             ; save FORTH IP
;get next char from the buffer if available
mov ah, [0243]      ; buffer length
mov al, [0240]      ; input_index
cmp al, ah          ; check if buffer is fully processed
jbe  303D           ; @get_from_buffer - including the final CR
mov dx, 0A          ; write lf
mov ah, 2           ; 
int 21              ; 
mov dx, 0D          ; write cr
mov ah, 2           ; 
int 21              ; 
xor al, al          ; if buffer is empty read next line
mov [0240], al      ; reset input index
mov [0243], al      ; reset result length for DOS
mov ah, 0A          ; STDIN read; str is terminated by CR (0Dh)
mov dx, 0242        ; input buffer, 1st byte=buffer size, 2nd length of the string
int 21              ; read line from STDIN
; move cursor
xor bx, bx
mov ah, 3
int 10
mov ah, 2
mov dl, [243]
inc dl
int 10
;@get_from_buffer:
xor  ax, ax
mov  si, 0244       ; input buffer+2, contains the string
add  si, [0240]     ; buffer beginning + input_index
inc  byte [0240]    ; advance input index
lodsb               ; load next byte
pop  si             ; restore IP
push ax
lodsw               ; NEXT
jmp ax

; [PRIMITIVE]
a 3100
db 3,"xor"
pop  ax
pop  bx
xor  ax, bx
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 3200
db 1,"c!"
pop di
pop ax
stosb
lodsw
jmp ax

; [PRIMITIVE]
a 3300
db 4,"over"
mov  bx, sp
mov  ax, [bx+2]
push ax
lodsw
jmp ax

; [PRIMITIVE]
a 3400
db 5,"allot"
pop  cx
mov  di, 304          ; 304 = var_here
mov  ax, [di]         ; dp
add  ax, cx           ; advance dp
stosw
lodsw
jmp ax

; [PRIMITIVE]
a 3500
db 5,"(bye)"
pop ax
mov ah, 4C
int 21

; [PRIMITIVE]
a 3600
db 6,"lshift"
pop  cx
pop  ax
shl  ax, cl
push ax
lodsw
jmp  ax

; [PRIMITIVE]
a 3700
db 6,"rshift"
pop  cx
pop  ax
shr  ax, cl
push ax
lodsw
jmp  ax

; [PRIMITIVE]
a 3800
db 2,"c,"
mov bx, 304          ; 304 = var_here
mov di, [bx]         ; bx = here
pop ax               ; number to be written
stosb
mov [bx], di
lodsw
jmp ax

; [PRIMITIVE]
a 3900
db 4,"save"
mov ah, 3C
xor cx, cx            ; attributes
mov dx, 380           ; file name (ASCIIZ)
int 21                ; create file
mov bx, ax            ; file handle
push bx
mov cx, FFFF          ; number of bytes
mov dx, 100           ; starting address
mov ah, 40
int 21                ; dump memory into file
pop bx                ; file handle
mov ah, 3E
int 21                ; close file
mov ah, 4C
xor al, al
int 21                ; bye

; [PRIMITIVE]
a 4000
db 2,"c@"
pop bx
xor ax, ax
mov al, [bx]  
push ax
lodsw
jmp ax

; Save binary
w 100

