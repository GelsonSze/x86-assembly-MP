;Gelson Sze S14
%include "io.inc"
section .data
input times 14 db 0
output times 9 db 0
segmentno db 0
counter db 0
pos db 0
nonbinmsg db "Error: Input should be 1's and 0's only!",10,0
non12bitmsg db "Error: Input should be 12 bits in length!",10,0
section .text
global main
main:
    PRINT_STRING "Input 12-bit code: "
    
    xor esi, esi ;index displacement 
    xor bl, bl ;flag to check if non binary is inputted
    xor bh, bh ;flag for more than 12 input
    xor dh, dh ;flag for error occurred
    
loop1:
    GET_CHAR cl
    inc byte[counter]
    cmp cl, 0 ;check if null character
    je endloop1 ;end loop if null character encountered
    cmp cl, 10 ;check if line feed
    je endloop1 ;end loop if line feed encountered
    cmp cl, 12 ;check if form feed
    je endloop1 ;end loop if form feed encountered
    
    sub cl, '0'
    cmp cl, 1
    ja setnonbin
returnnonbin:
    
    cmp byte[counter], 12
    jg setexceedflag
returnexceed:
    cmp bh, 1
    je loop1
    
    add cl, '0'
    mov [input+esi], cl
    inc esi
    jmp loop1 ;next iteration
   
setexceedflag:
    mov bh, 1
    jmp returnexceed
    
setnonbin:
    mov bl, 1
    jmp returnnonbin
    
endloop1: ;end of loop
    cmp bl, 1 ;if nonhex input flag is set
    je print_nonbinmsg
    jmp skip1 ;else skip print
    
print_nonbinmsg:
    mov dh, 1
    PRINT_STRING nonbinmsg
    
skip1:
    cmp byte[counter], 13 ;if input length is not 12 + \0
    jne print_non12bitmsg
    jmp skip2 ;else skip print
    
print_non12bitmsg:
    mov dh, 1
    PRINT_STRING non12bitmsg
    
skip2:
    cmp dh, 1 ;if error occurred, go to reset
    je resetprompt
    
    mov esi, 1 ;check for pos of 1
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
    mov ah, -7
    
skip3: 
    mov [segmentno], bl ;store segment number
    mov bl, [segmentno]
    sub bl, ah ; bl gets pos
    mov [pos], bl ;store position of first 1
                  ;if segment is 0, pos of 1 is the same as the pos of the 1 in segment 1
    
    ;get sign bit
    mov al, [input]
    mov [output], al
    
    ;get next 3 bits for segment pos
    ;4 2 1 -> X Y Z
    mov dl, [segmentno]
    mov dh, 2
    mov ax, 4
    mov ebx, 1
    mov ecx, 3
loop3:
    cmp ecx, 0
    jz endloop3
    cmp dl, al
    jge set1
    mov byte[output+ebx], '0'
    jmp skip4
set1:
    mov byte[output+ebx], '1'
    sub dl, al
skip4:
    idiv dh
    inc ebx
    dec ecx
    jmp loop3

endloop3:

    ;get the next 4 higher order bits
    mov eax, 4
    xor ebx, ebx ;reset value of ebx
    mov bl, [pos]
    inc ebx ;+1 from pos of 1
    mov ecx, 4

loop4:
    jecxz endloop4
    mov dl, [input+ebx]
    mov [output+eax], dl
    inc eax
    inc ebx
    
    loop loop4
endloop4:
    PRINT_STRING "Compressed code: "
    PRINT_STRING output
    NEWLINE
    PRINT_STRING "Segment number: "
    PRINT_DEC 1, [segmentno]
    NEWLINE
resetprompt:
    PRINT_STRING "Do you want to continue (Y/N)?"
    GET_CHAR al
    GET_CHAR ah ;get \n input from CLI
    cmp al, 'Y'
    je reset
    jmp end
reset:
    ;reset all memory for next input
    mov ecx, 13
    mov eax, 0
loop5:
    jecxz endloop5
    mov byte[input + eax], 0
    inc eax
    loop loop5
    
endloop5:    
    mov ecx, 8
    mov eax, 0
loop6:
    jecxz endloop6
    mov byte[output + eax], 0
    loop loop6
endloop6:
    mov byte[segmentno], 0
    mov byte[counter], 0
    mov byte[pos], 0
    NEWLINE
    NEWLINE
    jmp main
    
end:
    xor eax, eax
    ret