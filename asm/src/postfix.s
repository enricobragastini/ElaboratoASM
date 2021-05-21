.section .data

buffer:
    .int 0

flag:
    .int 1


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
    #STAMPA PER DEBUG
    
    # Controllo se ultimo carattere
    movl (%esi), %eax
    cmp $0, %eax
    je fine

    # Controlli

space:
    movl (%esi), %eax
    cmp $32, %eax
    jne sum

    # se prima c'era una cifra
    # push del buffer nello stack (buffer*=flag; flag=1)
    # poi svuota il buffer
    # e vai avanti

    # se prima c'era un operatore
    # non fare niente e vai avanti

    jmp lettura

sum:
    movl (%esi), %eax
    cmp $43, %eax
    jne subtraction

    # 2 pop dallo stack
    # fai la somma
    # push nello stack

    jmp lettura

subtraction:
    movl (%esi), %eax
    cmp $45, %eax
    jne multiplication
    
    # se dopo la meno c'è uno spazio-> è una sottrazione
    #       2 pop dallo stack
    #       fai la somma
    #       push nello stack
    # altrimenti -> è l'inizio di un numero negativo
    #       metti flag a -1

    jmp lettura

multiplication:
    movl (%esi), %eax
    cmp $42, %eax
    jne division

    # 2 pop dallo stack
    # fai il prodotto
    # push nello stack

    jmp lettura

division:
    movl (%esi), %eax
    cmp $47, %eax
    jne digit

    # 2 pop dallo stack
    # fai la divisione
    # push nello stack

    jmp lettura


digit:
    movl (%esi), %eax
    cmp $48, %eax
    jl invalid
    cmp $57, %eax
    jg invalid
    # operazioni in caso di numero
    # se buffer != 0: buffer *= 10
    # buffer += cifra

    movl buffer, %eax       # eax -> buffer
    cmpl $0, %eax
    je prima_cifra
    movl $10, %ebx
    mul %ebx                # moltiplica eax per 10
prima_cifra:
    add (%esi), %eax        # buffer += cifra
    # movl %eax, buffer


    incl %esi              # vai al carattere successivo
    jmp lettura            # ripeti 

invalid:


fine:
    popl %ebp
    ret
