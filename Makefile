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
FENNEL_BUILD_FLAGS = --no-metadata --require-as-include --compile
FENNEL_TEST_FLAGS = --no-compiler-sandbox

SRCS = $(shell find src -name '*.fnl')
MAIN_SRC := src/fnldoc.fnl
TESTS = $(shell find test -name '*.fnl' ! -name 'faith.fnl')
EXECUTABLE := fnldoc
CONFIG_FILE := .fenneldoc
VERSION ?= $(shell $(FENNEL) $(FENNEL_FLAGS) -e '(. (require :fnldoc) :version)')

DESTDIR ?=
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
DOCDIR ?= doc

.PHONY: build
build: $(EXECUTABLE) $(CONFIG_FILE)

$(EXECUTABLE): $(SRCS)
	echo '#!/usr/bin/env $(LUA)' > $@
	$(FENNEL) $(FENNEL_FLAGS) $(FENNEL_BUILD_FLAGS) $(MAIN_SRC) >> $@
	sed -Ei $@ \
		-e 's|(local fnldoc_version = ")[^"]+|\1$(VERSION)|' \
		-e '$$d'
	echo 'main()' >> $@
	chmod +x $@

$(CONFIG_FILE): $(EXECUTABLE)
	$(LUA) $< --config --project-version $(VERSION)

.PHONY: install
install: $(EXECUTABLE)
	install -pm755 -Dt $(DESTDIR)$(BINDIR) $<
	ln -s $< $(DESTDIR)$(BINDIR)/fenneldoc

.PHONY: clean
clean:
	rm -f $(EXECUTABLE)

.PHONY: test
test: $(SRCS) $(TESTS)
	@$(FENNEL) $(FENNEL_FLAGS) $(FENNEL_TEST_FLAGS) test/init.fnl

.PHONY: doc
doc: $(EXECUTABLE) $(CONFIG_FILE) $(SRCS)
	rm -rf $(DOCDIR)
	$(LUA) $< --no-sandbox --out-dir $(DOCDIR) $(SRCS)

.PHONY: format
format:
	fnlfmt --fix $(SRCS) $(TESTS)

.PHONY: check-format
check-format:
	fnlfmt --check $(SRCS) $(TESTS)

.PHONY: lint
lint:
	fennel-ls --check $(SRCS) $(TESTS)

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
