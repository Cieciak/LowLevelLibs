%ifdef STRING_LIB
%else
%define STRING_LIB
jmp StringLibExit

;; AX(DS:SI, ES:DI)
stringCompare: ;; AX(DS:SI, ES:DI)
    push ds
    push si
    push es
    push di
    cld
    .loop:
        lodsb       ;; mov al, byte [ds:si]; inc si
        scasb       ;; cmp al, byte [es:di]; inc di
        jne .diff   ;; If string are different return 0
        test al, al ;; If reached null terminator return 1
        jnz .loop   ;;
    mov ax, 0x0001
    pop di
    pop es
    pop si
    pop ds
    ret
    
    .diff:
    mov ax, 0x0000
    pop di
    pop es
    pop si
    pop ds
    ret

String_FindTerminator_SRC: ; void(DS:SI)
    ;; DS:SI - String data
    ;;
    ;; This will advance DS:SI until null terminator is encoutered
    ;; Final value of DS:SI points to null teminator

    push ax
    .loop:
        lodsb       ;; mov al, byte [ds:si]; inc si
        test al, al ;; Test content of al
        jz .exit    ;; If zero exit
        jmp .loop   ;;
    .exit:
    dec si ;; Adjustment for the lodsb
    pop ax
    ret

StringLibExit:
%endif