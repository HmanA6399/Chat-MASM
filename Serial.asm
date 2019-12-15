.Model Small




.Stack 64



.Data

Line db "-"    

VALUE db ? 

Up dw    0000h
Down dw  0D00h

.Code    

main proc far

   mov ax , @data
   mov ds , ax
   mov cx , 80
   
   mov dl , Line 
   
   mov ah , 02h
   mov dx , 0C00h
   int 10h
            
   mov dl , Line 
           
   ;DrawLine:             ; Draws a Line that splits Screen  to up and down
   ;    int 21h
   ;loop DrawLine  
   
   call InitializeUart   
   
   MainLoop:
       Check: mov ah , 01h
       int 16h
       jz Recieve
       
       mov ah , 00h
       int 16h
       
       
       cmp al , 27
       jz ZeEnd
       mov VALUE , al
       
       mov ah , 2 
       mov dx , Up
       cmp dl , 4 
        
       jz LineDown  
       
       inc dl 
       jmp CursCheck
       
       LineDown:
       
       mov dl , 01h
       inc dh
       CursCheck:
       
       cmp dh , 0Ch
       jb noScroll
       
       
       
       noScroll:
       mov Up , dx
       int 10h
       
       mov ah , 9      
       mov cx , 1
       mov bl , 0Ah
       int 10h
       
;Sending a value

;Check that Transmitter Holding Register is Empty  
    
	   mov dx , 3FDH		; Line Status Register     
	
    AGAIN:  	In al , dx 			;Read Line Status
  	   test al , 00100000b
  	   JNZ AGAIN                               ;Not empty

;If empty put the VALUE in Transmit data register
  	   mov dx , 3F8H		; Transmit data register
  	   mov  al,VALUE
  	   out dx , al

       Recieve:   ;Receiving a value

;Check that Data is Ready
	   mov dx , 3FDH		; Line Status Register     
	   
	CHK:	in al , dx 
  	   test al , 1
  	   JNZ CHK                                    ;Not Ready 

;If Ready read the VALUE in Receive data register
  	   mov dx , 03F8H
  	   in al , dx 
  	   mov VALUE , al  
  	   
       mov ah , 2 
       mov dx , Down
       cmp dl , 4 
        
       jz LineDown1  
       
       inc dl 
       jmp CursCheck1
       
       LineDown1:
       
       mov dl , 01h
       inc dh
       CursCheck1:
       
       cmp dh , 19h
       jb noScroll1
       
       
       
       noScroll1:
       mov Down , dx
       int 10h
       
       mov ah , 9      
       mov cx , 1
       mov bl , 0Eh
       int 10h
       
   jmp MainLoop
      
      
      
      
   ZeEnd:
   mov ah , 4ch
   int 21h
   
   
   
   
main endp  


;This procedure is to be written for initializing the UART (baud rate, parity, data bits, stop bits,�). Use the same parameters on both terminals.
InitializeUart proc
    



;	Set Divisor Latch Access Bit 

    mov dx,3fbh 			; Line Control Register
    mov al,10000000b		;Set Divisor Latch Access Bit
    out dx,al				;Out it                       
    
;Set LSB byte of the Baud Rate Divisor Latch register.  

    mov dx,3f8h			
    mov al,0ch			
    out dx,al       
    
;Set MSB byte of the Baud Rate Divisor Latch register.

    mov dx,3f9h
    mov al,00h
    out dx,al         
    
;Set port configuration   

    mov dx,3fbh
    mov al,00011011b   
    
;	0:Access to Receiver buffer, Transmitter buffer
;	0:Set Break disabled
;	011:Even Parity
;	0:One Stop Bit
;	11:8bits 

    out dx,al      
    ret
InitializeUart endp

 

  
        



end