INCLUDE lib.inc
		.MODEL SMALL
        .STACK 64

        .DATA
TESTMSG DB "Hello from TESTER!",'$'
CURSOR1_Y EQU 10D
CURSOR2_Y EQU 22D
CURSOR1_CUR_X DB 0
CURSOR2_CUR_X DB 0
CHAR1   DB  ?
CHAR2   DB  ?


        .CODE
MAIN	PROC	FAR

        MOV	AX,@DATA
        MOV	DS,AX
        CALL CONFIG
        CLRS
        CALL DRWLINECENTER
        SETCURSOR 0,CURSOR1_Y
MAIN_LP:
        SETCURSOR CURSOR1_CUR_X,CURSOR1_Y
        CHECKKEY
        JZ START_RECIEVE        ; Means that the sender didn't press any key so go to recieve
        GETKEY1                 ; If the user clicked a button so we get it and store it in CHAR1
        COMPARE_KEY 027D        ; If ESC is clicked, Send it then end the program 
        JZ SEND_THEN_END
DONT_EXIT:
        COMPARE_KEY 0DH             ; ASCII of ENTER
        JNZ CHECK_BACKSPACE1_LB     ; If not, go check BACKSPACE
        SCROLLUP1                   ; If ENTER, Scroll one line up
        MOV CURSOR1_CUR_X,0         ; Reset cursor1_cur_x which holds the current cursor position of sender
        SETCURSOR CURSOR1_CUR_X,CURSOR1_Y ; Reset the cursor to the left  of the screen
        JMP SEND_LB
CHECK_BACKSPACE1_LB:
        COMPARE_KEY 08H         ; ASCII of backspace
        JNZ PRINT_CHAR_1        ; If not, then it's a character, go print it ! 
        CALL HANDLEBS1          ; If yes, Call the function that handles BS for sender
        JMP SEND_LB
PRINT_CHAR_1:
        SETCURSOR CURSOR1_CUR_X,CURSOR1_Y   ; Set the cursor to the proper printing position
        CALL PRTCHAR1                       ; Print the entered character in this position
        JMP SEND_LB                         

SEND_THEN_END:
        CALL SENDMSG        ; We come here in case of ESC so as to send it to the reciever before exit
END_CHAT_TRANSIT:           ; Dummy branch for resolving jump out of range issue, Ends the program
        JMP END_CHAT        
CURE_JUMP_OUT_OF_RANGE:     ; Dummy branch for resolving jump out of range issue, Returns to the start of the loop
        JMP MAIN_LP

SEND_LB:                        
        CALL SENDMSG        ; Function to send CHAR1 to the reciever 
START_RECIEVE:
        CALL RECMSG         ; Function to recieve a byte, stores ASCII in AH, if nothing is set, it puts CHAR2=0
        CMP CHAR2,0         ; Means nothing to recieve
        JZ CURE_JUMP_OUT_OF_RANGE   ; Go to the top of the loop
        COMPARE_KEY 027D            ; If ESC is clicked, end the program 
        JZ END_CHAT
        COMPARE_KEY 0DH             ; ASCII for ENTER
        JNZ CHECK_BACKSPACE2_LB     ; If not ENTER, go check BS
        SCROLLUP2                   ; Scroll the bottom screen up 1 line
        MOV CURSOR2_CUR_X,0         ; Reset CURSOR2_CUR_X 
        JMP CURE_JUMP_OUT_OF_RANGE  ; Go to the top of the loop
CHECK_BACKSPACE2_LB:
        COMPARE_KEY 08H             ; ASCII of BS
        JNZ PRINT_CHAR_2            ; If not, then it's a character, go print it ! 
        CALL HANDLEBS2              ; If yes, Call the function that handles BS for reciever
        JMP CURE_JUMP_OUT_OF_RANGE  ; Go to the top of the loop
PRINT_CHAR_2:
        SETCURSOR CURSOR2_CUR_X,CURSOR2_Y   ; Set the cursor to the proper printing position
        CALL PRTCHAR2                       ; Print the entered character in this position
        JMP CURE_JUMP_OUT_OF_RANGE          ; Go to the top of the loop
        PAUSE
END_CHAT:
        CLRS
        HALT
MAIN	ENDP

CONFIG PROC
    ; Access the control bit
    MOV DX, 03FBH
    MOV AL,80H
    OUT DX,AL
    ; Set the divisor LSB
    MOV DX,3F8H			
    MOV AL,0CH			
    OUT DX,AL
    ; Set the divisor MSB
    MOV DX,3F9H			
    MOV AL,00H			
    OUT DX,AL
    ; Set port config
    ; d7:Access to Receiver buffer, Transmitter buffer
    ; d6:Set Break disabled
    ; d5d4d3:Even Parity
    ; d2:One Stop Bit
    ; d1d0:8bits
    MOV DX,3FBH
    MOV AL, 00011011B
    OUT DX,AL

CONFIG ENDP

SENDMSG PROC
    MOV DX,03FDH
AGAIN:
    IN AL,DX            ; Line status register
    TEST AL,00100000B   ; Means NOT EMPTY
    JZ AGAIN
    MOV DX,3F8H         ; If empty, send CHAR1
    MOV AL,CHAR1
    OUT DX,AL
OUT_LB1:
    RET
SENDMSG ENDP

RECMSG  PROC
    MOV DX,03FDH    ; Check data is ready
CHK:
    IN AL,DX        
    TEST AL,1       ; Means READY
    JNZ RECEIVE_LB
    MOV CHAR2,0
    JMP OUT_LB2
RECEIVE_LB:
    MOV DX,03F8H    ; If ready, recieve
    IN AL,DX
    MOV CHAR2,AL    ; Save the recieved char in CHAR2           
OUT_LB2:
    RET             
RECMSG ENDP

PRTCHAR1 PROC
    PRTCHAR 1,CHAR1,0AH
    GETCURSOR
    INC DL
    CMP DL, 80D
    JNZ INC_CURSOR1_X
    SCROLLUP1
    MOV CURSOR1_CUR_X,0
    JMP END_UPDATE_CURSOR1
INC_CURSOR1_X:
    MOV CURSOR1_CUR_X,DL
END_UPDATE_CURSOR1:
    RET 
PRTCHAR1 ENDP

PRTCHAR2 PROC
    PRTCHAR 1,CHAR2,0BH
    GETCURSOR
    INC DL
    CMP DL, 80D
    JNZ INC_CURSOR2_X
    SCROLLUP2
    MOV CURSOR2_CUR_X,0
    JMP END_UPDATE_CURSOR2
INC_CURSOR2_X:
    MOV CURSOR2_CUR_X,DL
END_UPDATE_CURSOR2:
    RET
PRTCHAR2 ENDP

DRWLINECENTER PROC
    SETCURSOR 0,13D
    PRTCHAR 80,"=",0FH
    RET
DRWLINECENTER ENDP

HANDLEBS1   PROC        
    CMP CURSOR1_CUR_X, 0    ; If BACKSPACE, see if the cursor ia already at the left of the screen i.e. empty line
    JNZ NO_SCROLL_DOWN1
    SCROLLDOWN1
    MOV CURSOR1_CUR_X, 79D
    SETCURSOR CURSOR1_CUR_X, CURSOR1_Y
    JMP END_HANDLEBS1
NO_SCROLL_DOWN1:
    DEC CURSOR1_CUR_X
    SETCURSOR CURSOR1_CUR_X,CURSOR1_Y
    PRTCHAR 1," ",0FH
END_HANDLEBS1:
    RET
HANDLEBS1 ENDP

HANDLEBS2   PROC        
    CMP CURSOR2_CUR_X, 0    ; If BACKSPACE, see if the cursor ia already at the left of the screen i.e. empty line
    JNZ NO_SCROLL_DOWN2
    SCROLLDOWN2
    MOV CURSOR2_CUR_X, 79D
    SETCURSOR CURSOR2_CUR_X, CURSOR2_Y
    JMP END_HANDLEBS2
NO_SCROLL_DOWN2:
    DEC CURSOR2_CUR_X
    SETCURSOR CURSOR2_CUR_X,CURSOR2_Y
    PRTCHAR 1," ",0FH
END_HANDLEBS2:
    RET
HANDLEBS2 ENDP


END		MAIN