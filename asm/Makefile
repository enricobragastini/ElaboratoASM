GCC = gcc -m32
AS = as -gstabs --32
LD = ld -m elf_i386

all:
	$(GCC) -c -g src/main.c -o obj/main.o
	$(GCC) -c -g src/postfix.s -o obj/postfix.o
	$(GCC) obj/main.o obj/postfix.o -o bin/postfix

clean:
	rm -f obj/* bin/*
