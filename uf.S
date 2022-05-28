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
 * ------------------------
 * FUNCTION ARGUMENT GUIDE:
 * ------------------------
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
        mov word ptr [rdx], 0x46 // write 'F' to `solution_string`
        inc rdx
        push rdx // pointer to next `solution_string` char
        sub rsp, 0x8
        // load parameters
        lea rdi, [rsi + 1]
        call getint // `rdi` safe; rax: data point D_i
        add rsp, 0x8
        pop rdx
        push rdi // pointer to next `insruction_string` char
        sub rsp, 0x8
        xor r13, r13 // r13: traversed levels
        xor rdi, rdi // reset `rdi`
        call find
        call write_solution
        add rsp, 0x8
        pop rsi
        jmp .Lparse_cmd
    
    // union
    .Lunion:
        mov word ptr [rdx], 0x55 // write 'U' to `solution_string`
        inc rdx
        push rdx // pointer to next `solution_string` char
        sub rsp, 0x8
        // load parameters
        lea rdi, [rsi + 1]
        call getint
        mov rbx, rax // rbx: first data point D_i
        inc rdi
        call getint // rax: second data point D_j
        add rsp, 0x8
        pop rdx
        push rdi
        sub rsp, 0x8
        xor r13, r13 // r13: traversed levels
        xor rdi, rdi // reset `rdi`
        call find // determine group of D_j
        mov r9, rdi // r9: group G_j of D_j
        mov r10, r13 // r10: traversed levels for D_j
        mov rax, rbx
        call find // determine group of D_i; 
        // rdi: group G_i of D_i; r13: traversed levels for D_i
        // determine parent and child group
        mov ax, word ptr [r15 + rdi * 2] // G_i group size |G_i|
        mov bx, word ptr [r15 + r9 * 2] // G_j group size |G_j|
        cmp bx, ax
        jng .Lunite_groups
        // swap parameters ...
        .Lunite_groups:
        mov word ptr [r14 + r9 * 2], di
        add word ptr [r15 + rdi * 2], bx
        mov word ptr [r15 + r9 * 2], 0x0
        call write_solution
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
 * INPUT:
 * ------
 * rax: data point D_i to be found
 * r14: G_i data structure
 * r15: |G_i| data structure
 *
 * OUTPUT:
 * -------
 * rdi: group G_i of data point D_i
 * r13: traversed levels
 */
find:
    push rbp
    mov di, word ptr [r14 + rax * 2] // rdi: D_i's tentative group G_i
    test di, ax
    jz .Lfind_end
    // group not found ...
    .Lfind_end:
    pop rbp
    ret

/**
 * INPUT:
 * ------
 * rdi: group G_i
 * rdx: next pointer to `solution_string` char
 * r13: traversed levels
 *
 * OUTPUT:
 * -------
 * rdx: next pointer to `solution_string` char
 */
write_solution:
    push rbp
    // write group G_i to `solution_string`
    mov rsi, rdx
    call putint
    mov rdx, rax
    // write traversed levels to `solution_string`
    mov word ptr [rdx], 0x4c
    inc rdx
    mov rdi, r13
    mov rsi, rdx
    call putint
    mov rdx, rax
    pop rbp
    ret

