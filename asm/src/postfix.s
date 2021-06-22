# VARIABILI
.section .data

buffer:         
    .int 0

flag:
    .int 1


invalid_string:
    .ascii "Invalid\0"
invalid_string_len:
    .long . - invalid_string


# CODICE
.section .text
    .global postfix

postfix:
    pushl %ebp              # push del "vecchio" base pointer

    # pushl %eax
    # pushl %ebx
    # pushl %ecx
    # pushl %edx
    # pushl %esi
    # pushl %edi

    movl %esp, %ebp         # nuovo base pointer -> punta allo stack pointer
    movl 8(%ebp), %esi      # ebp+8: puntatore a stringa INPUT
    movl 12(%ebp), %edi     # ebp+12: puntatore a stringa OUTPUT


lettura:
    # Controllo se stiamo leggendo l'ultimo carattere
    movb (%esi), %al        # una cifra è 1 byte -> usiamo la parte bassa di eax (al)
    cmp $0, %al             # se è il carattere di fine stringa '\0'
    je print_result         # vado a stampare il risultato 


# Se non è stato letto l'ultimo carattere, valutiamo di che carattere si tratta
space:
    movb (%esi), %al
    cmp $32, %al            # se non è uno spazio
    jne sum                 # salta al controllo successivo
    # Se leggiamo uno spazio, bisogna valutare il carattere precedente.

    # Se prima c'era una cifra: push del buffer nello stack (buffer*=flag; flag=1)
    # poi svuota il buffer, e vai avanti
    movb -1(%esi), %al
    cmp $48, %al            # compara con '0'
    jl operator_do_nothing  # se non è un numero -> salta avanti

    cmp $57, %al            # compara con '9'
    jg operator_do_nothing  # se non è un numero -> salta avanti

    movl buffer, %eax       
    movl flag, %ebx
    mul %ebx                # eax = eax * ebx
    movl $1, flag

    pushl %eax              # push del numero contenuto nel buffer
    movl $0, buffer         # azzeramento del buffer


operator_do_nothing:        # se invece prima c'era un operatore: non fare niente e leggi il carattere successivo
    jmp next_char


sum:
    movb (%esi), %al        
    cmp $43, %al            # se non è una somma
    jne dash                # salta al controllo successivo

    # Se viene trovato il simbolo '+'
    popl %eax               # pop del 1° operando
    popl %ebx               # pop del 2° operando
    addl %eax, %ebx         # somma
    pushl %ebx              # push del risultato

    jmp next_char           # lettura del carattere successivo


dash:
    movb (%esi), %al
    cmp $45, %al            # se non è un trattino
    jne multiplication      # salta al controllo successivo
    
    # Se viene trovato il simbolo '-' bisogna valutare il carattere successivo
    # Se dopo c'è uno spazio siamo nel caso di una sottrazione, altrimenti è l'inizio di un numero negativo.

    negative_number:
        movb 1(%esi), %al   # carattere successivo -> cifra: inizio di numero negativo
        cmp $48, %al
        jl operator_subtraction
        cmp $57, %al
        jg operator_subtraction
        
        # se dopo c'è una cifra
        movl $-1, flag      # impostiamo la flag a -1 per indicare l'inizio di un numero negativo

        jmp next_char       # lettura del carattere successivo

    operator_subtraction:
        movb 1(%esi), %al   # carattere successivo -> spazio/fine stringa: operazione di sottrazione
        cmp $32, %al        # spazio
        je subtraction
        cmp $0, %al         # fine stringa
        je subtraction

        # se viene letto dopo un carattere invalido -> stampa la stringa invalid
        jmp invalid


    subtraction:
        popl %eax           # sottraendo
        popl %ebx           # minuendo
        subl %eax, %ebx     # ebx = ebx - eax
        pushl %ebx          # push del risultato

        jmp next_char       # lettura del carattere successivo


multiplication:
    movb (%esi), %al
    cmp $42, %al            # se non è un asterisco
    jne division            # salta al controllo successivo

    # 2 pop dallo stack, fai il prodotto, push nello stack
    popl %eax               # pop del 1° operando
    popl %ebx               # pop del 2° operando
    imul %ebx               # moltiplicazione
    pushl %eax              # push del risultato

    jmp next_char           # lettura del carattere successivo

division:
    movb (%esi), %al
    cmp $47, %al            # se non è uno slash
    jne digit               # salta al controllo successivo

    popl %ebx               # il divisore  deve essere diverso da 0
    cmp $0, %ebx
    je invalid

    popl %eax               # il dividendo deve essere maggiore di 0
    cmp $0, %eax
    jl invalid

    xorl %edx, %edx         
    idiv %ebx               # eax = eax / ebx
    pushl %eax              # push del risultato

    jmp next_char           # lettura del carattere successivo


digit:
    # se il programma salta tutti i precedenti controlli, abbiamo trovato una stringa (o un carattere invalido)
    movb (%esi), %al       

    cmp $48, %al           # compara con '0'
    jl invalid             # se minore è invalido

    cmp $57, %al           # compara con '9'
    jg invalid             # se maggiore è invalido

    # buffer *= 10
    # buffer += cifra
    movl buffer, %eax      # in eax salvo il buffer
    movl $10, %ebx
    mul %ebx               # buffer = buffer * 10

    xorl %ebx, %ebx        # azzero tutto ebx (32 bit)
    movb (%esi), %bl       # sposto la cifra in bl (8 bit)
    subb $48, %bl          # tolgo 48 a bl per convertire l'ascii in intero
    addl %ebx, %eax        # eseguo la somma
    movl %eax, buffer      # riporto il valore nel buffer


next_char:
    incl %esi              # vai al carattere successivo
    jmp lettura            # ripeti

invalid:
    # Quando viene trovato un carattere invalido
    movl invalid_string_len, %ecx   # in ecx viene messa la lunghezza della stringa da stampare
    leal invalid_string, %esi       # in esi il puntatore al primo carattere della stringa

    invalid_string_loop:            # loop per scrivere la stringa sull'array di output (puntatote in edi)
        movb (%esi), %al            
        movb %al, (%edi)
        incl %esi
        incl %edi
        loop invalid_string_loop    # decrementa ecx e fa loop finché non arriva a ecx == 0

    jmp fine


print_result:       # Scrittura del risultato sull'array di output
    popl %eax       # Intero da stampare
    movl $0, %ecx   # Contatore cifre

    cmp $0, %eax
    jge positive_number     # salta se il numero è positivo

    # se il numero è negativo
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


fine:
    movl %ebp, %esp     # riporto lo stack pointer al base pointer

    # popl %edi
    # popl %esi
    # popl %edx
    # popl %ecx
    # popl %ebx
    # popl %eax

    popl %ebp
    ret
