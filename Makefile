TARGET := rpi3

CC := clang -target aarch64-elf
LD := ld.lld
AS := $(CC)

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

run: $(TARGET)
	qemu-system-aarch64 -machine raspi3 -kernel build/kernel-$(<).elf -serial stdio

clean:
	$(RM)r build
