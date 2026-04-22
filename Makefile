# ===============================================================================
# WARNING! You should leave this Makefile alone probably
#          To configure the build, you can edit config.mk, or else you export the 
#          equivalent shell variables prior to invoking 'make' to adjust the
#          build configuration. 
# ===============================================================================

include config.mk

# ===============================================================================
# Specific build targets and recipes below...
# ===============================================================================

# The version of the shared .so libraries
SO_VERSION := 1

# Link with math libs (NAN) and pthread (mutex)
LDFLAGS += -lm -lpthread

# Check if there is a doxygen we can run
ifndef DOXYGEN
  DOXYGEN := $(shell which doxygen)
else
  $(shell test -f $(DOXYGEN))
endif

# If there is doxygen, build the API documentation also by default
ifeq ($(.SHELLSTATUS),0)
  DOC_TARGETS += dox
else
  ifneq ($(DOXYGEN),none)
    $(info WARNING! Doxygen is not available. Will skip 'dox' target) 
  endif
endif

INSTALL_TARGETS := install-headers

export

# Build for distribution
.PHONY: distro
distro: $(LIBXCHANGE) $(DOC_TARGETS)

# Shared libraries (versioned and unversioned)
.PHONY: shared
shared: $(LIB)/libxchange.so

# Legacy static libraries (locally built)
.PHONY: static
static: $(LIB)/libxchange.a

# Build everything...
.PHONY: all
all: $(LIBXCHANGE) $(DOC_TARGETS) check

# Run regression tests
.PHONY: test
test:
	$(MAKE) -C test run

.PHONY: coverage
coverage:
	$(MAKE) -C test coverage

# Buld example programs
.PHONY: examples
examples: shared
	$(MAKE) -C examples

# Build HTML documentation
.PHONY: dox
dox: 
	$(MAKE) -C doc

# 'test" + 'analyze'
.PHONY: check
check: 
	$(MAKE) -C test analyze

# Static code analysis via Facebook's infer
.PHONY: infer
infer: clean
	infer run -- $(MAKE) $(LIBXCHANGE)

# Remove intermediates
.PHONY: clean
clean:
	@rm -f $(OBJECTS) README-xchange.md gmon.out
	@$(MAKE) -s -C test clean
	@$(MAKE) -s -C examples clean
	@$(MAKE) -s -C doc clean 

# Remove all generated files
.PHONY: distclean
distclean: clean
	@rm -f $(LIB)/libxchange.so* $(LIB)/libxchange.a
	@rm -rf build
	@$(MAKE) -s -C test distclean
	@$(MAKE) -s -C examples distclean
	@$(MAKE) -s -C doc distclean 

# Test programs
.PHONY: tests
tests: 
	$(MAKE) -C test

# ----------------------------------------------------------------------------
# The nitty-gritty stuff below
# ----------------------------------------------------------------------------

SOURCES = $(SRC)/xchange.c $(SRC)/xstruct.c $(SRC)/xlookup.c $(SRC)/xjson.c

# Generate a list of object (obj/*.o) files from the input sources
OBJECTS := $(subst .c,.o,$(subst $(SRC),$(OBJ),$(SOURCES)))

$(LIB)/libxchange.so: $(LIB)/libxchange.so.$(SO_VERSION)

# Shared library
$(LIB)/libxchange.so.$(SO_VERSION): $(SOURCES)

# Static library
$(LIB)/libxchange.a: $(OBJECTS)


# Some standard GNU targets, that should always exist...
.PHONY: html
html: dox

.PHONY: dvi
dvi:

.PHONY: ps
ps:

.PHONY: pdf
pdf:

# The package name to use for installation paths
PACKAGE_NAME ?= xchange

# Default values for install locations
# See https://www.gnu.org/prep/standards/html_node/Directory-Variables.html 
prefix ?= /usr
exec_prefix ?= $(prefix)
libdir ?= $(exec_prefix)/lib
includedir ?= $(prefix)/include
datarootdir ?= $(prefix)/share
datadir ?= $(datarootdir)
mydatadir ?= $(datadir)/$(PACKAGE_NAME)
docdir ?= $(datarootdir)/doc/$(PACKAGE_NAME)
htmldir ?= $(docdir)/html

# Standard install commands
INSTALL_PROGRAM ?= install
INSTALL_DATA ?= install -m 644

.PHONY: install
install: install-libs install-headers install-html

.PHONY: install-libs
install-libs:
ifneq ($(wildcard $(LIB)/*),)
	@echo "installing libraries to $(DESTDIR)$(libdir)"
	install -d $(DESTDIR)$(libdir)
	cp -a $(LIB)/* $(DESTDIR)$(libdir)/
else
	@echo "WARNING! Skipping libs install: needs 'shared' and/or 'static'"
endif

.PHONY: install-headers
install-headers:
	@echo "installing headers to $(DESTDIR)$(includedir)"
	install -d $(DESTDIR)$(includedir)
	$(INSTALL_DATA) -D include/* $(DESTDIR)$(includedir)/

.PHONY: install-html
install-html:
ifneq ($(wildcard doc/html/search/*),)
	@echo "installing API documentation to $(DESTDIR)$(htmldir)"
	install -d $(DESTDIR)$(htmldir)/search
	$(INSTALL_DATA) -D doc/html/search/* $(DESTDIR)$(htmldir)/search/
	$(INSTALL_DATA) -D doc/html/*.* $(DESTDIR)$(htmldir)/
	@echo "installing Doxygen tag file to $(DESTDIR)$(docdir)"
	install -d $(DESTDIR)$(docdir)
	$(INSTALL_DATA) -D doc/*.tag $(DESTDIR)$(docdir)/
else
	@echo "WARNING! Skipping apidoc install: needs doxygen and 'dox'"
endif


# Built-in help screen for `make help`
.PHONY: help
help:
	@echo
	@echo "Syntax: make [target]"
	@echo
	@echo "The following targets are available:"
	@echo
	@echo "  shared        Builds the shared 'libxchange.so' (linked to versioned)."
	@echo "  static        Builds the static 'libxchange.a' library."
	@echo "  dox           Compiles local HTML API documentation using 'doxygen'."
	@echo "  analyze       Performs static analysis with 'cppcheck'."
	@echo "  all           All of the above."
	@echo "  distro        shared libs and documentation (default target)."
	@echo "  install       Install components (e.g. 'make prefix=<path> install')."
	@echo "  clean         Removes intermediate products."
	@echo "  distclean     Deletes all generated files."
	@echo

# This Makefile depends on the config and build snipplets.
Makefile: config.mk build.mk

# ===============================================================================
# Generic targets and recipes below...
# ===============================================================================

include build.mk

vpath %.c test
