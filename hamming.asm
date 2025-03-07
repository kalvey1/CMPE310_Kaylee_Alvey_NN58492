section .data
    newline db 0xA  ; Newline character for output formatting

    msg1 db 'The hamming distance is ', 0x0A    ;setting up to display distance
    len1 equ $-msg1

    msg2 db 'Enter a string ', 0x0A     ;prompting for first string
    len2 equ $-msg2

section .bss
    distance resb 10  ; Reserve space for up to 10 bytes (Hamming distance)
    string1 resb 32
    string2 resb 32

section .text
    global _start

_start:

    ;ask for first string
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2 
    mov edx, len2
    int 0x80

    ;read in first string
    mov eax, 3
    mov ebx, 0
    mov ecx, string1
    mov edx, 100
    int 0x80

    ;ask for second string
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2 
    mov edx, len2
    int 0x80

    ;read in second string
    mov eax, 3
    mov ebx, 0
    mov ecx, string2
    mov edx, 100
    int 0x80


    mov ecx, 0 ; i of loop
    mov edx, 0 ;counter that goes up



.loop:
    
    ; Load two 32-bit numbers into registers (binary values)
    mov al, byte[string1+ecx]  ; Binary number 1
    mov bl, byte[string2+ecx]  ; Binary number 2
    
    cmp al, 0
    je .exit
    cmp bl, 0
    je .exit

    inc ecx
    
    ; XOR the two numbers to compare bits (find differing bits)
    xor al, bl     ; EAX = EAX XOR EBX
    jmp .count_ones
    ; Count the number of 1's in EAX (Hamming distance)
;    mov ecx, 0       ; Initialize counter for Hamming distance

.count_ones:
    test al, 1      ; Test the least significant bit of EAX
    jz .no_bit       ; If it's 0, skip to the next bit
    inc edx          ; Increment the counter (bit is 1)

.no_bit:
    shr al, 1       ; Shift EAX right to check the next bit
    jnz .count_ones  ; Repeat until all bits are checked
    jmp .loop
    ; Now ECX contains the Hamming distance (number of differing bits)

    ; Let's print the Hamming distance as a number (directly in integer form)
.exit:
    ; Move Hamming distance into EAX to convert to string
    mov eax, edx         ; Move the distance of the Hamming distance into eax
    mov ebx, distance    ; Point EBX to the distance buffer
    add ebx, 10          ; Move to the end of the buffer (to fill from right)
    mov byte [ebx], 0    ; Null-terminate the buffer
    dec ebx              ; Point to the last character

; 00100000 
; 01100011

.convert_to_ascii:
    xor edx, edx             ; Clear remainder
    mov ecx, 10              ; Set divisor to 10
    div ecx                  ; EAX = EAX / 10, remainder in EDX
    add dl, '0'              ; Convert remainder to ASCII ('0' = 48)
    mov [ebx], dl            ; Store the digit in the buffer
    dec ebx                  ; Move to next character position
    test eax, eax            ; Check if quotient is zero
    jnz .convert_to_ascii    ; If not zero, continue conversion

    ; Print msg1
    mov eax, 4              ; Syscall number for sys_write (4)
    mov ebx, 1              ; File descriptor (1 = STDOUT)
    lea ecx, msg1       ; Address of the distance buffer
    mov edx, len1             ; Length of the distance (up to 10 characters)
    int 0x80                ; Make the syscall to print

    ; Print the distance (Hamming distance) as string
    mov eax, 4              ; Syscall number for sys_write (4)
    mov ebx, 1              ; File descriptor (1 = STDOUT)
    lea ecx, [distance]       ; Address of the distance buffer
    mov edx, 10             ; Length of the distance (up to 10 characters)
    int 0x80                ; Make the syscall to print

    ; Print a newline character
    mov eax, 4              ; Syscall number for sys_write (4)
    mov ebx, 1              ; File descriptor (1 = STDOUT)
    lea ecx, [newline]      ; Address of the newline character
    mov edx, 1              ; Print 1 byte (newline)
    int 0x80                ; Make the syscall to print newline

    ; Exit the program
    mov eax, 1              ; Syscall number for sys_exit (1)
    xor ebx, ebx            ; Return code 0
    int 0x80                ; Make the syscall to exit
