TARGET := rpi3

ifeq (,$(filter $(TARGET),rpi3 rpi4 qemu-virt))
$(error Invalid target: $(TARGET))
endif

CC := clang -target aarch64-elf
LD := ld.lld
AS := $(CC)
OBJCOPY := llvm-objcopy

CFLAGS := -O0 -g
CHARDFLAGS := -nostdlib -ffreestanding -fno-stack-protector -Isrc -Isrc/board/$(TARGET)
LDFLAGS :=
LDHARDFLAGS := -m aarch64elf -nostdlib -T src/board/$(TARGET)/linker.ld 
ASFLAGS := $(CFLAGS)

KERNEL_SRC := $(wildcard src/*.c src/*/*.c src/board/$(TARGET)/*.c src/board/$(TARGET)/*/*.c src/*.s src/*/*.s src/board/$(TARGET)/*.s src/board/$(TARGET)/*/*.s)
KERNEL_OBJ := $(patsubst src/%, build/$(TARGET)/%.o, $(KERNEL_SRC:%.c=%))
KERNEL_OBJ += $(patsubst src/%, build/$(TARGET)/%.o, $(KERNEL_OBJ:%.s=%))

all: $(shell mkdir -p build/$(TARGET) build/$(TARGET)/board/$(TARGET)) $(TARGET)

$(TARGET): $(KERNEL_OBJ)
	$(LD) $(LDFLAGS) $(LDHARDFLAGS) $^ -o build/kernel-$(@).elf

build/$(TARGET)/%.s.o: src/%.s
	$(AS) $< $(ASFLAGS) -c -o $@

build/$(TARGET)/%.o: src/%.c
	$(CC) $(CFLAGS) $(CHARDFLAGS) -c $< -o $@

run: $(TARGET) run-$(TARGET)

run-rpi3:
	$(OBJCOPY) -O binary build/kernel-rpi3.elf build/kernel8.img
	qemu-system-aarch64 -machine raspi3 -kernel build/kernel8.img -serial stdio

run-rpi4:
	$(error QEMU currently doesn't support Raspberry Pi 4. You might need to run the kernel on real hardware)

run-qemu-virt:
	qemu-system-aarch64 -machine virt -cpu cortex-a57 -kernel build/kernel-qemu-virt.elf -serial stdio

clean:
	$(RM)r build
