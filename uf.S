.intel_syntax noprefix

.extern malloc
.extern free
.extern getint
.extern putint

.global unionfind

.section .rodata
.align 16

.section .text
/**
 *
 * -------------------------
 * FUNCTION ARGUMENTS GUIDE:
 * -------------------------
 * rdi: uint64_t set_size
 * rsi: char* instruction_string
 * rdx: char* solution_string
 *
 * ----------------
 * CONSTANTS GUIDE:
 * ----------------
 * ASCII F: 0x46
 * ASCII U: 0x55
 * ASCII L: 0x4C
 * ASCII &: 0x26
 *
 */
unionfind:
    // setup base pointer
    push rbp
    mov rbp, rsp

    // preserve registers
    push rbx
    push r13
    push r14
    push r15

    // dynamically allocate memory for data structure.
    // `rsi` and `rdx` may be affected during malloc and are thus preserved
    // and then released after the memory allocation.
    push rsi
    push rdx
    mov rbx, rdi // rbx: `set_size`
    shl rdi, 0x2 // both data structure, n ∈ [0, 65535] require 2 bytes for representation
    call malloc // reserve memory for data structures
    mov r14, rax // r14: pointer to group G_i
    mov r15, rbx
    shl r15, 0x1
    add r15, r14 // r15: pointer to group size |G_i|
    pop rdx
    pop rsi

    // initialize data structure values
    .LDSinit:
        dec rbx
        mov word ptr [r14 + rbx * 2], bx
        mov word ptr [r15 + rbx * 2], 0x1
        test rbx, rbx
        jnz .LDSinit

    // parse command to function
    .Lparse_cmd:
        cmp byte ptr [rsi], 0x46
        je .Lfind
        cmp byte ptr [rsi], 0x55
        je .Lunion
        jmp .Lfinish

    // find
    .Lfind:
        // write 'F' to `solution_string`
        mov word ptr [rdx], 0x46 // 'F'
        inc rdx

        // load parameters
        push rdx // pointer to next `solution_string` char
        sub rsp, 0x8
        lea rdi, [rsi + 1]
        call getint
        // rdi: pointer to next `insruction_string` char
        // rax: data point D_i
        add rsp, 0x8
        pop rdx

        // find group
        push rdi // pointer to next `insruction_string` char
        push rdx // pointer to next `solution_string` char
        mov rdi, rax
        call find
        // rax: group G_i
        // rdx: D_i traversed levels

        // write solution
        mov rdi, rax
        mov rsi, rdx
        pop rdx
        sub rsp, 0x8
        call write_solution
        add rsp, 0x8
        mov rdx, rax // rdx: pointer to next `solution_string` char
        pop rsi // pointer to next `instruction_string` char

        jmp .Lparse_cmd

    // union
    .Lunion:
        // write 'U' to `solution_string`
        mov word ptr [rdx], 0x55 // 'U'
        inc rdx

        // load first data point D_i parameters
        push rdx // pointer to next `solution_string` char
        sub rsp, 0x8
        lea rdi, [rsi + 1]
        call getint
        mov rbx, rax // rbx: first data point D_i

        inc rdi // skip '&'

        // load second data point D_j parameters
        call getint // rax: second data point D_j
        add rsp, 0x8
        pop rdx

        // find group of data points
        push rdi // pointer to next `instruction_string` char
        push rdx // pointer to next `solution_string` char

        // find group G_j of D_j
        mov rdi, rax
        call find
        push rdx // rdx: traversed levels for D_j
        push rax // rax: group G_j of D_j

        // find group G_i of D_i
        mov rdi, rbx
        call find
        // rax: group G_i of D_i
        // rdi: traversed levels for D_i

        pop r9 // r9: group G_j of D_i
        pop r8 // r8: traversed level for D_j

        // determine parent and child group
        mov r10w, word ptr [r15 + rax * 2] // G_i group size |G_i|
        mov r11w, word ptr [r15 + r9 * 2] // G_j group size |G_j|
        cmp r10w, r11w
        jge .Lunite_groups
        // swap parameters ...
        .Lunite_groups:
        mov word ptr [r14 + r9 * 2], ax // set D_j group to G_i
        add word ptr [r15 + rax * 2], r11w // increase group size of G_i
        mov word ptr [r15 + r9 * 2], 0x0 // empty group size calculations for G_j

        // write solution
        mov rdi, rax
        mov rsi, rdi
        pop rdx
        sub rsp, 0x8
        call write_solution
        mov rdx, rax
        add rsp, 0x8
        pop rsi
        jmp .Lparse_cmd

    // cleanup program
    .Lfinish:
        // free dynamically allocated memory
        mov rdi, r14
        call free
        // release preserved registers
        pop r15
        pop r14
        pop r13
        pop rbx
        // reset base pointer
        pop rbp

    // exit program 
    ret
    // :) DONE!

/**
 * ARGUMENTS GUIDE:
 * ----------------
 * r14: G_i data structure
 * r15: |G_i| data structure
 * rdi: data point D_i to be found
 *
 * !!!NOTE!!!:
 * -----------
 * `r14` and `r15` are register constants used in this program and are
 * hereby excluded from the calling convention palava
 *
 * OUTPUT:
 * -------
 * rax: group G_i of data point D_i
 * rdx: traversed levels
 */
find:
    push rbp

    xor rax, rax
    xor rdx, rdx

    mov ax, word ptr [r14 + rdi * 2] // rax: D_i's tentative group G_i
    test ax, di
    jz .Lfind_end
    // group not found ...

    .Lfind_end:
    pop rbp
    ret

/**
 * INPUT:
 * ------
 * rdi: group G_i
 * rsi: traversed levels
 * rdx: pointer to next `solution_string` char
 *
 * OUTPUT:
 * -------
 * rax: pointer to next `solution_string` char
 */
write_solution:
    push rbp

    // write group G_i to `solution_string`
    push rsi
    sub rsp, 0x8
    mov rsi, rdx
    call putint
    mov rdx, rax // rdx: pointer to next `solution_string` char
    add rsp, 0x8
    pop rsi

    // write traversed levels to `solution_string`
    mov word ptr [rdx], 0x4c // write 'L'
    inc rdx
    mov rdi, rsi
    mov rsi, rdx
    call putint

    pop rbp
    ret

