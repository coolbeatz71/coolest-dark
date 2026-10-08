; =============================================================
; x86-64 Assembly language tour (NASM syntax, System V ABI)
;
; Covers sections, labels, directives, registers, addressing modes,
; the stack, calling conventions, macros and system calls.
; =============================================================

%define SYS_WRITE   1
%define SYS_EXIT    60
%define STDOUT      1

; Macro: write a NUL-terminated buffer of known length.
%macro write_str 2
    mov     rax, SYS_WRITE          ; syscall number
    mov     rdi, STDOUT             ; fd
    mov     rsi, %1                 ; buffer
    mov     rdx, %2                 ; length
    syscall
%endmacro

            section .rodata
msg_ok:     db  "ok", 10
msg_ok_len: equ $ - msg_ok
msg_busy:   db  "busy", 10
msg_busy_len: equ $ - msg_busy
severities: dq  1, 2, 3, 4          ; debug, info, warning, error

            section .bss
counter:    resq 1                  ; reserve one quadword

            section .text
            global  _start
            extern  printf

; -------------------------------------------------------------
; describe(rdi = count, rsi = severity_rank) -> rax = 0 ok / 1 busy
;
; Clobbers: rax, rcx
; Preserves: rbx, rbp, r12-r15 (callee-saved)
; -------------------------------------------------------------
describe:
            push    rbp
            mov     rbp, rsp
            sub     rsp, 16                 ; local frame

            test    rdi, rdi                ; count == 0 ?
            jz      .empty

            cmp     rsi, 4                  ; severity == error ?
            je      .failing

            cmp     rdi, 100
            jg      .busy

.ok:
            xor     eax, eax                ; return 0
            jmp     .done

.busy:
            mov     eax, 1
            jmp     .done

.failing:
            mov     eax, 2
            jmp     .done

.empty:
            mov     eax, 3

.done:
            mov     rsp, rbp
            pop     rbp
            ret

_start:
            ; Indexed addressing: severities[2]
            lea     rbx, [rel severities]
            mov     rcx, qword [rbx + 2*8]

            mov     rdi, 150                ; count
            mov     rsi, rcx                ; severity rank
            call    describe

            cmp     rax, 1
            jne     .print_ok

            write_str msg_busy, msg_busy_len
            jmp     .exit

.print_ok:
            write_str msg_ok, msg_ok_len

.exit:
            mov     rax, SYS_EXIT
            xor     edi, edi                ; status 0
            syscall
