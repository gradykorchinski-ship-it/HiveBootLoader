; ============================================================================
; HIVE BOOTLOADER v3.0 - Stage 2 (Main Boot Manager)
; ============================================================================
; Full-featured bootloader with OS detection, menu, and chainloading
; ============================================================================

[org 0x8000]
[bits 16]

; Colors
BLACK equ 0x00
BLUE equ 0x01
GREEN equ 0x02
CYAN equ 0x03
RED equ 0x04
MAGENTA equ 0x05
BROWN equ 0x06
LGRAY equ 0x07
DGRAY equ 0x08
LBLUE equ 0x09
LGREEN equ 0x0A
LCYAN equ 0x0B
LRED equ 0x0C
LMAGENTA equ 0x0D
YELLOW equ 0x0E
WHITE equ 0x0F

HDR_CLR equ (BLUE<<4)|WHITE
SEL_CLR equ (WHITE<<4)|BLACK
NRM_CLR equ (BLACK<<4)|LGRAY
BDR_CLR equ (BLACK<<4)|CYAN
FTR_CLR equ (BLACK<<4)|DGRAY
HLP_CLR equ (DGRAY<<4)|WHITE

KEY_UP equ 0x48
KEY_DOWN equ 0x50
KEY_ENTER equ 0x0D

entry:
    mov [boot_drive], dl
    mov [ptable_ptr], si
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ax, 0x0003
    int 0x10
    mov ah, 0x01
    mov ch, 0x20
    int 0x10
    call detect_mem
    call detect_cpu
    call scan_parts
    mov byte [selected], 0
    call count_items
    call draw_ui

main_loop:
    xor ax, ax
    int 0x16
    cmp ah, KEY_UP
    je .up
    cmp ah, KEY_DOWN
    je .down
    cmp al, KEY_ENTER
    je .enter
    cmp al, 'r'
    je do_reboot
    cmp al, 'R'
    je do_reboot
    cmp al, '1'
    jb main_loop
    cmp al, '9'
    ja main_loop
    sub al, '1'
    cmp al, [menu_cnt]
    jae main_loop
    mov [selected], al
    call draw_menu
    jmp .enter
    jmp main_loop
.up:
    mov al, [selected]
    test al, al
    jz .wup
    dec al
    jmp .upd
.wup:
    mov al, [menu_cnt]
    dec al
.upd:
    mov [selected], al
    call draw_menu
    jmp main_loop
.down:
    mov al, [selected]
    inc al
    cmp al, [menu_cnt]
    jb .upd
    xor al, al
    jmp .upd
.enter:
    call exec_sel
    jmp main_loop

exec_sel:
    mov al, [selected]
    mov bl, [num_parts]
    cmp al, bl
    jae .builtin
    call boot_part
    ret
.builtin:
    sub al, bl
    cmp al, 0
    je show_info
    cmp al, 1
    je do_reboot
    cmp al, 2
    je do_shutdown
    ret

boot_part:
    pusha
    mov al, [selected]
    mov bl, 16
    mul bl
    mov si, parts
    add si, ax
    mov al, [si+4]
    test al, al
    jz .inv
    call clr_scr
    mov dh, 10
    mov dl, 30
    call setcur
    mov si, msg_boot
    mov bl, LGREEN
    call prcol
    mov eax, [si+8]
    mov [dap_lba], eax
    mov word [dap_cnt], 1
    mov word [dap_off], 0x7C00
    mov word [dap_seg], 0
    mov si, dap
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13
    jc .rerr
    cmp word [0x7DFE], 0xAA55
    jne .nbt
    mov dl, [boot_drive]
    jmp 0x0000:0x7C00
.inv:
    mov si, msg_inv
    jmp .err
.rerr:
    mov si, msg_rerr
    jmp .err
.nbt:
    mov si, msg_nbt
.err:
    call clr_scr
    mov dh, 12
    mov dl, 25
    call setcur
    mov bl, LRED
    call prcol
    mov dh, 14
    mov dl, 25
    call setcur
    mov si, msg_key
    mov bl, DGRAY
    call prcol
    xor ax, ax
    int 0x16
    popa
    call draw_ui
    ret

show_info:
    call clr_scr
    mov dh, 2
    mov dl, 30
    call setcur
    mov si, title_info
    mov bl, LCYAN
    call prcol
    mov dh, 5
    mov dl, 10
    call setcur
    mov si, lbl_cpu
    mov bl, WHITE
    call prcol
    mov si, cpu_name
    call prcol
    mov dh, 7
    mov dl, 10
    call setcur
    mov si, lbl_mem
    call prcol
    mov ax, [low_mem]
    call prdec
    mov si, kb_str
    call prcol
    mov si, comma_str
    call prcol
    mov ax, [ext_mem]
    call prdec
    mov si, kb_str
    call prcol
    mov dh, 9
    mov dl, 10
    call setcur
    mov si, lbl_drv
    call prcol
    mov al, [boot_drive]
    call prhex
    mov dh, 11
    mov dl, 10
    call setcur
    mov si, lbl_parts
    call prcol
    mov al, [num_parts]
    add al, '0'
    mov bl, WHITE
    call prchar
    mov dh, 20
    mov dl, 10
    call setcur
    mov si, msg_key
    mov bl, DGRAY
    call prcol
    xor ax, ax
    int 0x16
    call draw_ui
    ret

do_reboot:
    call clr_scr
    mov dh, 12
    mov dl, 32
    call setcur
    mov si, msg_reboot
    mov bl, YELLOW
    call prcol
    mov cx, 0x000F
    mov dx, 0x4240
    mov ah, 0x86
    int 0x15
    mov al, 0xFE
    out 0x64, al
    int 0x19
    cli
    hlt

do_shutdown:
    call clr_scr
    mov dh, 12
    mov dl, 30
    call setcur
    mov si, msg_halt
    mov bl, LRED
    call prcol
    mov ax, 0x5301
    xor bx, bx
    int 0x15
    mov ax, 0x530E
    xor bx, bx
    mov cx, 0x0102
    int 0x15
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    cli
    hlt

detect_mem:
    int 0x12
    mov [low_mem], ax
    mov ah, 0x88
    int 0x15
    jc .noext
    mov [ext_mem], ax
    ret
.noext:
    mov word [ext_mem], 0
    ret

detect_cpu:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 0x200000
    push eax
    popfd
    pushfd
    pop eax
    xor eax, ecx
    jz .nocpuid
    xor eax, eax
    cpuid
    mov [cpu_name], ebx
    mov [cpu_name+4], edx
    mov [cpu_name+8], ecx
    mov byte [cpu_name+12], 0
    ret
.nocpuid:
    mov si, unk_cpu
    mov di, cpu_name
    mov cx, 12
    rep movsb
    ret

scan_parts:
    pusha
    mov byte [num_parts], 0
    mov si, [ptable_ptr]
    test si, si
    jz .done
    mov di, parts
    mov cx, 4
    mov byte [pcnt], 0
.lp:
    push cx
    push si
    mov al, [si+4]
    test al, al
    jz .nx
    mov cx, 16
    rep movsb
    sub si, 16
    inc byte [num_parts]
.nx:
    pop si
    add si, 16
    pop cx
    loop .lp
.done:
    popa
    ret

count_items:
    mov al, [num_parts]
    add al, 3
    mov [menu_cnt], al
    ret

get_pname:
    cmp al, 0x01
    je .f12
    cmp al, 0x04
    je .f16
    cmp al, 0x06
    je .f16
    cmp al, 0x07
    je .ntfs
    cmp al, 0x0B
    je .f32
    cmp al, 0x0C
    je .f32
    cmp al, 0x83
    je .lnx
    cmp al, 0x82
    je .swp
    cmp al, 0xEF
    je .efi
    jmp .unk
.f12:
    mov si, pn_f12
    ret
.f16:
    mov si, pn_f16
    ret
.f32:
    mov si, pn_f32
    ret
.ntfs:
    mov si, pn_ntfs
    ret
.lnx:
    mov si, pn_lnx
    ret
.swp:
    mov si, pn_swp
    ret
.efi:
    mov si, pn_efi
    ret
.unk:
    mov si, pn_unk
    ret

draw_ui:
    call clr_scr
    call draw_hdr
    call draw_box
    call draw_menu
    call draw_ftr
    call draw_hlp
    ret

clr_scr:
    pusha
    mov ax, 0x0600
    mov bh, BLACK
    xor cx, cx
    mov dx, 0x184F
    int 0x10
    popa
    ret

draw_hdr:
    pusha
    mov dh, 0
    xor dl, dl
    mov cx, 80
    mov bl, HDR_CLR
.h1:
    call setcur
    mov al, ' '
    call prattr
    inc dl
    loop .h1
    mov dh, 0
    mov dl, 30
    call setcur
    mov si, title
    mov bl, HDR_CLR
    call prcol
    popa
    ret

draw_box:
    pusha
    mov dh, 4
    mov dl, 8
    call setcur
    mov al, 0xC9
    mov bl, BDR_CLR
    call prattr
    mov cx, 62
.tp:
    inc dl
    call setcur
    mov al, 0xCD
    call prattr
    loop .tp
    inc dl
    call setcur
    mov al, 0xBB
    call prattr
    mov cx, 14
    mov dh, 5
.sd:
    mov dl, 8
    call setcur
    mov al, 0xBA
    call prattr
    mov dl, 71
    call setcur
    mov al, 0xBA
    call prattr
    inc dh
    loop .sd
    mov dh, 19
    mov dl, 8
    call setcur
    mov al, 0xC8
    call prattr
    mov cx, 62
.bt:
    inc dl
    call setcur
    mov al, 0xCD
    call prattr
    loop .bt
    inc dl
    call setcur
    mov al, 0xBC
    call prattr
    popa
    ret

draw_menu:
    pusha
    mov dh, 5
    mov dl, 10
    call setcur
    mov si, menu_ttl
    mov bl, LCYAN
    call prcol
    mov byte [pcnt], 0
    mov dh, 7
.lp:
    mov al, [pcnt]
    cmp al, [menu_cnt]
    jae .dn
    mov dl, 10
    call setcur
    mov al, [pcnt]
    cmp al, [selected]
    jne .nrm
    push dx
    mov cx, 58
    mov bl, SEL_CLR
.hl:
    mov al, ' '
    call prattr
    inc dl
    call setcur
    loop .hl
    pop dx
    call setcur
    mov bl, SEL_CLR
    jmp .txt
.nrm:
    mov bl, NRM_CLR
.txt:
    mov al, [pcnt]
    call get_mtxt
    call prcol
    inc dh
    inc byte [pcnt]
    jmp .lp
.dn:
    popa
    ret

get_mtxt:
    push bx
    mov bl, [num_parts]
    cmp al, bl
    jae .bi
    push ax
    mov si, mbuf
    mov di, si
    push si
    mov si, pfx_boot
.cp1:
    lodsb
    test al, al
    jz .d1
    stosb
    jmp .cp1
.d1:
    pop si
    pop ax
    push ax
    mov bl, 16
    mul bl
    push si
    mov si, parts
    add si, ax
    mov al, [si+4]
    pop si
    push si
    call get_pname
.cp2:
    lodsb
    test al, al
    jz .d2
    stosb
    jmp .cp2
.d2:
    pop si
    mov byte [di], 0
    pop ax
    pop bx
    mov si, mbuf
    ret
.bi:
    sub al, bl
    xor ah, ah
    shl ax, 1
    mov bx, ax
    mov si, [bitems+bx]
    pop bx
    ret

draw_ftr:
    pusha
    mov dh, 20
    xor dl, dl
    mov cx, 80
    mov bl, FTR_CLR
.lp:
    call setcur
    mov al, 0xC4
    call prattr
    inc dl
    loop .lp
    mov dh, 21
    mov dl, 2
    call setcur
    mov si, ftr_txt
    mov bl, FTR_CLR
    call prcol
    popa
    ret

draw_hlp:
    pusha
    mov dh, 24
    xor dl, dl
    mov cx, 80
    mov bl, HLP_CLR
.lp:
    call setcur
    mov al, ' '
    call prattr
    inc dl
    loop .lp
    mov dh, 24
    mov dl, 2
    call setcur
    mov si, hlp_txt
    mov bl, HLP_CLR
    call prcol
    popa
    ret

setcur:
    pusha
    mov ah, 0x02
    xor bh, bh
    int 0x10
    popa
    ret

prattr:
    pusha
    mov ah, 0x09
    xor bh, bh
    mov cx, 1
    int 0x10
    popa
    ret

prchar:
    pusha
    mov ah, 0x09
    xor bh, bh
    mov cx, 1
    int 0x10
    mov ah, 0x03
    int 0x10
    inc dl
    mov ah, 0x02
    int 0x10
    popa
    ret

prcol:
    pusha
.lp:
    lodsb
    test al, al
    jz .dn
    call prchar
    jmp .lp
.dn:
    popa
    ret

prdec:
    pusha
    xor cx, cx
    mov bx, 10
.dv:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .dv
.pr:
    pop dx
    add dl, '0'
    mov al, dl
    mov bl, WHITE
    call prchar
    loop .pr
    popa
    ret

prhex:
    pusha
    push ax
    shr al, 4
    call .dig
    pop ax
    and al, 0x0F
    call .dig
    popa
    ret
.dig:
    cmp al, 10
    jb .dec
    add al, 'A'-10
    jmp .out
.dec:
    add al, '0'
.out:
    mov bl, WHITE
    call prchar
    ret

boot_drive: db 0
ptable_ptr: dw 0
selected: db 0
menu_cnt: db 0
num_parts: db 0
pcnt: db 0
low_mem: dw 0
ext_mem: dw 0
cpu_name: times 13 db 0
unk_cpu: db "Unknown CPU",0

align 2
dap:
db 0x10,0
dap_cnt: dw 0
dap_off: dw 0
dap_seg: dw 0
dap_lba: dq 0

parts: times 64 db 0

title: db "HIVE BOOTLOADER v3.0",0
menu_ttl: db "Select OS:",0
bitems:
dw item_info
dw item_reboot
dw item_halt
item_info: db "System Information",0
item_reboot: db "Reboot",0
item_halt: db "Shutdown",0
pfx_boot: db "Boot: ",0
mbuf: times 64 db 0
pn_f12: db "FAT12",0
pn_f16: db "FAT16",0
pn_f32: db "Windows/FAT32",0
pn_ntfs: db "Windows/NTFS",0
pn_lnx: db "Linux",0
pn_swp: db "Linux Swap",0
pn_efi: db "EFI",0
pn_unk: db "Unknown",0
ftr_txt: db "HIVE Bootloader (c) 2024-2026 | GPL-3.0 License",0
hlp_txt: db 24,25," Select | Enter Boot | 1-9 Quick | r Reboot",0
msg_boot: db "Booting...",0
msg_inv: db "Invalid partition",0
msg_rerr: db "Read error",0
msg_nbt: db "Not bootable",0
msg_key: db "Press any key",0
title_info: db "System Info",0
lbl_cpu: db "CPU: ",0
lbl_mem: db "Memory: ",0
lbl_drv: db "Drive: 0x",0
lbl_parts: db "Partitions: ",0
kb_str: db " KB",0
comma_str: db ", ",0
msg_reboot: db "Rebooting...",0
msg_halt: db "Shutting down...",0

times 65536-($-$$) db 0
