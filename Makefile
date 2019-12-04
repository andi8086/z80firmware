all: test4.asm
	zasm -u test4.asm
	cat test4.rom test4.rom > test4b.rom
