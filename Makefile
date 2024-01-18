#platform	:= CV1812H
platform	:= qemu
mode := debug
# mode := release
K=kernel
U=xv6-user
T=target

OBJS =
ifeq ($(platform), CV1812H)
OBJS += $K/entry_CV1812H.o
else
OBJS += $K/entry_qemu.o
endif

OBJS += \
  $K/printf.o \
  $K/kalloc.o \
  $K/intr.o \
  $K/spinlock.o \
  $K/string.o \
  $K/main.o \
  $K/vm.o \
  $K/proc.o \
  $K/swtch.o \
  $K/trampoline.o \
  $K/trap.o \
  $K/syscall.o \
  $K/sysproc.o \
  $K/bio.o \
  $K/sleeplock.o \
  $K/file.o \
  $K/pipe.o \
  $K/exec.o \
  $K/sysfile.o \
  $K/kernelvec.o \
  $K/timer.o \
  $K/disk.o \
  $K/fat32.o \
  $K/plic.o \
  $K/console.o \
  $K/testsd.o

ifeq ($(platform), CV1812H)
OBJS += \
  $K/spi.o \
  $K/gpiohs.o \
  $K/fpioa.o \
  $K/utils.o \
  $K/sdcard.o \
  $K/dmac.o \
  $K/sysctl.o \

else
OBJS += \
  $K/virtio_disk.o \
  $K/uart.o \

endif

QEMU = qemu-system-riscv64

ifeq ($(platform), CV1812H)
RUSTSBI = ./bootloader/SBI/sbi-CV1812H
else
RUSTSBI = ./bootloader/SBI/sbi-qemu
endif

TOOLPREFIX	:= riscv64-unknown-elf-
#TOOLPREFIX	:= riscv64-linux-gnu-
CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)gas
LD = $(TOOLPREFIX)ld
OBJCOPY = $(TOOLPREFIX)objcopy
OBJDUMP = $(TOOLPREFIX)objdump

CFLAGS = -Wall -Werror -O -fno-omit-frame-pointer -ggdb -g
CFLAGS += -MD
CFLAGS += -mcmodel=medany
CFLAGS += -ffreestanding -fno-common -nostdlib -mno-relax
CFLAGS += -I.
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)

ifeq ($(mode), debug) 
CFLAGS += -DDEBUG 
endif 

ifeq ($(platform), qemu)
CFLAGS += -D QEMU
endif

LDFLAGS = -z max-page-size=4096

ifeq ($(platform), CV1812H)
linker = ./linker/CV1812H.ld
endif

ifeq ($(platform), qemu)
linker = ./linker/qemu.ld
endif

# Compile Kernel
$T/kernel: $(OBJS) $(linker) $U/initcode
	@if [ ! -d "./target" ]; then mkdir target; fi
	@$(LD) $(LDFLAGS) -T $(linker) -o $T/kernel $(OBJS)
	@$(OBJDUMP) -S $T/kernel > $T/kernel.asm
	@$(OBJDUMP) -t $T/kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $T/kernel.sym
  
build: $T/kernel userprogs

# Compile RustSBI
RUSTSBI:
ifeq ($(platform), CV1812H)
	@cd ./bootloader/SBI/rustsbi-CV1812H && cargo build && cp ./target/riscv64gc-unknown-none-elf/debug/rustsbi-CV1812H ../sbi-CV1812H
	@$(OBJDUMP) -S ./bootloader/SBI/sbi-CV1812H > $T/rustsbi-CV1812H.asm
else
	@cd ./bootloader/SBI/rustsbi-qemu && cargo build && cp ./target/riscv64gc-unknown-none-elf/debug/rustsbi-qemu ../sbi-qemu
	@$(OBJDUMP) -S ./bootloader/SBI/sbi-qemu > $T/rustsbi-qemu.asm
endif

rustsbi-clean:
	@cd ./bootloader/SBI/rustsbi-CV1812H && cargo clean
	@cd ./bootloader/SBI/rustsbi-qemu && cargo clean

image = $T/kernel.bin
CV1812H = $T/CV1812H.bin
CV1812H-serialport := /dev/ttyUSB0

ifndef CPUS
CPUS := 2
endif

QEMUOPTS = -machine virt -kernel $T/kernel -m 128M -nographic

# use multi-core 
QEMUOPTS += -smp $(CPUS)

QEMUOPTS += -bios default #$(RUSTSBI)

# import virtual disk image
QEMUOPTS += -drive file=sdcard.img,if=none,format=raw,id=x0 
QEMUOPTS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
QEMUOPTS += -D /root/textlab8asm.txt -d in_asm
QEMUOPTSADD += -S -s -D /root/details/textlab8asm.txt -d in_asm

run: build
ifeq ($(platform), CV1812H)
	@$(OBJCOPY) $T/kernel --strip-all -O binary $(image)
	@$(OBJCOPY) $(RUSTSBI) --strip-all -O binary $(CV1812H)
	@dd if=$(image) of=$(CV1812H) bs=128k seek=1
	@$(OBJDUMP) -D -b binary -m riscv $(CV1812H) > $T/CV1812H.asm
	@chmod 777 $(CV1812H-serialport)
	@python3 ./tools/kflash.py -p $(CV1812H-serialport) -b 1500000 -t $(CV1812H)
else
	@$(QEMU) $(QEMUOPTS)
endif

$U/initcode: $U/initcode.S
	$(CC) $(CFLAGS) -march=rv64g -nostdinc -I. -Ikernel -c $U/initcode.S -o $U/initcode.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0 -o $U/initcode.out $U/initcode.o
	$(OBJCOPY) -S -O binary $U/initcode.out $U/initcode
	$(OBJDUMP) -S $U/initcode.o > $U/initcode.asm

tags: $(OBJS) _init
	@etags *.S *.c

ULIB = $U/ulib.o $U/usys.o $U/printf.o $U/umalloc.o

_%: %.o $(ULIB)
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o $@ $^
	$(OBJDUMP) -S $@ > $*.asm
	$(OBJDUMP) -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $*.sym

$U/usys.S : $U/usys.pl
	@perl $U/usys.pl > $U/usys.S

$U/usys.o : $U/usys.S
	$(CC) $(CFLAGS) -c -o $U/usys.o $U/usys.S

$U/_forktest: $U/forktest.o $(ULIB)
	# forktest has less library code linked in - needs to be small
	# in order to be able to max out the proc table.
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o $U/_forktest $U/forktest.o $U/ulib.o $U/usys.o
	$(OBJDUMP) -S $U/_forktest > $U/forktest.asm

# Prevent deletion of intermediate files, e.g. cat.o, after first build, so
# that disk image changes after first build are persistent until clean.  More
# details:
# http://www.gnu.org/software/make/manual/html_node/Chained-Rules.html
.PRECIOUS: %.o

UPROGS=\
	$U/_init\
	$U/_sh\
	$U/_cat\
	$U/_echo\
	$U/_grep\
	$U/_ls\
	$U/_kill\
	$U/_mkdir\
	$U/_xargs\
	$U/_sleep\
	$U/_find\
	$U/_rm\
	$U/_wc\
	$U/_test\
	$U/_usertests\
	$U/_strace\
	$U/_mv \
	$U/_inittest\

	#$U/_forktest\
	#$U/_ln\
	#$U/_stressfs\
	#$U/_grind\
	#$U/_zombie\

userprogs: $(UPROGS)
	@$(OBJCOPY) -S -O binary $U/_inittest $U/inittest.bin

dst=/mnt

# @cp $U/_init $(dst)/init
# @cp $U/_sh $(dst)/sh
# Make fs image
fs: $(UPROGS)
	@if [ ! -f "fs.img" ]; then \
		echo "making fs image..."; \
		dd if=/dev/zero of=fs.img bs=512k count=512; \
		mkfs.vfat -F 32 fs.img; fi
	@mount fs.img /mnt
	@if [ ! -d "$(dst)/bin" ]; then mkdir $(dst)/bin; fi
	@cp README $(dst)/README
	@for file in $$( ls $U/_* ); do \
		cp $$file $(dst)/$${file#$U/_};\
		cp $$file $(dst)/bin/$${file#$U/_}; done
	@umount $(dst)

# Write mounted sdcard
sdcard: userprogs
	@if [ ! -d "$(dst)/bin" ]; then mkdir $(dst)/bin; fi
	@for file in $$( ls $U/_* ); do \
		cp $$file $(dst)/bin/$${file#$U/_}; done
	@cp $U/_init $(dst)/init
	@cp $U/_sh $(dst)/sh
	@cp README $(dst)/README

clean: 
	rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg \
	*/*.o */*.d */*.asm */*.sym \
	$T/* \
	$U/initcode $U/initcode.out \
	$K/kernel \
	$U/inittest.bin \
	./kernel-qemu \
	./kernel-qemu.asm \
	./kernel-qemu.sym \
	.gdbinit \
	$U/usys.S \
	$(UPROGS)

qg: build
	@$(QEMU) $(QEMUOPTS) $(QEMUOPTSADD)


# all: $(UPROGS)
# 	@if [ ! -f "kernel-qemu" ]; then \
# 		echo "kernel-qemu..."; \
# 		dd if=/dev/zero of=kernel-qemu bs=512k count=512; \
# 		mkfs.vfat -F 32 fs.img; fi
# 	@mount kernel-qemu /mnt
# 	@if [ ! -d "$(dst)/bin" ]; then mkdir $(dst)/bin; fi
# 	@cp README $(dst)/README
# 	@for file in $$( ls $U/_* ); do \
# 		cp $$file $(dst)/$${file#$U/_};\
# 		cp $$file $(dst)/bin/$${file#$U/_}; done
# 	@umount $(dst)

# build-qemu: platform=qemu
# build-qemu: build

all:
	@make userprogs
	@make build platform=qemu mode=release
	@cp $T/kernel ./kernel-qemu
	@cp $T/kernel.asm ./kernel-qemu.asm
	@cp $T/kernel.sym ./kernel-qemu.sym

qemu: all
	@qemu-system-riscv64 \
	-machine virt \
	-kernel kernel-qemu \
	-m 128M -nographic -smp 2 \
	-bios default \
	-drive file=sdcard.img,if=none,format=raw,id=x0 \
	-device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 \
	-device virtio-net-device,netdev=net \
	-netdev user,id=net \

	