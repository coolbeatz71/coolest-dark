; =============================================================
; Bare-metal / bootloader framework tour (NASM, 16-bit real mode)
;
; Covers BIOS interrupt services, segment registers, the boot
; signature, real-mode addressing, string routines and the
; transition to 32-bit protected mode with a GDT.
; =============================================================

            BITS 16
            ORG  0x7C00                 ; BIOS loads the boot sector here

%define VIDEO_TELETYPE  0x0E
%define BIOS_VIDEO      0x10
%define BIOS_DISK       0x13
%define STACK_TOP       0x7C00

; -------------------------------------------------------------
; Entry point
; -------------------------------------------------------------
start:
            cli                          ; no interrupts while we set up
            xor     ax, ax
            mov     ds, ax
            mov     es, ax
            mov     ss, ax
            mov     sp, STACK_TOP
            sti

            mov     [boot_drive], dl     ; BIOS passes the drive in DL

            mov     si, msg_booting
            call    print_string

            call    load_kernel
            jc      disk_error

            mov     si, msg_ok
            call    print_string

            jmp     enter_protected_mode

; -------------------------------------------------------------
; print_string(ds:si = NUL-terminated string)
; Clobbers: ax, bx, si
; -------------------------------------------------------------
print_string:
            push    ax
            push    bx
            mov     ah, VIDEO_TELETYPE
            xor     bx, bx
.next:
            lodsb                        ; al <- [ds:si], si++
            test    al, al
            jz      .done
            int     BIOS_VIDEO
            jmp     .next
.done:
            pop     bx
            pop     ax
            ret

; -------------------------------------------------------------
; load_kernel() -> CF set on failure
; Reads 8 sectors from LBA 1 into 0x1000:0000
; -------------------------------------------------------------
load_kernel:
            mov     bx, 0x1000
            mov     es, bx
            xor     bx, bx

            mov     ah, 0x02             ; read sectors
            mov     al, 8                ; sector count
            mov     ch, 0                ; cylinder
            mov     cl, 2                ; sector (1-based)
            mov     dh, 0                ; head
            mov     dl, [boot_drive]
            int     BIOS_DISK
            ret

disk_error:
            mov     si, msg_disk_err
            call    print_string
.halt:
            hlt
            jmp     .halt

; -------------------------------------------------------------
; Global Descriptor Table
; -------------------------------------------------------------
gdt_start:
gdt_null:   dq 0x0000000000000000
gdt_code:   dw 0xFFFF, 0x0000
            db 0x00, 10011010b, 11001111b, 0x00
gdt_data:   dw 0xFFFF, 0x0000
            db 0x00, 10010010b, 11001111b, 0x00
gdt_end:

gdt_descriptor:
            dw gdt_end - gdt_start - 1
            dd gdt_start

CODE_SEG    equ gdt_code - gdt_start
DATA_SEG    equ gdt_data - gdt_start

enter_protected_mode:
            cli
            lgdt    [gdt_descriptor]
            mov     eax, cr0
            or      eax, 0x1             ; set the PE bit
            mov     cr0, eax
            jmp     CODE_SEG:protected_entry

            BITS 32
protected_entry:
            mov     ax, DATA_SEG
            mov     ds, ax
            mov     es, ax
            mov     ss, ax
            mov     esp, 0x90000
            jmp     0x10000              ; hand control to the kernel

; -------------------------------------------------------------
; Data
; -------------------------------------------------------------
boot_drive:   db 0
msg_booting:  db "Booting Coolest Dark...", 13, 10, 0
msg_ok:       db "Kernel loaded.", 13, 10, 0
msg_disk_err: db "Disk read failed!", 13, 10, 0

            times 510 - ($ - $$) db 0    ; pad to 510 bytes
            dw 0xAA55                    ; boot signature
