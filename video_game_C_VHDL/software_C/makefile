#############################################
#MAKEFILE FOR COMPILING TOOLS AND PROGRAMS FOR THE TARGET#
#############################################

#Modify the .bashrc file: export PATH=/home/xxxxxxxxxxx/mlite_project/gccmips_elf:$PATH

# The CC_X86 is for compiling tools on your PC.
#CC_X86 = cl /O1 /nologo

VHDL_DIR = ../vhdl
TOOLS_BIN = ./bin

# The GCC_MIPS is for compiling code on the target.
BIN_MIPS = ../gccmips_elf
GCC_MIPS  = $(BIN_MIPS)/gcc $(CFLAGS)
AS_MIPS   = $(BIN_MIPS)/as
LD_MIPS   = $(BIN_MIPS)/ld
DUMP_MIPS = $(BIN_MIPS)/objdump

# Convert_bin changes test.axf into code.txt which is used by the VHDL.
CONVERT_BIN = $(TOOLS_BIN)/convert_bin.exe

CP = cp
RM = rm -rf 
CFLAGS = -O2 -Wall -c -s 

#all: convert_bin.exe tracehex.exe bintohex.exe ram_image.exe
#	@echo make targets = count, opcodes, pi, test, run, tohex, \
#	bootldr, toimage, etermip
	
clean:
	-$(RM) *.o *.obj *.map *.lst *.hex *.txt *.exe *.axf

opcodes: 
	$(AS_MIPS) -o opcodes.o opcodes.asm
	$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf opcodes.o
	-@$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)

test: 
	$(AS_MIPS) -o boot.o boot.asm
	$(GCC_MIPS) test.c
	$(GCC_MIPS) no_os.c
	$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf \
		boot.o test.o no_os.o
	-@$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)
	
count: 
	$(AS_MIPS) -o boot.o boot.asm
	$(GCC_MIPS) count.c
	$(GCC_MIPS) no_os.c 
	$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf \
		boot.o count.o no_os.o 
	-$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)

pi: 
	$(AS_MIPS) -o boot.o boot.asm
	$(GCC_MIPS) pi.c
	$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf \
		boot.o pi.o 
	@$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)

# Run a MIPS opcode simulator
run: $(TOOLS_BIN)/mlite.exe test.bin 

disassemble: mlite.exe
	$(TOOLS_BIN)/mlite.exe test.bin BD > test.txt

# Used by Altera FPGAs for ram image
tohex: bintohex.exe
	$(TOOLS_BIN)/bintohex.exe test.bin
	$(CP) code*.hex $(VHDL_DIR)

# Used by Xilinx FPGAs for ram image
toimage:
	$(TOOLS_BIN)/ram_image.exe ../vhdl/ram_xilinx.vhd ../vhdl/code.txt ../vhdl/ram_image.vhd

new_app :
	$(AS_MIPS) -o boot.o boot.asm
	$(GCC_MIPS) new_app.c
	$(GCC_MIPS) no_os.c
	$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf \
		boot.o new_app.o no_os.o
	-$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)

test_led : 
	$(AS_MIPS) -o boot.o boot.asm
	$(GCC_MIPS) test_led.c
	$(GCC_MIPS) no_os.c
	$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf \
		boot.o test_led.o no_os.o
	-$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)
	
	
count2:
	$(AS_MIPS) -o boot.o boot.asm
	$(GCC_MIPS) count.c
	$(GCC_MIPS) no_os.c
	$(LD_MIPS) -Ttext 0x10000000 -eentry -Map test.map -s -N -o test.axf \
		boot.o count.o no_os.o
	-$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)

bootldr:
	$(AS_MIPS) -o boot.o boot.asm
	$(GCC_MIPS) bootldr.c
	$(GCC_MIPS) no_os.c
	$(GCC_MIPS) -DDLL_DISABLE ddr_init.c
	$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf \
		boot.o bootldr.o no_os.o ddr_init.o
	@$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)
	
tp3 :
	$(AS_MIPS) -o boot.o boot.asm
	$(GCC_MIPS) tp3.c
	$(GCC_MIPS) no_os.c
	$(LD_MIPS) -Ttext 0x10000000 -eentry -Map test.map -s -N -o test.axf \
		boot.o tp3.o no_os.o
	-$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)
	
vga_sprite :
	$(AS_MIPS) -o boot.o boot.asm
	$(GCC_MIPS) vga_sprite.c
	$(GCC_MIPS) no_os.c
	$(LD_MIPS) -Ttext 0x10000000 -eentry -Map test.map -s -N -o test.axf \
		boot.o vga_sprite.o no_os.o
	-$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)
	
jeu :
	$(AS_MIPS) -o boot.o boot.asm
	$(GCC_MIPS) jeu.c
	$(GCC_MIPS) no_os.c
	$(LD_MIPS) -Ttext 0x10000000 -eentry -Map test.map -s -N -o test.axf \
		boot.o jeu.o no_os.o
	-$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)