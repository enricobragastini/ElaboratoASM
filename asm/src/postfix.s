.section .data

buffer:
    .int 0

flag:
    .int 1


invalid_string:
    .ascii "Invalid\n"
invalid_string_len:
    .long . - invalid_string


.section .text
    .global postfix


postfix:
    # prologue
    pushl %ebp              # push del "vecchio" base pointer
    movl %esp, %ebp         # nuovo base pointer -> punta allo stack pointer
    
    # esp punta all'indirizzo di return
    movl 8(%ebp), %ecx      # esp+8: puntatore a stringa INPUT
    movl 4(%ebp), %ebx      # esp+4: puntatore a stringa OUTPUT

    movl %ecx, %esi         # in ESI -> puntatore a stringa INPUT

lettura:
    # STAMPA PER DEBUG
/*     movl $4, %eax           # stampa di un carattere
    movl $1, %ebx
    movl %esi, %ecx
    movl $1, %edx
    int $0x80 */
    
    # Controllo se ultimo carattere
    movb (%esi), %al        # una cifra è 1 byte -> usiamo la parte bassa di eax (al)
    cmp $0, %al             # controllo carattere di fine stringa '\0'
    je fine

space:
    movb (%esi), %al
    cmp $32, %al
    jne sum

    # se prima c'era una cifra
    # push del buffer nello stack (buffer*=flag; flag=1)
    # poi svuota il buffer, e vai avanti
    movb -1(%esi), %al
    cmp $48, %al           # compara con '0'
    jl operator_do_nothing

    cmp $57, %al           # compara con '9'
    jg operator_do_nothing

    movl buffer, %eax       
    movl flag, %ebx
    mul %ebx
    movl $1, flag

    pushl %eax
    movl $0, buffer

operator_do_nothing:        # se prima c'era un operatore non fare niente e vai avanti
    incl %esi               # vai al carattere successivo
    jmp lettura


sum:
    movb (%esi), %al
    cmp $43, %al
    jne dash

    # 2 pop dallo stack, fai la somma, push nello stack
    popl %eax
    popl %ebx
    addl %eax, %ebx
    pushl %ebx

    incl %esi              # vai al carattere successivo
    jmp lettura


dash:
    movb (%esi), %al
    cmp $45, %al
    jne multiplication
    
    # se dopo il trattino c'è uno spazio-> è una sottrazione
    #       2 pop dallo stack
    #       fai la sottrazione
    #       push nello stack
negative_number:
    movb 1(%esi), %al   # carattere successivo -> cifra: inizio di numero negativo
    cmp $48, %al
    jl operator_subtraction
    cmp $57, %al
    jg operator_subtraction

    movl $-1, flag      # flag a -1 per rendere il numero negativo

    incl %esi              # vai al carattere successivo
    jmp lettura

operator_subtraction:
    movb 1(%esi), %al   # carattere successivo -> spazio/fine stringa: operazione di sottrazione
    cmp $32, %al        # spazio
    je subtraction
    cmp $0, %al         # fine stringa
    je subtraction

    jmp invalid


subtraction:
    popl %eax           # sottraendo
    popl %ebx           # minuendo
    subl %eax, %ebx     # ebx = ebx - eax
    pushl %ebx
    
    incl %esi           # vai al carattere successivo
    jmp lettura


multiplication:
    movb (%esi), %al
    cmp $42, %al
    jne division

    # 2 pop dallo stack, fai il prodotto, push nello stack
    popl %eax
    popl %ebx
    imul %ebx
    pushl %eax

    incl %esi              # vai al carattere successivo
    jmp lettura

division:
    movb (%esi), %al
    cmp $47, %al
    jne digit

    popl %ebx       # divisore != 0
    cmp $0, %ebx
    je invalid

    popl %eax       # dividendo > 0
    cmp $0, %eax
    jl invalid

    xorl %edx, %edx
    idiv %ebx
    pushl %eax

    incl %esi              # vai al carattere successivo
    jmp lettura


digit:
    movb (%esi), %al

    cmp $48, %al           # compara con '0'
    jl invalid             # se minore è invalido

    cmp $57, %al           # compara con '9'
    jg invalid             # se maggiore è invalido

    # operazioni in caso di numero
    # se e solo se buffer != 0: buffer *= 10
    # buffer += cifra
    movl buffer, %eax      # eax -> buffer
    movl $10, %ebx
    mul %ebx               # moltiplica eax per 10

    xorl %ebx, %ebx        # azzero tutto ebx (32 bit)
    movb (%esi), %bl       # sposto la cifra nella parte bassa di ebx (bl)
    subb $48, %bl          # tolgo 48 per avere il valore in intero
    addl %ebx, %eax        # eseguo la somma
    movl %eax, buffer      # riporto il valore nel buffer
  
    incl %esi              # vai al carattere successivo
    jmp lettura            # ripeti

invalid:
    movl $4, %eax
    movl $1, %ebx
    leal invalid_string, %ecx
    movl invalid_string_len, %edx
    int $0x80
    

fine:
    movl %ebp, %esp         # ripristino lo stack pointer al base pointer

    popl %ebp
    ret
