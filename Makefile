LUA ?= lua
FENNEL ?= fennel

FENNEL_PATHS := src
FENNEL_MACRO_PATHS := src
FENNEL_FLAGS = --no-metadata --globals '*' --require-as-include --compile
FENNEL_FLAGS +=\
	$(foreach path,$(FENNEL_PATHS),\
		--add-fennel-path $(path)/?.fnl\
		--add-fennel-path $(path)/?/init.fnl)
FENNEL_FLAGS +=\
	$(foreach path,$(FENNEL_MACRO_PATHS),\
		--add-macro-path $(path)/?.fnl\
		--add-macro-path $(path)/?/init-macros.fnl)

SRCS = $(wildcard src/*.fnl)
MAIN_SRC := src/fenneldoc.fnl
EXECUTABLE := fenneldoc
VERSION ?= $(shell git describe --abbrev=0 || "unknown")

DESTDIR ?=
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin

.PHONY: build
build: $(EXECUTABLE)

$(EXECUTABLE): $(SRCS)
	echo '#!/usr/bin/env $(LUA)' > $@
	echo 'FENNELDOC_VERSION = [[$(VERSION)]]' >> $@
	$(FENNEL) $(FENNEL_FLAGS) $(MAIN_SRC) >> $@
	chmod 755 $@
	$(LUA) $@ --config --project-version $(VERSION)

.PHONY: install
install: $(EXECUTABLE)
	install -D -t $(DESTDIR)$(BINDIR) $<

.PHONY: clean
clean:
	rm -f $(EXECUTABLE)

.PHONY: doc
doc: $(EXECUTABLE)
	$(LUA) $< --no-sandbox $(SRCS)

.PHONY: format
format:
	fnlfmt --fix $(SRCS)

.PHONY: check-format
check-format:
	fnlfmt --check $(SRCS)

.PHONY: lint
lint:
	fennel-ls --check $(SRCS)

.PHONY: help
help:
	@echo >&2 "make              -- Run make build."
	@echo >&2 "make build        -- Build Lua executable."
	@echo >&2 "make install      -- Install executable to \$$DESTDIR\$$PREFIX/bin"
	@echo >&2 "make clean        -- Clean up built files."
	@echo >&2 "make doc          -- Generate documentation for fenneldoc."
	@echo >&2 "make format       -- Format source files."
	@echo >&2 "make check-format -- Check if source files are formatted."
	@echo >&2 "make lint         -- Lint source files using fennel-ls."
	@echo >&2 "make help         -- Print this message and exit."
