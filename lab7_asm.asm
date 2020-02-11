;lab7_asm.asm
;Name: David Piatt
;Date 3/27/2017
;Class: cse 2421 m/w 4:15
;this is lab7_asm.asm, it is the translation of lab7_c.c into assemly
;export the symbol "main"
global main
;indicate that printf will be an extern that will have to be resolved at link time
extern printf
extern atoi

;the read-only data segment
section .rodata
;placing ascii val of \n (0xa) as byte after format string instead of making format string "%d\n"
format_string_1 db "(%d, %d): %d",0xa,0

;the read-write section of data
section .data
;initialize the static variablesome_stateic_int = 0
some_static_int dd 0x0
table:
dd case_0
dd case_1
dd case_2
dd case_3

;libc has already established the stack. we linked to this
section .text
;the 'main' function

main:
    ;set up stack fram
    push ebp
    mov ebp, esp
    ;set aside space for mains 4 local variables
    ;outer_limit, iner, counter1, counter 2
    sub esp, 0x10
    ;implement int outer_limit = atoi(argv[1]);
    ;set aside room for the one parameter on the stack for the first call to atoi
    sub esp, 0x4
    ;the array argv will be found in the location of the first argument placed on the stack for this function to consume
    mov ecx, [ebp+0xc]
    ;the first argument to the executable, a pointer to a character assumed to represent a legal integer, can be found 4 bytes fofset from where eax points
    ;the second argument to the executable, a pointer to a character assumed to represent a legal integer can be found 8 bytes offset from where eax points
    ;move the first argument onto the stack in preparation for calling atoi
    mov eax, [ecx+4]
    mov [esp], eax
    call atoi
    ;restore the stack to its original state
    add esp, 0x4
    ;eax has our integer value of var_x that we can now store
    mov [ebp-0x4], eax
    mov [esp-0x4], eax ;setting up esp for call to complex_function
    
    ;implement int inner_limit = atoi_argv[2]);
    sub esp, 0x4
    mov ecx, [ebp+0xc]
    mov eax, [ecx+8]
    mov [esp], eax
    call atoi
    add esp, 0x4
    mov [ebp-0x8], eax
    mov [esp-0x8], eax ;setting up esp for call to complex_function 
    ;now make for loop and nested for loop
    ;we shouldn't use registers to count since we'd like to pass this so let's add it to the stack
    mov dword [ebp-0xc], 0 ;counter1
    mov dword [ebp-0x10], 2 ;counter 2
    loop:
        push ecx
        mov ecx, [ebp-0x4]
        cmp [ebp-0xc], ecx ;compare counter1 to outer_limit
        pop ecx
            jg done
    code:
        ;this is the neted for loop
        ;already set edx to 0       
        loop2:
           push ecx
            mov ecx, [ebp-0x8]
           cmp [ebp-0x10], ecx ;compare counter 2 to inner_limit
            pop ecx
                jl done
            code_2:
            ;call complex_function 
            call complex_function
            ;the value is in eax
            mov [ebp-0x14], eax ;this is the value after complex_function 
            push ecx
            mov ecx, [ebp-0x14]
            mov [esp+0x4], ecx ;moves on the value after complex_function
            mov ecx, [ebp-0x10]
            mov [esp+0x8], ecx ;moves counter 2 
            mov ecx, [ebp-0xc]
            mov [esp+0xc], ecx  ;moves on counter 1
            pop ecx
            ;move address of format string into eax and place onto proper place on stack for second call to printf
            mov eax, format_string_1
            mov[esp], eax
            ;call print f          
            call printf
            inc edx
            jmp loop2
             
 
    inc ecx
    jmp loop
    done:
        xor eax, eax ;set eax to zero to return success to the caller of main()
        leave
        ret

complex_function:
    push ebp
    mov ebp, esp
    code2:
    ;declare int temp1
    mov eax, [ebp+0x8] ;counter 1 || arg1
    sub dword eax, 7
    mov [ebp-0x4], eax ;ebp-4 will have temp1
    ;declare int temp2
    xor eax, eax
    push ecx
    mov ecx, [ebp+0x4]
    mov [ebp-0x8],ecx  ;now ebp-8 has arg2 or counter 2 in it     
    pop ecx
    ;declare int temp3
    mov eax, [ebp+0x8] ;move arg1 into eax
    mov edx, [ebp+0x4] ;move arg2 int edx
    mul edx ;multiply eax by edx
    mov [ebp-0xc], eax ;ebp-0xc now has temp3 in it
    ;declare retval
    push ecx
    mov ecx, [ebp-0xc]
    mov [ebp-0x10], ecx
    pop ecx
    ;if temp 2 < 0 retval is += 17 else -= 13
    cmp dword [ebp-0x10], 0
    jg else    
    add dword [ebp-0x10], 17
    jmp switch
    else:
    sub dword [ebp-0x10], 13
    switch:
        push eax
        mov eax, [ebp-8]
        cmp eax, 4
        jge _default
        jmp [table + eax * 4]
        pop eax 
        jmp done1   
    case_0:
        ;retval = retval + temp2 + s_s_i + 4
        push ecx
        mov ecx, [ebp-0x8]
        add [ebp-0x10], ecx
        pop ecx
        add dword [ebp-0x10], some_static_int
        add dword [ebp-0x10], 4
        jmp done1
    case_1:
        ;retval = retval - temp2 + 5
        push ecx
        mov ecx, [ebp-0x8]
        sub [ebp-0x10], ecx
        pop ecx
        add dword [ebp-0x10], 5
        jmp done1
    case_2:
        ;retval = retval - 13 - s_s_i
        sub dword [ebp-0x10], 13
        sub dword [ebp-0x10], some_static_int
        jmp done1
    case_3:
        ;retval = retval + (temp3*7) - temp2
        push eax
        xor eax, eax
        mov eax, [ebp-0xc]
        push edx
        mov dword edx, 7
        mul edx
        pop edx
        add [ebp-0x10], eax
        xor eax, eax
        pop eax
        push ecx 
        mov ecx, [ebp-0x8]
        sub [ebp-0x10], ecx
        pop ecx
        jmp done1
    _default:
        ;default retval++
        inc dword [ebp-0x10]
        jmp done1
    done1:
    ;some static int = s_s_i - arg1 + retval
    push edx
    xor edx, edx
    mov edx, some_static_int
    sub edx, [ebp+0x8]  
    add edx, [ebp-0x10]
    mov [some_static_int], edx
    xor edx, edx
    pop edx
    ;move the right value into eax
    mov eax, [ebp-0x10]
    ;leave
    pop ebp
    ret








