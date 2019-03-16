global          _start

section         .text

%macro write 2
	mov 		rax, 1
	mov 		rdi, 1
	mov 		rsi, %1
	mov 		rdx, %2
	syscall
	cmp rax, 0
	jl _writing_failure_error
%endmacro

read:
	xor			rax, rax
	mov			rdi,  [input_fd]
	mov			rsi, input_msg
	mov			rdx, input_msg.len
	syscall
	ret

parse:      
	mov rax, r8
    mov rcx, 10
    xor rdi, rdi
	
loop:

    xor rdx, rdx
    div rcx
    add dl, '0'
    push rdx
    inc rdi
    cmp rax, 0
    je end
    jmp loop
	

end:

    mov [buf.len], dil
    xor rcx, rcx
	
for:

    pop rax
    mov [buf + rcx], al
    inc rcx
    dec rdi
    jz return
    jmp for

return:
	ret

check:
	mov rax, input_msg
	xor r10, r10
	go:
		cmp r10, input_msg.len
		jg return
		call check1
		inc r10
		mov rax, [input_msg + r10] 
		jmp go
	ret

check1:
		cmp al, 8
		jg check2
		mov r9, 1
		ret

check2:
	cmp al, 14
	jl main_check
	cmp al, 32
	je main_check
	mov r9, 1
	ret 

main_check:
	cmp r9, 1
	je sum
	ret

sum:
	inc r8
	xor r9, r9
	ret

_start:
	pop rax
	cmp rax, 2
	jne _wrong_args_error
	
	pop rax
	mov rax, 2
	pop rdi
	xor rsi, rsi
	xor rdx, rdx
	syscall
	
	cmp     rax, 0
    jl      _input_init_failure_error
    mov     [input_fd], rax
	poop:
		xor r9, r9
		call read
		cmp rax, 0
		jl err
		je exit
		call check
		jmp poop
		
err:
	call _reading_failure_error
	
exit:		
		call parse
		write buf, [buf.len]
		write   endl, endl.len
		mov 		rax, 60
		xor 			rdi, rdi
		syscall
	
exit1:
		mov 		rax, 60
		xor 			rdi, rdi
		syscall
	
_wrong_args_error:
    write   input_args_failure_msg, input_args_failure_msg_len
write   endl, endl.len
    call exit1

_input_init_failure_error:
    write   input_init_failure_msg, input_init_failure_msg_len
write   endl, endl.len    
call exit1

_reading_failure_error:
    write   reading_failure_msg, reading_failure_msg_len
	write   endl, endl.len
    call exit1

_writing_failure_error:
    write   writing_failure_msg, writing_failure_msg_len
	write   endl, endl.len
    call exit1

input_args_failure_msg      db      "usage: count_words INPUT_FILE"
input_args_failure_msg_len  equ     $ - input_args_failure_msg
input_init_failure_msg      db      "input init failure"
input_init_failure_msg_len  equ     $ - input_init_failure_msg
reading_failure_msg         db      "reading failure"
reading_failure_msg_len     equ     $ - reading_failure_msg
writing_failure_msg         db      "writing failure"
writing_failure_msg_len     equ     $ - writing_failure_msg

section 	.rodata
endl        db      10
.len    	equ        1

section         .bss

input_msg:      resb              1024
.len 				  equ		  		  1024

section         .bss

buf:           			resb              20
.len 						resb 				1
input_fd    				resq    			1
