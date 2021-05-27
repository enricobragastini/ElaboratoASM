.section .data

buffer:
    .int 0

flag:
    .byte 1

invalid_string:
    .ascii "Invalid"
invalid_string_len:
    .long . - invalid_string


.section .text
    .global postfix


postfix:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %ecx     # puntatore a stringa INPUT
    movl 4(%ebp), %ebx     # puntatore a stringa OUTPUT

    movl %ecx, %esi        # in ESI -> puntatore a stringa INPUT

lettura:
    # STAMPA PER DEBUG
    movl $4, %eax         # stampa di un carattere
    movl $1, %ebx
    movl %esi, %ecx
    movl $1, %edx
    int $0x80
    
    # Controllo se ultimo carattere
    movb (%esi), %al                    # una cifra è 1 byte -> usiamo la parte bassa di eax (al)
    cmp $0, %al        # '\0'
    je fine

    # Controlli

space:
    movb (%esi), %al
    cmp $32, %al
    jne sum

    # se prima c'era una cifra
    # push del buffer nello stack (buffer*=flag; flag=1)
    # poi svuota il buffer
    # e vai avanti
    movb -1(%esi), %al
    cmp $48, %al           # compara con '0'
    jl operator_do_nothing

    cmp $57, %al           # compara con '9'
    jg operator_do_nothing

    movl buffer, %eax       
    movb flag, %bl
    mul %bl
    movb $1, flag

    pushl %eax
    movl $0, buffer

operator_do_nothing:        # se prima c'era un operatore non fare niente e vai avanti
    incl %esi               # vai al carattere successivo
    jmp lettura


sum:
    movb (%esi), %al
    cmp $43, %al
    jne subtraction

    # 2 pop dallo stack, fai la somma, push nello stack
    popl %eax
    popl %ebx
    addl %eax, %ebx
    pushl %ebx

    incl %esi              # vai al carattere successivo
    jmp lettura


subtraction:
    movb (%esi), %al
    cmp $45, %al
    jne multiplication
    
    # se dopo la meno c'è uno spazio-> è una sottrazione
    #       2 pop dallo stack
    #       fai la somma
    #       push nello stack
    # altrimenti -> è l'inizio di un numero negativo
    #       metti flag a -1

    incl %esi              # vai al carattere successivo
    jmp lettura

multiplication:
    movb (%esi), %al
    cmp $42, %al
    jne division

    # 2 pop dallo stack, fai il prodotto, push nello stack
    popl %eax
    popl %ebx
    mul %ebx
    pushl %eax

    incl %esi              # vai al carattere successivo
    jmp lettura

division:
    movb (%esi), %al
    cmp $47, %al
    jne digit

    # 2 pop dallo stack
    # fai la divisione
    # push nello stack

    incl %esi              # vai al carattere successivo
    jmp lettura


digit:
    movb (%esi), %al

    cmp $48, %al           # compara con '0'
    jl invalid              # se minore è invalido

    cmp $57, %al           # compara con '9'
    jg invalid              # se maggiore è invalido

    # operazioni in caso di numero
    # se e solo se buffer != 0: buffer *= 10
    # buffer += cifra
    movl buffer, %eax       # eax -> buffer
    movl $10, %ebx
    mul %ebx                # moltiplica eax per 10

    xorl %ebx, %ebx        # azzero tutto ebx (32 bit)
    movb (%esi), %bl       # sposto la cifra nella parte bassa di ebx (bl)
    subb $48, %bl          # tolgo 48 per avere il valore in intero
    addl %ebx, %eax        # eseguo la somma
    movl %eax, buffer      # riporto il valore nel buffer

/* test_buf:                # per vedere il contenuto di buffer perché non sappiamo farlo da gdb
    movl buffer, %ecx */
    
    incl %esi              # vai al carattere successivo
    jmp lettura            # ripeti

invalid:
    movl $4, %eax
    movl $1, %ebx
    leal invalid_string, %ecx
    movl invalid_string_len, %edx
    int $0x80


fine:
    popl %ebp
    ret
