####################
# user paramaeters #
####################
# should we show commands executed ?
DO_MKDBG?=0
# should we depend on the date of the makefile itself ?
DO_MAKEDEPS?=1
# do you want debugging enabled?
DO_DEBUG?=0
# target folder
TARGET_DIR?=/usr

#######################
# non user parameters #
#######################
# basic flags to use
BASE_FLAGS:=-O2 -fpic -Wall -Werror
# where to install the shared library?
TARGET_LIB:=$(TARGET_DIR)/lib
# where to install the header files?
TARGET_INC:=$(TARGET_DIR)/include
# name of the library to create
LIBNAME:=except
# folder where the sources are
DIR:=lib
# our include files
INC:=lib/except.h
# compiler to use...
CC:=gcc

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

# the library we create
LIB:=lib$(LIBNAME).so
SRC:=$(shell find $(DIR) -type f -and -name "*.c")
OBJ:=$(addsuffix .o,$(basename $(SRC)))
CFLAGS:=$(BASE_FLAGS) -I$(DIR) -Itest
LDFLAGS:=-shared -fpic
LIBS:=-ldl
ALL_DEPS:=Makefile
TEST_DIR:=test
TEST_SRC:=$(shell find $(TEST_DIR) -type f -and -name "*.c")
TEST_OBJ:=$(addsuffix .o,$(basename $(TEST_SRC)))
TEST_BIN:=$(addsuffix .exe,$(basename $(TEST_SRC)))
LD_OURLIB:=-L. -l$(LIBNAME)
LD_NEEDED:=-lpthread
LD_WITHOURLIB:=$(LD_NEEDED) -L. -l$(LIBNAME)
LD_WITHOUTOURLIB:=$(LD_NEEDED)

.PHONY: all
all: $(LIB) $(TEST_BIN) $(ALL_DEPS)

# binaries and libraries

$(LIB): $(OBJ) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)

# special targets

.PHONY: debug
debug: $(ALL_DEPS)
	$(info DIR is $(DIR))
	$(info SRC is $(SRC))
	$(info OBJ is $(OBJ))
	$(info LIB is $(LIB))
	$(info TEST_DIR is $(TEST_DIR))
	$(info TEST_SRC is $(TEST_SRC))
	$(info TEST_OBJ is $(TEST_OBJ))
	$(info TEST_BIN is $(TEST_BIN))
	$(info INC is $(INC))
	$(info TARGET_LIB is $(TARGET_LIB))
	$(info TARGET_INC is $(TARGET_INC))

.PHONY: clean
clean: $(ALL_DEPS)
	$(info doing [$@])
	$(Q)rm -f $(OBJ) $(LIB) $(BIN)

.PHONY: install
install: $(LIB) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)sudo install -m 755 $(LIB) $(TARGET_LIB)
	$(Q)sudo install -m 644 $(INC) $(TARGET_INC)
	$(Q)sudo ldconfig -n $(TARGET_LIB)

# rules

$(OBJ): %.o: %.c $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) -c $(CFLAGS) -o $@ $<
test/test_link.exe: test/test_link.c $(LIB) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) $(CFLAGS) -o $@ $< $(LD_WITHOURLIB)
test/test_nolink.exe: test/test_nolink.c $(LIB) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) $(CFLAGS) -o $@ $< $(LD_WITHOUTOURLIB)
