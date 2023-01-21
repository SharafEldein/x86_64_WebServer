.intel_syntax noprefix
.global _start

.section .text
_start:

	mov rdi, 2 
	mov rsi, 1
	mov rdx, 0
	mov rax, 0x29 	# socket(AF_INET, SOCK_STREAM, IPProto_IP)
	syscall

	mov rdi, 3
	lea rsi, [rip+structaddr]
	mov rdx, 16
	mov rax, 0x31 	# bind(3, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("0.0.0.0"), 0}, 16)
 	syscall 

	mov rdi, 3
	mov rsi, 0
	mov rax, 0x32	# listen(3,0)
	syscall

	mov rdi, 3
	mov rsi, 0
	mov rdx, 0
	mov rax, 2B 	# accept(3, NULL, NULL)
	syscall
	
	mov rdi, 0
	mov rax, 0x3C 	# exit(0)
	syscall

.section .data
structaddr:
	.2byte 2
	.2byte 0x5000
	.4byte 0
	.byte  0