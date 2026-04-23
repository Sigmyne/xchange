# ===========================================================================
# Generic configuration options for building the xchange library (both static 
# and shared).
#
# You can include this snipplet in your Makefile also.
# ============================================================================

# Folders for compiled objects, libraries, and binaries, respectively 
OBJ ?= obj
BIN ?= bin

# Compiler: use gcc by default
CC ?= gcc

# Base compiler options (if not defined externally...)
CFLAGS ?= -g -Os -Wall

# Compile for specific C standard
ifdef CSTANDARD
  CFLAGS += -std=$(CSTANDARD)
endif

# Extra warnings (not supported on all compilers)
ifeq ($(WEXTRA), 1) 
  CFLAGS += -Wextra
endif

# Add source code fortification checks
ifdef FORTIFY 
  CFLAGS += -D_FORTIFY_SOURCE=$(FORTIFY)
endif

# Extra linker flags to use
#LDFLAGS =

# cppcheck options for 'check' target
CHECKOPTS ?= --enable=performance,warning,portability,style --language=c \
            --error-exitcode=1 --inline-suppr --std=c99 $(CHECKEXTRA)

# Exhaustive checking for newer cppcheck
#CHECKOPTS += --check-level=exhaustive

# Specific Doxygen to use if not the default one
#DOXYGEN ?= /opt/bin/doxygen

# ============================================================================
# END of user config section. 
#
# Below are some generated constants based on the one that were set above
# ============================================================================


# Build static or shared libs
ifeq ($(STATICLINK),1)
  LIBXCHANGE = $(LIB)/libxchange.a
else
  LIBXCHANGE = $(LIB)/libxchange.so
endif

# By default determine the build platform (OS type)
PLATFORM ?= $(shell uname -s)

# Platform-specific configurations
ifeq ($(PLATFORM),Darwin)
  # macOS specific
  SOEXT := dylib
  SHARED_FLAGS := -dynamiclib -fPIC
  SONAME_FLAG := -Wl,-install_name,@rpath/
  LIB_PATH_VAR := DYLD_LIBRARY_PATH
else
  # Linux/Unix specific
  SOEXT := so
  SHARED_FLAGS := -shared -fPIC
  SONAME_FLAG := -Wl,-soname,
  LIB_PATH_VAR := LD_LIBRARY_PATH
endif


# Search for files in the designated locations
vpath %.h $(INC)
vpath %.c $(SRC)
vpath %.o $(OBJ)
vpath %.d dep 

