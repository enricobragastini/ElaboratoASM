AS = as -gstabs --32
LD = ld -m elf_i386
file = test_lettura

all:
	$(AS) $(file).s -o $(file).o
	$(LD) $(file).o -o $(file)

clean:
	rm -f $(file).o $(file) 