.lcomm statlocation, 1024

.section .data          # variabili statiche

filename:   
    .string     "file.txt"
filesize:
    .int        0

carattere:
    .ascii      "#"

fd:         # file descryptor
    .int 0


.section .text
    .global _start      # codice


_start:
    # Apertura file
    movl $5, %eax
    movl $filename, %ebx
    movl $0, %ecx
    movl $0777, %edx
    int $0x80
    
    movl %eax, fd

    # Lettura dimensione file
    movl $18, %eax
    movl fd, %ebx
    leal statlocation, %ecx
    int $0x80

    leal statlocation, %eax
    movl 20(%eax), %ebx
    movl %ebx, filesize


leggi:
    # Lettura carattere da file
    movl $3, %eax
    movl fd, %ebx          # leal 
    leal carattere, %ecx
    movl $1, %edx
    int $0x80

    movb carattere, %al
    movb $10, %bl          # 10 -> \0  LF
    cmp %al, %bl           
    je fine

    # Stampa del carattere a console
    movl $4, %eax
    movl $1, %ebx
    leal carattere, %ecx
    movl $1, %edx
    int $0x80
    
    jmp leggi


fine:
    movl $1, %eax
    movl $0, %ebx
    int $0x80
