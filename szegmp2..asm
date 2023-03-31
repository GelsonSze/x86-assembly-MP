;Gelson Sze S14
%include "io.inc"
section .data
input times 21 db 0
output times 8 db 0
segmentno db 0
counter db 0
pos db 0
nonbinmsg db "Error: Input should be 1's and 0's only!",10,0
non12bitmsg db "Error: Input should be 12 bits in length!",10,0
section .text
global main
main:
    mov ebp, esp; for correct debugging
    ;write your code here
    PRINT_STRING "Input 12-bit code: "
    GET_STRING input, 21
    PRINT_STRING [input]
    NEWLINE
    xor esi, esi ;index displacement
    xor bl, bl ;flag to check if non binary is inputted
    
loop1:
    mov al, byte[input + esi] ;get next character
    cmp al, 0 ;check if null character
    jz endloop1 ;end loop if null character encountered
    
    sub al, '0' ;get value of number
    cmp al, 1   ;check if input is 0 or 1
    ja setnonbin ;if above 1 set flag to 1
returnnonbin:    
    inc esi
    inc byte[counter]
    
    jmp loop1 ;next iteration
   
setnonbin:
    mov bl, 1
    jmp returnnonbin
    
endloop1: ;end of loop
    cmp bl, 1 ;if nonhex input flag is set
    je print_nonbinmsg
    jmp skip1 ;else skip print
    
print_nonbinmsg:
    PRINT_STRING nonbinmsg
    
skip1:
    cmp byte[counter], 12 ;if input length is not 12
    jne print_non12bitmsg
    jmp skip2 ;else skip print
    
print_non12bitmsg:
    PRINT_STRING non12bitmsg
    
skip2:
    PRINT_DEC 1, [counter]
    NEWLINE
    mov esi, 1 ;check for segment 0
    mov ah, 6  ;offset to get segment from pos
loop2:
    cmp esi, 8 ;check if segment is 8, 8 means segment is 0
    je endloop2
    
    cmp byte[input + esi], '1' 
    je endloop2
    
    inc esi
    sub ah, 2
    jmp loop2
    
endloop2:
    mov ebx, esi
    cmp bl, 8 ;if bl is 8, segment = 0
    je seg0
    
    add bl, ah ;get segment from pos
    jmp skip3
seg0:
    xor bl, bl
    mov ah, 8
    
skip3:    
    mov [segmentno], bl ;store segment number
    mov bl, [segmentno]
    sub bl, ah ; bl gets pos
    mov [pos], bl ;store position of first 1
    
    ;get sign bit
    mov al, [input]
    mov [output], al
    ;get next 3 bits for segment pos
    ;4 2 1 -> X Y Z
    mov dl, [segmentno]
    mov al, 4
    mov ebx, 1
    mov ecx, 3
loop3:
    jecxz endloop3
    cmp dl, al
    jge set1
    mov [output+ebx], 0
    jmp skip4
set1:
    mov [output+ebx], 1
skip4:
    idiv ax, 2
    mov ax, al
    inc ebx
    loop loop3
    
endloop3:
    PRINT_STRING output
    PRINT_STRING "Segment number: "
    PRINT_DEC 1, [segmentno]
    xor eax, eax
    ret