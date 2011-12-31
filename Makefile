###############
# paramaeters #
###############
# should we show commands executed ?
DO_MKDBG?=0
# should we depend on the date of the makefile itself ?
DO_MAKEDEPS?=1
# folder where the sources are...
DIR:=lib
# name of the library to create
LIBNAME:=except
# compiler to use...
CC:=gcc
# basic flags to use
BASE_FLAGS:=-O2 -fpic -Wall -Werror
# do you want debugging enabled?
DO_DEBUG?=0
# where to install the shared library?
TARGET_DIR?=/usr/lib

########
# BODY #
########
ifeq ($(DO_MKDBG),1)
Q=
# we are not silent in this branch
else # DO_MKDBG
Q=@
#.SILENT:
endif # DO_MKDBG

ifeq ($(DO_DEBUG),1)
BASE_FLAGS:=$(BASE_FLAGS) -g2
endif # DO_DEBUG

ALL_DEP:=
ifeq ($(DO_MAKEDEPS),1)
	ALL_DEP:=$(ALL_DEP) Makefile
endif

LIB:=lib$(LIBNAME).so
SRC:=$(shell find $(DIR) -type f -and -name "*.c")
OBJ:=$(addsuffix .o,$(basename $(SRC)))
CFLAGS:=$(BASE_FLAGS) -I$(DIR) -Itest
LDFLAGS:=-shared -fpic
LIBS:=-ldl
ALL_DEPS:=Makefile
BIN:=test/test
BINLD:=-lpthread -L. -l$(LIBNAME)

.PHONY: all
all: $(LIB) $(BIN) $(ALL_DEPS)

# binaries and libraries

$(LIB): $(OBJ) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)

# special targets

.PHONY: debug
debug: $(ALL_DEPS)
	$(info SRC is $(SRC))
	$(info OBJ is $(OBJ))
	$(info LIB is $(LIB))
	$(info BIN is $(BIN))

.PHONY: clean
clean: $(ALL_DEPS)
	$(info doing [$@])
	$(Q)rm -f $(OBJ) $(LIB) $(BIN)

.PHONY: run
run: $(BIN) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)export LD_LIBRARY_PATH=. ; ./test/logging_speed

.PHONY: run_debug
run_debug: $(BIN) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)export LD_LIBRARY_PATH=. ; gdb ./test/logging_speed

.PHONY: install
install: $(LIB) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)sudo install -m 755 $(LIB) $(TARGET_DIR)
	$(Q)sudo ldconfig -n $(TARGET_DIR)

# rules

$(OBJ): %.o: %.c $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) -c $(CFLAGS) -o $@ $<
$(BIN): %: %.c $(LIB) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) $(CFLAGS) -o $@ $< $(BINLD)
