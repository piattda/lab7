OUTPUTS = hello_asm hello_c disassembly.txt lab7_c lab7_asm

all: $(OUTPUTS)

lab7_asm: lab7_asm.asm
	nasm -f elf -o lab7_asm.o $<
	gcc -m32 -o $@ lab7_asm.o
	
lab7_c: lab7_c.c
	gcc -g -m32 -o $@ $<

hello_asm: hello_asm.asm
	nasm -f elf -o hello_asm.o $<
	gcc -m32 -o $@ hello_asm.o

hello_c: hello_c.c
	gcc -g -m32 -o $@ $<

disassembly.txt: hello_c
	objdump --full-contents --section=.rodata $< > disassembly.txt
	objdump --full-contents --section=.data $< >> disassembly.txt
	objdump --architecture=i386 --disassembler-options=intel-mnemonic --no-show-raw-insn --source --wide $< >> disassembly.txt

clean:
	rm -f *.o $(OUTPUTS)
