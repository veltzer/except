####################
# user paramaeters #
####################
# should we show commands executed ?
DO_MKDBG:=0
# should we depend on the date of the makefile itself ?
DO_MAKEDEPS:=1
# do you want debugging enabled?
DO_DEBUG:=0
# target folder
TARGET_DIR:=/usr

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
LIBNAMECC:=exceptcc
# folder where the sources are
DIR:=lib
# our include files
INC:=lib/except.h
# compilers to use...
CC:=gcc
CXX:=g++

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
LIBCC:=lib$(LIBNAMECC).so
SRC:=$(shell find $(DIR) -type f -and -name "*.c")
SRCCC:=$(shell find $(DIR) -type f -and -name "*.cc")
OBJ:=$(addsuffix .o,$(basename $(SRC)))
OBJCC:=$(addsuffix .o,$(basename $(SRCCC)))
CFLAGS:=$(BASE_FLAGS) -I$(DIR) -Itest
CXXFLAGS:=$(BASE_FLAGS) -I$(DIR) -Itest
LDFLAGS:=-shared -fpic
LIBS:=-ldl
ALL_DEPS:=Makefile
TEST_DIR:=test
TEST_SRC:=$(shell find $(TEST_DIR) -type f -and -name "*.c")
TEST_OBJ:=$(addsuffix .o,$(basename $(TEST_SRC)))
TEST_BIN:=$(addsuffix .exe,$(basename $(TEST_SRC)))
TEST_SRCCC:=$(shell find $(TEST_DIR) -type f -and -name "*.cc")
TEST_OBJCC:=$(addsuffix .o,$(basename $(TEST_SRCCC)))
TEST_BINCC:=$(addsuffix .exe,$(basename $(TEST_SRCCC)))
LD_BASE:=-lpthread
LD_LIB:=$(LD_BASE) -L. -l$(LIBNAME)
LD_LIBCC:=$(LD_BASE) -L. -l$(LIBNAMECC)
LD_EMPTY:=$(LD_BASE)

.PHONY: all
all: $(LIB) $(LIBCC) $(TEST_BIN) $(TEST_BINCC) $(ALL_DEPS)

# special targets

.PHONY: debug
debug: $(ALL_DEPS)
	$(info DIR is $(DIR))
	$(info SRC is $(SRC))
	$(info SRCCC is $(SRCCC))
	$(info OBJ is $(OBJ))
	$(info OBJCC is $(OBJCC))
	$(info LIB is $(LIB))
	$(info LIBCC is $(LIBCC))
	$(info TEST_DIR is $(TEST_DIR))
	$(info TEST_SRC is $(TEST_SRC))
	$(info TEST_OBJ is $(TEST_OBJ))
	$(info TEST_BIN is $(TEST_BIN))
	$(info TEST_SRCCC is $(TEST_SRCCC))
	$(info TEST_OBJCC is $(TEST_OBJCC))
	$(info TEST_BINCC is $(TEST_BINCC))
	$(info INC is $(INC))
	$(info TARGET_LIB is $(TARGET_LIB))
	$(info TARGET_INC is $(TARGET_INC))

.PHONY: clean
clean: $(ALL_DEPS)
	$(info doing [$@])
	$(Q)rm -f $(OBJ) $(OBJCC) $(LIB) $(LIBCC) $(TEST_BIN) $(TEST_BINCC) $(TEST_OBJ) $(TEST_OBJCC)

.PHONY: install
install: $(LIB) $(LIBCC) $(LIBCC) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)sudo install -m 755 $(LIB) $(TARGET_LIB)
	$(Q)sudo install -m 755 $(LIBCC) $(TARGET_LIB)
	$(Q)sudo install -m 644 $(INC) $(TARGET_INC)
	$(Q)sudo ldconfig -n $(TARGET_LIB)

# rules

$(LIB): $(OBJ) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)
$(LIBCC): $(OBJ) $(OBJCC) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CXX) $(LDFLAGS) -o $@ $(OBJ) $(OBJCC) $(LIBS)
$(OBJ): %.o: %.c $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) -c $(CFLAGS) -o $@ $<
$(OBJCC): %.o: %.cc $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CXX) -c $(CXXFLAGS) -o $@ $<
test/test_link.exe: test/test_link.c $(LIB) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) $(CFLAGS) -o $@ $< $(LD_LIB)
test/test_linkcc.exe: test/test_linkcc.cc $(LIBCC) $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CXX) $(CXXFLAGS) -o $@ $< $(LD_LIBCC)
test/test_nolink.exe: test/test_nolink.c $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CC) $(CFLAGS) -o $@ $< $(LD_EMPTY)
test/test_nolinkcc.exe: test/test_nolinkcc.cc $(ALL_DEPS)
	$(info doing [$@])
	$(Q)$(CXX) $(CXXFLAGS) -o $@ $< $(LD_EMPTY)
