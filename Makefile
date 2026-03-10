# Makefile - Install dbh
# BCS1212 compliant

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man/man1
COMPDIR ?= /etc/bash_completion.d
DESTDIR ?=

.PHONY: all install uninstall check test help

all: help

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 dbh $(DESTDIR)$(BINDIR)/dbh
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 dbh.1 $(DESTDIR)$(MANDIR)/dbh.1
	@if [ -d $(DESTDIR)$(COMPDIR) ]; then \
	  install -m 644 dbh.bash_completion $(DESTDIR)$(COMPDIR)/dbh; \
	fi
	@if [ -z "$(DESTDIR)" ]; then $(MAKE) --no-print-directory check; fi

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/dbh
	rm -f $(DESTDIR)$(MANDIR)/dbh.1
	rm -f $(DESTDIR)$(COMPDIR)/dbh

check:
	@command -v dbh >/dev/null 2>&1 \
	  && echo 'dbh: OK' \
	  || echo 'dbh: NOT FOUND (check PATH)'

test:
	cd tests && ./run_tests.sh

help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@echo '  install     Install to $(PREFIX)'
	@echo '  uninstall   Remove installed files'
	@echo '  check       Verify installation'
	@echo '  test        Run test suite'
	@echo '  help        Show this message'
	@echo ''
	@echo 'Install from GitHub:'
	@echo '  git clone https://github.com/Open-Technology-Foundation/dbh.git'
	@echo '  cd dbh && sudo make install'
