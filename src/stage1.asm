; ============================================================================
; HIVE BOOTLOADER v3.0 - Stage 1 (MBR Boot Sector)
; ============================================================================
; Copyright (c) 2024-2026 HIVE Project
; Licensed under GNU General Public License v3.0
; https://github.com/hive-bootloader/hive
; ============================================================================

[org 0x7C00]
[bits 16]

STAGE2_SEG      equ 0x0800
STAGE2_OFF      equ 0x0000
STAGE2_LIN      equ 0x8000
STAGE2_SECTS    equ 127

    jmp short start
    nop
    times 0x3E-($-$$) db 0

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    mov [drive], dl
    mov si, 0x7DBE
    mov di, ptable
    mov cx, 64
    cld
    rep movsb
    mov ah, 0x41
    mov bx, 0x55AA
    mov dl, [drive]
    int 0x13
    jc .chs
    cmp bx, 0xAA55
    jne .chs
    mov si, dap
    mov ah, 0x42
    mov dl, [drive]
    int 0x13
    jnc .ok
.chs:
    mov cx, 3
.retry:
    push cx
    mov ax, STAGE2_SEG
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, STAGE2_SECTS
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [drive]
    int 0x13
    pop cx
    jnc .ok
    xor ax, ax
    mov dl, [drive]
    int 0x13
    loop .retry
    mov si, err
    mov ah, 0x0E
.pr:
    lodsb
    test al, al
    jz .hl
    int 0x10
    jmp .pr
.hl:
    cli
    hlt
    jmp .hl
.ok:
    mov dl, [drive]
    mov si, ptable
    jmp STAGE2_SEG:STAGE2_OFF

drive:  db 0
err:    db "E",0
align 4
dap:    db 16,0
        dw STAGE2_SECTS
        dw STAGE2_OFF, STAGE2_SEG
        dq 1
ptable: times 64 db 0
times 510-($-$$) db 0
dw 0xAA55
