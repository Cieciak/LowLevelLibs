%ifdef DISKIO_LIB
%else
%define DISKIO_LIB
jmp DiskIOExit

;; void(AL, ES:BX, CX, DX)
;; AL    - Amount of sectors to read
;; ES:BX - Pointer to target buffer
;; CH    - Track number
;; CL    - Sector number (Starting at 1)
;; DH    - Head number
;; DL    - Drive number (0x00 - 0x7F -> Floppy, 0x80 - 0xFF -> HDD)
readDiskSectors:
    mov ah, 0x02 ;; Set BIOS command to DiskRead
    int 0x13     ;; Call BIOS interrupt
    ret

DiskIO_LBAExtChcek:
    pusha
        mov ah, 0x41
        mov bx, 0x55AA
        mov dl, 0x80
        int 0x13
    popa
    ret
    
DiskIOExit:
%endif