TOP = ../../..
WANT_TCL=yes
include $(TOP)/platform.mk

# -----
# Tcl 8.5 requires a workaround

TCLVER=$(shell echo 'catch { puts [info tclversion]; exit 0}; exit 1' | $(TCLSH))
ifeq ($(TCLVER),8.5)
# Use -optc-D instead of -D, since not all versions of GHC pass -D to the C compiler
# (see GHC issue 24885)
CFLAGS += -DTCL85
else
ifeq ($(TCLVER),8.6)
# No flags needed
else
$(error Unsupported Tcl version: $(TCLVER))
endif
endif

# -----

CFLAGS += -Wall ${TCL_INC_FLAGS}
CC ?= cc

# -----

ifeq ($(OSTYPE),Darwin)
SHARED_FLAGS = $(shell $(TOP)/platform.sh c++_shared_flags)
ifeq ($(MACHTYPE),arm64)
ARCH_FLAGS = -arch arm64
else
ARCH_FLAGS = -arch x86_64
endif
endif

# We use CC to compile this
%.o: %.c
	$(CC) $(CFLAGS) $(ARCH_FLAGS) -c $<

ifeq ($(OSTYPE),Darwin)
libhtcl.dylib: haskell.o
	$(CC) $(SHARED_FLAGS) $(ARCH_FLAGS) -o $@ $< ${TCL_LIB_FLAGS}
else
libhtcl.a: haskell.o
	$(AR) -r $@ $(filter %.o, $+)
endif

.PHONY: install
install: libhtcl.a libhtcl.dylib

.PHONY: clean full_clean
clean full_clean:
	$(RM) -rf *.o *.a *.dylib TAGS

# -----
