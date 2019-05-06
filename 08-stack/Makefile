build_dir=build
iso=dist/train-os.iso
linker_script=linker.d
kernel=dist/kernel.bin
grub_cfg=grub.cfg

TARGET=x86_64-elf
CC=$(TARGET)-gcc

asm_source_files := $(wildcard *.asm)
asm_object_files := $(patsubst %.asm, $(build_dir)/%.o, $(asm_source_files))

c_source_files := $(wildcard *.c)
c_object_files := $(patsubst %.c, $(build_dir)/%.o, $(c_source_files))

# CFLAGS=-ffreestanding
CFLAGS=

clean:
	@rm -r build

# assemble all asm files
$(build_dir)/%.o: %.asm
	mkdir -p $(build_dir)
	echo $@
	nasm -f elf64 $< -o $@

$(build_dir)/%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@

# buils the kernel
kernel: $(kernel)

$(kernel): $(asm_object_files) $(c_object_files) $(linker_script)
	@mkdir -p $(shell dirname $@)
	ld -T $(linker_script) -o $@ $(asm_object_files) $(c_object_files)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p $(build_dir)/isofiles/boot/grub
	@cp $(kernel) $(build_dir)/isofiles/boot/kernel.bin
	@cp $(grub_cfg) $(build_dir)/isofiles/boot/grub/
	@grub-mkrescue -o $(iso) $(build_dir)/isofiles
	@rm -r $(build_dir)/isofiles

run: $(iso)
	qemu-system-x86_64 $(iso)

