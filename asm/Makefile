GCC = gcc -m32

all:
	$(GCC) -c -g src/main.c -o obj/main.o
	$(GCC) -c -g src/postfix.s -o obj/postfix.o
	$(GCC) obj/main.o obj/postfix.o -o bin/postfix

clean:
	rm -f obj/* bin/postfix
