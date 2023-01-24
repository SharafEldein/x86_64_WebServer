.intel_syntax noprefix
.global _start

.section .text
_start:

        mov rdi, 2
        mov rsi, 1
        mov rdx, 0
        mov rax, 0x29   # socket(AF_INET, SOCK_STREAM, IPProto_IP)
        syscall

        mov rdi, 3
        lea rsi, [rip+structaddr]
        mov rdx, 16
        mov rax, 0x31   # bind(3, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("0.0.0.0"), 0}, 16)
        syscall

        mov rdi, 3
        mov rsi, 0
        mov rax, 0x32   # listen(3,0)
        syscall

        mov rdi, 3
        mov rsi, 0
        mov rdx, 0
        mov rax, 0x2B   # accept(3, NULL, NULL)
        syscall

        mov rax, 0x39
        syscall

        cmp rax, 0
        je child

        mov rdi, 4
        mov rax, 0x3    # close(4)
        syscall

        mov rdi, 3
        mov rsi, 0
        mov rdx, 0
        mov rax, 0x2B   # accept(3, NULL, NULL)
        syscall

        jmp all_done
child:
        mov rdi, 3
        mov rax, 0x3    # close(3)
        syscall

        mov rdi, 4
        lea rsi, [rsp]  # read starting from stack pointer till nullByte
        mov rdx, 512
        mov rax, 0x0    # read(4, req, req.size)
        syscall
        push rax        # saving size of request
        push rsi


        loop_first_space:
                mov r10b, [rsi]
                cmp r10b, ' '
                je done
                inc rsi
                jmp loop_first_space

        done:
                inc rsi

        mov r9, rsi     # saving start of the path
        loop_second_space:
                mov r10b, [rsi]
                cmp r10b, ' '
                je done_2
                inc rsi
                jmp loop_second_space
        done_2:
                mov byte ptr [rsi], 0   # nullByteing the end of string


        mov rdi, r9
        mov rsi, 0101
        mov rdx, 0777
        mov rax, 0x2    # open("path", flags, mode)
        syscall



        pop rsi
        xor rdx, rdx
        last_req_header:
                mov r10d, [rsi]
                cmp r10d, 0x0A0D0A0D    #"\r\n\r\n"
                je raw_data
                add rdx, 4
                add rsi, 4
                jmp last_req_header
        raw_data:
                add rsi, 4
                add rdx, 4
                mov r8, rsi


        pop r10
        sub r10, rdx

        mov rdi, 3
        mov rsi, r8
        mov rdx, r10
        mov rax, 0x1    # write(3, raw_data, raw_data.size)
        syscall


        mov rdi, 3
        mov rax, 0x3    # close(3)
        syscall

        mov rdi, 4
        lea rsi, [rip+str]
        mov rdx, 19
        mov rax, 0x1    # write(4, 200 Ok, response.size)
        syscall


all_done:
        mov rdi, 0
        mov rax, 0x3C
        syscall

.section .data
structaddr:
        .2byte 2
        .2byte 0x5000
        .4byte 0
        .byte  0

str:
        .string "HTTP/1.0 200 OK\r\n\r\n"

