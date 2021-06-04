.section .data

buffer:
    .int 0

flag:
    .int 1


invalid_string:
    .ascii "Invalid\0"
invalid_string_len:
    .long . - invalid_string


.section .text
    .global postfix


postfix:
    # prologue
    pushl %ebp              # push del "vecchio" base pointer
    movl %esp, %ebp         # nuovo base pointer -> punta allo stack pointer
    
    movl 8(%ebp), %esi      # ebp+8: puntatore a stringa INPUT
    movl 12(%ebp), %edi     # ebp+12: puntatore a stringa OUTPUT


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
    je print_result

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
    jmp next_char


sum:
    movb (%esi), %al
    cmp $43, %al
    jne dash

    # 2 pop dallo stack, fai la somma, push nello stack
    popl %eax
    popl %ebx
    addl %eax, %ebx
    pushl %ebx

    jmp next_char


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

    jmp next_char

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
    
    jmp next_char


multiplication:
    movb (%esi), %al
    cmp $42, %al
    jne division

    # 2 pop dallo stack, fai il prodotto, push nello stack
    popl %eax
    popl %ebx
    imul %ebx
    pushl %eax

    jmp next_char

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

    jmp next_char


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


next_char:
    incl %esi              # vai al carattere successivo
    jmp lettura            # ripeti

invalid:
    movl invalid_string_len, %ecx
    leal invalid_string, %esi

    invalid_string_loop:
        movb (%esi), %al
        movb %al, (%edi)
        incl %esi
        incl %edi
        loop invalid_string_loop
    jmp fine


print_result:
    popl %eax   # intero completo da stampare
    movl $0, %ecx   # contatore cifre

    cmp $0, %eax
    jge positive_number
    # il numero è negativo
    movl $-1, flag  # flag a -1
    movl $-1, %ebx
    imul %ebx       # rendiamo eax positivo

    positive_number:
        pushl $-48
        incl %ecx

        continue_division:
            cmp $10, %eax   # valuta se c'è solo una cifra
            jge divide

            # se rimane solo una cifra (è la più significativa)
            pushl %eax
            incl %ecx

            # controllo se lavoriamo con un numero negativo
            movl $-1, %edx
            cmp flag, %edx 
            jne skip_dash
            # numero negativo -> aggiungiamo il '-' davanti
            pushl $-3
            incl %ecx

            skip_dash:
            mov  %ecx, %ebx
            jmp print

        divide:
            movl $0, %edx       
            movl $10, %ebx          # divisore in ebx
            divl %ebx               # divisione eax/ebx: in eax quoziente, in edx resto

            pushl %edx              # push del resto
            incl %ecx               # incrementa contatore cifre

            jmp continue_division   # comincia da capo

        print:
            cmp $0, %ebx            # se ho finito le cifre da stampare
            je fine                 # termino l'esecuzione

            popl %eax 
            addb $48, %al           # ottengo il valore ascii
            movb %al, (%edi)

            decl %ebx               # decremento il contatore delle cifre
            incl %edi               # incremento il puntatore al carattere successivo

            jmp print

fine:
    movl %ebp, %esp     # riporto lo stack pointer al base pointer

    popl %ebp
    ret
