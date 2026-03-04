#
# Simple Makefile for a Prog8 program.
#

# Cross-platform commands
ifeq ($(OS),Windows_NT)
    CLEAN = del /Q build\*
    CP = copy
    RM = del /Q
    MD = mkdir
    SEP = \\
    PATHSEP = ;
else
    CLEAN = rm -f build/*
    CP = cp -p
    RM = rm -f
    MD = mkdir -p
    SEP = /
    PATHSEP = :
endif

# needed for subst
EMPTY:=
SPACE:=$(EMPTY) $(EMPTY)

BUILD_DIR=build
PCC=prog8c
PCCARGS?=-asmlist -out $(BUILD_DIR) $(pccargs_$(platform)) 
PCCARGS+=-srcdirs $(subst $(SPACE),$(PATHSEP),$(PROG8_SRCDIRS))

# must be defined for each target/platform
pccargs_= -target CHECK_PLATFORM_SETTINGS
pccargs_c64=-target c64
pccargs_cx16=-target cx16

EMU?=$(emu_$(platform)) 

# must be defined for each target/platform
emu_=echo broken platform
emu_c64=x64sc -autostartprgmode 1
emu_cx16=x16emu -run -prg

# the top level file you pass to the compiler
SRCS = src/main.p8

# the directory where your src files are
PROG8_SRCDIRS = src

# automatically imports libraries from ./libs/
include $(wildcard libs/*/lib.mk)

# list of platforms to build in build-<target> format
all: build_dir build-c64 build-cx16

build_dir:
	$(MD) $(BUILD_DIR)

# list one build-<target> for each platform
build-c64: platform=c64
build-cx16: platform=cx16
build-%: $(BUILD_DIR)/main%.prg
	@echo "End platform: $(platform)"

# list at prg per platform
$(BUILD_DIR)/mainc64.prg: platform=c64
$(BUILD_DIR)/maincx16.prg: platform=cx16
$(BUILD_DIR)/%.prg: $(SRCS)
	@echo "Platform: $(platform)"
	$(PCC) $(PCCARGS) $<
	$(CP) $(BUILD_DIR)/main.prg $@
	$(RM) $(BUILD_DIR)/main.prg

# list one emu-<target> for each platform
emu-c64: platform=c64
emu-cx16: platform=cx16
emu-%:  $(BUILD_DIR)/main%.prg
	$(EMU) $<

# remove by extension instead of just '*' for safety
clean:
	$(RM) $(BUILD_DIR)$(SEP)*.asm
	$(RM) $(BUILD_DIR)$(SEP)*.list
	$(RM) $(BUILD_DIR)$(SEP)*.prg
	$(RM) $(BUILD_DIR)$(SEP)*.vice-mon-list

#
# end-of-file
#
