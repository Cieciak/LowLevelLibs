%ifdef PROCESS_LIB
%else
%define PROCESS_LIB_LIB
jmp ProcessLibExit


Process_getIP: ; ES:BX()
    ;; Will return pointer of next instruction in ES:BX
    
    pop bx
    pop es
    push es
    push bx
    ret

Process_getNearIP: ; ES:BX()
    ;; "Near" version of Process_getIP

    push cs
    pop es
    pop bx
    push bx
    ret

ProcessLibExit:
%endif