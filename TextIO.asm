%ifdef TEXTIO_LIB
%else
%define TEXTIO_LIB
jmp TextIOExit
TextIO_PRIMM: ; void() | D: AX, SI
    ;; This is stolen idea from http://6502.org/source/io/primm.htm
    ;; I just changed it to work on x86
    ;; Let's you print string like this
    ;; call PRIM
    ;; db "Message here", 0x00
    
    ;; CALL pushes a trace onto the stack
    ;;
    ;; |------------|
    ;; | SEG OFFSET | <-- Top
    ;; |------------|
    ;; |  CODE SEG  |
    ;; |------------|
    ;; |............|
    ;; |............|
    ;; 
    ;; The trace point to next instruction, or at least it points where it
    ;; should be. In this case it's the first byte of null terminated string.
    ;; Then using special adressing mode we access the data.
    ;; 
    ;; Destroys: AX, SI

    pop si       ;; Get the segment offset into source register
    mov ah, 0x0e ;; Set BIOS command to Write

    .loop:                ;; Printing string to display
        mov al, [cs:si]   ;; Load byte from pointer
        cmp al, byte 0x00 ;; 
        jz .exit          ;; If zero exit 
        int 0x10          ;; 
        inc si            ;; Increment pointer
        jmp .loop         ;; 
    .exit:

    inc si  ;; Adjust pointer
    push si ;; Patch trace to point to actual next instruction
    ret

TextIO_printString: ; void(DS:SI) | D: DS:SI
    ;; DS:SI - String to print

    ;; Will print null terminated string at DS:SI

    ;; Destroys: DS:SI
    
    push ax
    mov ah, 0x0e
    .loop:
        mov al, [ds:si]   ;; Load character
        cmp al, byte 0x00 ;; If terminator exit
        jz .exit          ;;
        int 0x10          ;; Call BIOS interrupt
        inc si            ;; Increment pointer
        jmp .loop         ;; Loop
    .exit:
    pop ax
    ret

TextIO_printNewLine: ; void()
    ;; Will print new line

    push ax
    mov ax, 0x0e0d ;; Print CR
    int 0x10       ;; 
    mov ax, 0x0e0a ;; Print NL
    int 0x10       ;;
    pop ax
    ret

TextIO_printInt: ; void(AX, BX)
    ;; AX - Number to print
    ;; BX - Base

    ;; Will print number stored in AX using base given in BX

    pusha
    xor dx, dx   ;; Clear DX

    mov cx, 0x37 ;; This is an offset into character block 
    mov di, cx   ;; It's stored for use later

    push bx        ;; This will be used as flag to signal end of digits
    .loop:
        div bx              ;; Divide by base
        push dx             ;; Send digit onto the stack
        xor dx, dx          ;; Clear digit
        cmp ax, word 0x0000
        jz .print
        jmp .loop

    .print:
        pop ax     ;; Get digit
        cmp ax, bx ;; Check for flag
        je .exit
        
        mov cx, 0x30      ;; Offset to digits block
        cmp al, byte 0x09 ;; Outside 0 - 9 range
        cmova cx, di      ;; Move offset stored previously
        add ax, cx        ;; Add the correct offset
        
        mov ah, 0x0e ;; BIOS call
        int 0x10     ;;
        jmp .print

    .exit:
    popa
    ret

TextIO_printPointer: ; void(ES:BX, CX) | D: ES:BX, CX
    ;; ES:BX - Data pointer
    ;; CX    - Number of bytes to print

    ;; Will print bytes stored at pointer as text

    push ax
    mov ah, 0x0e ;; BIOS command
    .loop:
        mov al, byte [es:bx] ;; Loop over bytes and print them
        int 0x10             ;;
        dec cx               ;;
        jz .exit             ;;
        inc bx               ;;
        jmp .loop            ;;
    .exit:
    pop ax
    ret


TextIO_readString: ; void(ES:DI)
    ;; ES:DI - Pointer to store

    ;; Reads keyboard and stores at ES:DI
    ;; Technically returns at ES:DI
    ;; It does not modify the pointer

    push es
    push di
    .loop:
        mov ah, 0x00 ;; Get ASCII code
        int 0x16     ;;
        cmp al, 0x0d ;; Compare with Carriage Return code
        je .exit     ;;
        stosb        ;; Store string
        mov ah, 0x0e ;; Print character
        int 0x10     ;;
        jmp .loop
    .exit:
    xor al, al             ;; Add string terminator
    mov [es:di], byte 0x00 ;;
    pop di
    pop es
    ret

TextIO_readInt: ; AX(BX) | R: AX
    ;; BX - Base of the number to read
    
    ;; Reads int16 from the user

    ;; Returns: AX

    push bx
    push cx
    mov ax, 0x0000 ;; Clear GP registers
    mov cx, 0x0000 ;;

    .loop:
        push ax      ;; Get ASCII code
        mov ah, 0x00 ;;
        int 0x16     ;;
        mov cl, al   ;; 
        pop ax       ;;

        cmp cl, 0x0d ;; Exit on Carriage Return
        je .exit     ;;

        push ax      ;; Print character
        mov ah, 0x0e ;;
        mov al, cl   ;;
        int 0x10     ;;
        pop ax       ;;

        sub cl, 0x30 ;; Adjust digit
        cmp cl, 0x09 ;; Test if digit it bigger than 9
        jna .adjust  ;; Adjust char
        sub cl, 0x7  ;;
        .adjust:     ;;

        mul bx       ;; Multiply by base
        add ax, cx   ;; Add digit
        jmp .loop
    .exit:
    pop cx
    pop bx
    ret

TextIO_printAddress: ;; void(DS:SI)
    ;; DS:SI - Address to print

    ;; Will print value of DS:SI in hex using xxxx:xxxx format
    
    pusha
    mov bx, 0x10         ;; Use hexadecimal base
    mov ax, ds           ;; Print segment register
    call TextIO_printInt ;;
    mov al, byte ":"     ;; Print ":" separator
    mov ah, 0x0e         ;;
    int 0x10             ;;
    mov ax, si           ;; Print offset register
    call TextIO_printInt ;;
    popa
    ret

TextIO_printByte: ; void(AL)
    ;; AL - Byte to print

    ;; Will print byte value in hex

    push bx
    push ax

    cmp al, byte 0x0f
    ja .skipZero

    mov bx, ax
    mov ah, 0x0e
    mov al, byte "0"
    int 0x10
    mov ax, bx

    .skipZero:
    and ah, 0x00
    mov bx, 16
    call TextIO_printInt
    pop ax
    pop bx
    ret

TextIO_printSegment: ; void(ES:BX, CX)
    ;; ES:BX - Pointer to data
    ;; CX    - Number of bytes to print

    push dx
    .loop:
        mov al, byte [es:bx]
        inc bx
        call TextIO_printByte
        inc dx
        dec cx
        jz .exit

        mov ah, 0x0e
        mov al, byte " "
        int 0x10

        cmp dx, 0x10
        jne .loop
        call TextIO_printNewLine
        xor dx, dx
        jmp .loop

    .exit:
    pop dx
    ret


TextIOExit:
%endif