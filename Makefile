LUA ?= lua
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
FENNEL ?= fennel
FNLPATHS = src
FNLSOURCES = $(wildcard src/*.fnl)
FNLARGS = $(foreach path,$(FNLPATHS),--add-fennel-path $(path)/?.fnl)
FNLARGS += --no-metadata --globals "*" --require-as-include --compile
VERSION ?= $(shell git describe --abbrev=0 || "unknown")

.PHONY: build clean help install doc format check-format

build: fenneldoc

fenneldoc: $(FNLSOURCES)
	echo '#!/usr/bin/env $(LUA)' > $@
	echo 'FENNELDOC_VERSION = [[$(VERSION)]]' >> $@
	$(FENNEL) $(FNLARGS) --add-package-path ./?.lua src/fenneldoc.fnl >> $@
	chmod 755 $@
	./fenneldoc --config --project-version $(VERSION)

install: fenneldoc
	mkdir -p $(BINDIR) && cp fenneldoc $(BINDIR)/

clean:
	rm -f fenneldoc $(wildcard src/*.lua)

doc: fenneldoc
	./fenneldoc --no-sandbox $(FNLSOURCES)

format:
	fnlfmt --fix src/*.fnl

check-format:
	fnlfmt --check src/*.fnl

help:
	@echo "make               -- create executable lua script" >&2
	@echo "make clean         -- remove lua files" >&2
	@echo "make doc           -- generate documentation files for fenneldoc" >&2
	@echo "make format        -- format source files" >&2
	@echo "make check-format  -- check if source files are formatted" >&2
	@echo "make install       -- install fenneldoc accordingly to \$$PREFIX" >&2
	@echo "make help          -- print this message and exit" >&2
