# -x assembler-with-cpp
# gpSP makefile
# Gilead Kutnick - Exophase


# Global definitions

PSPSDK = ${shell psp-config --pspsdk-path}
PREFIX = ${shell psp-config --psp-prefix}

BUILD_PRX = 1
ENCRYPT = 1

PSP_FW_VERSION = 300
PSP_LARGE_MEMORY = 0

PSP_EBOOT_ICON = res/ICON0.png
PSP_EBOOT_TITLE = BonsaiGBA

EXTRA_TARGETS = EBOOT.PBP

COMMON_FILE = \
 common.h \
 cpu.h cpu_common.h memory.h video.h input.h sound.h main.h message.h mh_print.h gui.h zip.h png.h \
 ku_bridge.h exception.h ch_print.h

MAINOBJS = \
 cpu.o memory.o video.o input.o sound.o main.o message.o mh_print.o gui.o zip.o png.o \
 mips_stub.o volatile_mem.o \
 ku_bridge.o exception.o cheats.o ch_print.o

OBJZ = adler32.o crc32.o deflate.o infback.o inffast.o inflate.o inftrees.o trees.o zutil.o
OBJG = compress.o uncompr.o gzclose.o gzlib.o gzread.o gzwrite.o

OBJS = $(MAINOBJS) $(OBJZ) $(OBJG)

TARGET = BonsaiGBA

VPATH = src src/zlib

#
# Bonsai GBA build flags.
#
# `-fno-strict-aliasing` is intentional: emulator code legitimately punts the
# same backing store through different pointer types (u8*/u16*/u32*, mmap
# tables, JIT codegen buffers, savestate I/O, etc.). Strict aliasing breaks
# this and can silently miscompile correct code.
#
# `-flto=auto` and `-fipa-pta` give the compiler whole-program visibility,
# which the dynarec/video/audio paths benefit from significantly on PSP.
#
CFLAGS = \
 -O3 -G0 \
 -march=allegrex -mfp32 -mgp32 -mlong32 \
 -mllsc -mbranch-likely -mno-check-zero-division \
 -fomit-frame-pointer -fno-strict-aliasing \
 -fno-split-wide-types -fgcse-after-reload \
 -funroll-loops -fno-unwind-tables -fno-asynchronous-unwind-tables \
 -falign-functions=32 -falign-loops -falign-labels -falign-jumps \
 -ffast-math -fmerge-all-constants -funsafe-loop-optimizations -funsigned-char \
 -finline-functions -fipa-cp -fipa-cp-clone -fipa-pta \
 -fmodulo-sched -fmodulo-sched-allow-regmoves \
 -fforce-addr \
 -flto=auto -fno-fat-lto-objects \
 -Wall -Wundef -Wpointer-arith -Wbad-function-cast -Wwrite-strings -Wmissing-prototypes -Wsign-compare \
 -DZLIB_CONST

LDFLAGS += -flto=auto

ASFLAGS = ${CFLAGS}

INCDIR = SDK/include src src/zlib src/libpower
LIBDIR = SDK/lib

LIBS = src/libpower/libpsppower.a -lpspgu -lpsprtc -lpspaudio -lpspkubridge -lpspgum -lm

include ${PSPSDK}/lib/build.mak

