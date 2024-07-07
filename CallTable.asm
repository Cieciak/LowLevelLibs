%ifdef CALLTABLE_LIB
%else
%define CALLTABLE_LIB
jmp CallTableExit

%include "libs/String.asm"
%include "libs/TextIO.asm"

CallTable_find: ; void(DS:SI, ES:DI) | D: ALL
    ;; DS:SI - Pointer to table
    ;; ES:DI - String to find

    ;; This will run function attached to the name
    ;; Not guarantee to save any of the registers
    ;; Every function has to be in the same segment as table

    ;; DESTROYS: All

    .loop:
        push es            ;; Compare current table entry with string
        push di            ;; This saves the pointer to input string on stack
        call stringCompare ;;
        pop di             ;;
        pop es             ;;
        call String_FindTerminator_SRC ;; Find the end of entry
        test al, al                    ;; On match execute the command
        jnz .match                     ;;
        add si, 4                      ;; Else skip JMP instruction (jmp near)
        mov al, byte [ds:si] ;; Test for end of the jump table
        test al, al          ;;
        jz .exit             ;;
        jmp .loop            ;; If there is more data, loop

    .match:
        inc si  ;; Increment SI to make it point to JMP instruction
        call si ;; Call te instruction, and hope it uses RET

    .exit:
    ret

CallTableExit:
%endif