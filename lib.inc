; GETCURSOR - Get cursor pos., X=>DL & Y=>DH
GETCURSOR MACRO
    MOV AH,03H
    MOV BH,00H
    INT 10H
ENDM GETCURSOR

; SETCURSOR - Set cursor X and Y
; Params: X,Y 
SETCURSOR MACRO X,Y
    MOV AH,02H
    MOV BH,00H
    MOV DL,X
    MOV DH,Y
    INT 10H
ENDM SETCURSOR

CHECKKEY MACRO
    MOV AH,01H
    INT 16H
ENDM CHECKKEY

; GETKEY - Get key pressed (Wait for a key-AH:scancode,AL:ASCII) 
GETKEY MACRO 
    MOV AH,0
    INT 16H
ENDM GETKEY

; GETKEY - Get key pressed (Wait for a key-AH:scancode,AL:ASCII) 
GETKEY1 MACRO
    GETKEY
    MOV CHAR1,AL
ENDM GETKEY
; GETKEY - Get key pressed (Wait for a key-AH:scancode,AL:ASCII) 
GETKEY2 MACRO 
    GETKEY
    MOV CHAR2,AL
ENDM GETKEY



;GETKEY_NOWAIT - Get key pressed without waiting
GETKEY_NOWAIT MACRO
    MOV AH,1
    INT 16H
    clearkeyboardbuffer
ENDM GETKEY_NOWAIT

;--------------------------------------------------------------------------
; clears keyboard buffer
;--------------------------------------------------------------------------
clearkeyboardbuffer MACRO
	push	ax
	mov		ax, 0000h
	mov		es, ax
	mov		es:[041ah], 041eh
	mov		es:[041ch], 041eh				; Clears keyboard buffer
	pop		ax
endm  clearkeyboardbuffer


; COMPARE_KEY - Compares a keyboard key Stored in AH with a Given scan code and sets ZF if equal
; Params: (byte) KASCII - ASCII code for the compared key  
COMPARE_KEY MACRO KASCII
    CMP AL, KASCII
ENDM COMPARE_KEY

; PRTCHAR - Print a char with a color
PRTCHAR MACRO NTIMES, CHAR_ASCII, COLOR 
    MOV AH,09H
    MOV BH,0
    MOV AL,CHAR_ASCII
    MOV CX,NTIMES ; No of times
    MOV BL,COLOR
    INT 10H
ENDM PRTCHAR

; PRINTMSG - Print message 
; Params: MSG - (byte[]1) message to print
PRINTMSG MACRO MSG
    MOV AX,09H
    MOV DX,offset MSG
    INT 21H
ENDM PRINTMSG

HALT MACRO
    MOV AH,4CH
    INT 21H
ENDM HALT

; SCROLL: Scroll up no of lines in a specific window
; Params:   NLINES - no. of lines
;           X1 - x of upper left corner
;           Y1 - y of upper left corner
;           X2 - x of lower right corner
;           Y2 - y of lower right corner
; USES : AX,BX,CX,DX
SCROLL MACRO NLINES,X1,Y1,X2,Y2 
    MOV AH,06H
    MOV AL,NLINES
    MOV BH,07H  ; Normal video attribute
    MOV CH,Y1
    MOV CL,X1
    MOV DH,Y2
    MOV DL,X2
    INT 10H
ENDM SCROLL

; SCROLLDOWN: Scroll down no of lines in a specific window
; Params:   NLINES - no. of lines
;           X1 - x of upper left corner
;           Y1 - y of upper left corner
;           X2 - x of lower right corner
;           Y2 - y of lower right corner
; USES : AX,BX,CX,DX
SCROLLDOWN MACRO NLINES,X1,Y1,X2,Y2 
    MOV AH,07H
    MOV AL,NLINES
    MOV BH,07H  ; Normal video attribute
    MOV CH,Y1
    MOV CL,X1
    MOV DH,Y2
    MOV DL,X2
    INT 10H
ENDM SCROLLDOWN


SCROLLUP1 MACRO
    SCROLL 1,0,0,79D,12D
ENDM SCROLLUP1

SCROLLUP2 MACRO
    SCROLL 1,0,14D,79D,24D
ENDM SCROLLUP2

SCROLLDOWN1 MACRO
    SCROLLDOWN 1,0,0,79D,12D
ENDM SCROLLDOWN1

SCROLLDOWN2 MACRO
    SCROLLDOWN 1,0,14D,79D,24D
ENDM SCROLLDOWN2


CLRS MACRO
    MOV AX,0600H
    MOV BH,07H
    MOV CX,0
    MOV DX,184FH
    INT 10H
ENDM CLRS

PAUSE MACRO
LB: JMP LB
ENDM PAUSE