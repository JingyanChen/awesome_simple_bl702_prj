#=====================CPU Common =====================
CPU_ARCH := RISCV
MCPU := riscv-e24
MARCH := rv32imafc
MABI :=ilp32f

#=====================Toolchain config================
COMPILE_PREFIX := riscv64-unknown-elf-
AS    := $(COMPILE_PREFIX)gcc
CC    := $(COMPILE_PREFIX)gcc
CPP   := $(COMPILE_PREFIX)g++
LD    := $(COMPILE_PREFIX)gcc
AR    := $(COMPILE_PREFIX)ar
OBJCOPY := $(COMPILE_PREFIX)objcopy
STRIP := $(COMPILE_PREFIX)strip

LD_FILE_PATH := bl702_driver/bl702_flash.ld
GLOBAL_CFLAGS = -DARCH_RISCV 

GLOBAL_CFLAGS +=-march=$(MARCH) -O2 -mabi=$(MABI) -g3 -fshort-enums -fno-common \
                 -fms-extensions -ffunction-sections -fdata-sections -fstrict-volatile-bitfields \
                 -Wall -Wshift-negative-value -Wchar-subscripts -Wformat -Wuninitialized -Winit-self -fno-jump-tables \
                 -Wignored-qualifiers -Wswitch-default -Wunused -Wundef -std=c99 -msmall-data-limit=4
# -Wl,option 将选项 传递给链接器
# --cref 输出交叉引用表
# --gc-sections 不链接未使用到的函数，减小可执行文件大小
# -nostartfiles 不使用标准系统启动文件
# -lm代表连接器将会链接GCC的数学标准库libm.a
# -lc代表连接器将链接GCC的标准C库 libc.a
# -g3意味着调试器的配置，启动较高的调试器内容
# extensions 增强一些基本功能
# -ffunction-sections -fdata-sections 仅链接以函数/数据作为最小section，这样可以避免因为调用了一个section而链接了整个以.c为一个section的库
# 
GLOBAL_LDFLAGS = -Wl,--cref -Wl,--gc-sections -nostartfiles -lc -lm -mabi=$(MABI) -g3  \
                     -fms-extensions -ffunction-sections -fdata-sections -Wall -Wchar-subscripts \
    				 -Wformat -Wuninitialized -Winit-self -Wignored-qualifiers -Wswitch-default -Wunused -Wundef -std=c99 \
    				 -march=$(MARCH) -Wl,-Map=$(TARGET_OUT)/$(basename $(TARGET)).map -T$(LD_FILE_PATH) \
				     -o $(TARGET_OUT)/$(basename $(TARGET)).elf

GLOBAL_CFLAGS += -mcmodel=medany
MODULE_DIR:=.
#======================Startup object generate=================

STARTUP_MODULE_DIR = bl702_driver/startup
STARTUP_OUT_DIR = build/startup
STARTUP_INCLUDE = -I bl702_driver/risc-v/Core/Include \
				 -I bl702_driver/startup \
				 -I bl702_driver/regs \
				 -I bl702_driver/std_drv/inc

LOCAL_ASM_FILE  := entry.S
LOCAL_SRCS_FILE := start_load.c interrupt.c system_bl702.c 

startup_objs:= $(addprefix $(STARTUP_OUT_DIR)/,$(subst .c,.o,$(LOCAL_SRCS_FILE))) 
startup_objs += $(addprefix $(STARTUP_OUT_DIR)/,$(subst .S,.o,$(LOCAL_ASM_FILE)))

$(STARTUP_OUT_DIR)/%.o:$(STARTUP_MODULE_DIR)/%.c
	@mkdir -p $(dir $@)
	@echo "cc $<"
	$(CC) -c $(GLOBAL_CFLAGS) $(GLOBAL_INCLUDE) $(STARTUP_INCLUDE) $< -o $@

$(STARTUP_OUT_DIR)/%.o:$(STARTUP_MODULE_DIR)/%.S
	@mkdir -p $(dir $@)
	@echo "cc $<"
	$(CC) -c $(GLOBAL_CFLAGS) $(GLOBAL_INCLUDE) $(STARTUP_INCLUDE) $< -o $@


riscv_core: $(startup_objs)
	@echo "$(startup_objs) is generate"
#=============================================================



#======================Stddriver object generate=================
STDDRIVER_MODULE_DIR = bl702_driver/std_drv/src
STDDRIVER_OUT_DIR = build/bl702_driver/std_drv/src
STDDRIVER_INCLUDE = -I bl702_driver/risc-v/Core/Include \
				 -I bl702_driver/startup \
				 -I bl702_driver/std_drv/inc \
				 -I bl702_driver/regs \

STDDRIVER_SRCS_FILE := bl702_uart.c \
						bl702_glb.c \
						bl702_common.c \

stddriver_objs:= $(addprefix $(STDDRIVER_OUT_DIR)/,$(subst .c,.o,$(STDDRIVER_SRCS_FILE))) 

$(STDDRIVER_OUT_DIR)%.o:$(STDDRIVER_MODULE_DIR)/%.c
	@mkdir -p $(dir $@)
	@echo "cc $<"
	$(CC) -c $(GLOBAL_CFLAGS) $(GLOBAL_INCLUDE) $(STDDRIVER_INCLUDE) $< -o $@

stddriver :$(stddriver_objs)
	@echo  "stddriver_objs is $(stddriver_objs) build success"
#========================================================

#======================helloworld bin generate=================
# first step build helloworld.c to helloworld.o

build/helloworld.o:helloworld.c
	@mkdir -p $(dir $@)
	$(CC) -c $(GLOBAL_CFLAGS) $(LOCAL_CFLAGS) \
	$(GLOBAL_INCLUDE) $(STDDRIVER_INCLUDE) $< -o $@

#============================================================
#链接过程，将.o文件使用链接器链接成一个可执行的bin文件
#指令分为三个部分 1 riscv64-unknown-elf-gcc 选择链接器
#               2 需要链接的.o文件列表
#               3 链接选项，包含MAP文件选项，链接脚本文件，通过-L -I来选择需要链接的库
#               4 -o 输出文件的路径
# riscv64-unknown-elf-gcc build/helloworld.o build/bl702_driver/std_drv/src/bl702_common.o build/bl702_driver/std_drv/src/bl702_glb.o build/bl702_driver/std_drv/src/bl702_uart.o build/startup/interrupt.o build/startup/system_bl702.o build/startup/entry.o build/startup/start_load.o -Wl,--cref -Wl,--gc-sections -nostartfiles -lc -lm -mabi=ilp32f -g3 -fms-extensions -ffunction-sections -fdata-sections -Wall -Wchar-subscripts -Wformat -Wuninitialized -Winit-self -Wignored-qualifiers -Wswitch-default -Wunused -Wundef -std=c99 -march=rv32imafc -Wl,-Map=build/hello.map -Tbl702_driver/bl702_flash.ld -o hello.elf


helloworld: build/helloworld.o stddriver riscv_core
	riscv64-unknown-elf-gcc build/helloworld.o build/bl702_driver/std_drv/src/bl702_common.o build/bl702_driver/std_drv/src/bl702_glb.o build/bl702_driver/std_drv/src/bl702_uart.o build/startup/interrupt.o build/startup/system_bl702.o build/startup/entry.o build/startup/start_load.o -Wl,--cref -Wl,--gc-sections -nostartfiles -lc -lm -mabi=ilp32f -g3 -fms-extensions -ffunction-sections -fdata-sections -Wall -Wchar-subscripts -Wformat -Wuninitialized -Winit-self -Wignored-qualifiers -Wswitch-default -Wunused -Wundef -std=c99 -march=rv32imafc -Wl,-Map=build/hello.map -Tbl702_driver/bl702_flash.ld -o hello.elf
	riscv64-unknown-elf-objcopy -O binary hello.elf hello.bin
clean:
	rm -rf build

.PHONY: basic_riscv_env helloworld