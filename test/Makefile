# Part of xchange
#
# Builds and runs regression tests, measures test coverage
#
# Author: Attila Kovacs

include ../config.mk

# Flags for measuring test coverage
# Our own include directory
CPPFLAGS += -I../include
CFLAGS += -I../include -pg -Wall
LDFLAGS += -lm -fprofile-arcs -ftest-coverage

# cppcheck options for 'check' target. You can add additional options by
# setting the CHECKEXTRA variable (e.g. in shell) prior to invoking 'make'.
CHECKOPTS = --enable=performance,warning,portability --language=c \
            --error-exitcode=1 --std=c99 --inline-suppr $(CHECKEXTRA)

SOURCES := $(wildcard ../src/*.c)
OBJECTS := $(subst .c,.o,$(subst ../src/,,$(SOURCES)))
COVFILES := $(subst .c,.c.gcov,$(SOURCES))

TESTS := test-parse test-struct test-lookup test-json

# Run tests
.PHONY: run
run: clean-cov clean-data $(TESTS)
	./test-parse
	./test-struct
	./test-lookup
	./test-json

.PHONY: coverage
coverage:
	$(MAKE) cov

cov: lcov.info
	genhtml $< -o $@

lcov.info:
	geninfo . -o $@
	lcov --remove $@ $(EXCLUDE_COV) -o $@

.PRECIOUS: %.c.gcov
%.c.gcov: %.gcno %.gcda
	gcov -b $*

.PRECIOUS: %.gcno %.gcda
%.gcno %.gcda: src/%.c
	$(MAKE) clean
	$(MAKE) run

test-%: test-%.o $(OBJECTS) | Makefile
	@echo sources: $(SOURCES)
	@echo objects: $(OBJECTS)
	$(CC) -o $@ $^ $(LDFLAGS)

test-%.o: test-%.c | Makefile
	$(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) $<

%.o: %.c | Makefile
	$(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) -fprofile-arcs -ftest-coverage $<

# Static code analysis using 'cppcheck'
.PHONY: analyze
analyze:
	@echo "   [analyze]"
	@cppcheck $(CPPFLAGS) $(CHECKOPTS) $(SRC)

.PHONY: clean-test
clean-test:
	@rm -f $(TESTS)

.PHONY: clean-cov
clean-cov:
	@rm -rf gmon.out *.gcov *.gcda *.gcno cov cov.info

.PHONY: clean-data
clean-data:
	@rm -rf data

.PHONY: clean
clean: clean-test clean-cov
	@rm -f *.o

.PHONY: distclean
distclean: clean clean-data
	@rm -f lcov.info
	@rm -rf cov

.PHONY: help
help:
	@echo
	@echo "Syntax: make [target]"
	@echo
	@echo "The following targets are available:"
	@echo
	@echo "  run           (default) Compiles and runs regression tests."
	@echo "  coverage      Extracts test coverage data."
	@echo "  analyze       Static analysis with cppcheck."
	@echo "  clean         Removes intermediate products."
	@echo "  distclean     Deletes all generated files."
	@echo

vpath %.c ../src

