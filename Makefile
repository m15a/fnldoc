LUA ?= lua
FENNEL ?= fennel

FENNEL_PATHS := src
FENNEL_MACRO_PATHS := src
FENNEL_FLAGS :=
ifndef FENNEL_PATH
FENNEL_FLAGS +=\
	$(foreach path,$(FENNEL_PATHS),\
		--add-fennel-path $(path)/?.fnl\
		--add-fennel-path $(path)/?/init.fnl)
endif
ifndef FENNEL_MACRO_PATH
FENNEL_FLAGS +=\
	$(foreach path,$(FENNEL_MACRO_PATHS),\
		--add-macro-path $(path)/?.fnl\
		--add-macro-path $(path)/?/init-macros.fnl)
endif
FENNEL_BUILD_FLAGS = --no-metadata --globals '*' --require-as-include --compile

SRCS = $(wildcard src/*.fnl src/**/*.fnl)
MAIN_SRC := src/fnldoc.fnl
EXECUTABLE := fnldoc
VERSION ?= $(shell $(FENNEL) $(FENNEL_FLAGS) -e '(. (require :fnldoc) :version)')

DESTDIR ?=
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
DOCDIR ?= doc

.PHONY: build
build: $(EXECUTABLE)

$(EXECUTABLE): $(SRCS)
	echo '#!/usr/bin/env $(LUA)' > $@
	echo 'FNLDOC_EXECUTABLE = true' >> $@
	$(FENNEL) $(FENNEL_FLAGS) $(FENNEL_BUILD_FLAGS) $(MAIN_SRC) >> $@
	chmod +x $@
	$(LUA) $@ --config --project-version $(VERSION)

.PHONY: install
install: $(EXECUTABLE)
	install -pm755 -Dt $(DESTDIR)$(BINDIR) $<
	ln -s $< $(DESTDIR)$(BINDIR)/fenneldoc

.PHONY: clean
clean:
	rm -f $(EXECUTABLE)

.PHONY: test
test:
	@$(FENNEL) $(FENNEL_FLAGS) test/init.fnl

.PHONY: doc
doc: $(EXECUTABLE)
	rm -rf $(DOCDIR)
	$(LUA) $< --no-sandbox --out-dir $(DOCDIR) $(SRCS)

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
	@echo >&2 "make test         -- Run tests."
	@echo >&2 "make doc          -- Generate documentation for fnldoc."
	@echo >&2 "make format       -- Format source files."
	@echo >&2 "make check-format -- Check if source files are formatted."
	@echo >&2 "make lint         -- Lint source files using fennel-ls."
	@echo >&2 "make help         -- Print this message and exit."
