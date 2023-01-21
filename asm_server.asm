.intel_syntax noprefix
.global _start

.section .text
_start:

	mov rdi, 2 
	mov rsi, 1
	mov rdx, 0
	mov rax, 0x29 	# sys_socket socket(AF_INET, SOCK_STREAM, IPProto_IP)
	syscall

	mov rdi, 0
	mov rax, 0x3C 	# sys_exit exit(0)
	syscall

.section .data
