LUA ?= lua
FENNEL ?= fennel
FNLPATHS = src cljlib
FNLSOURCES = $(wildcard src/*.fnl)
LUASOURCES = $(FNLSOURCES:.fnl=.lua)

.PHONY: build clean help

build: fenneldoc

fenneldoc: $(LUASOURCES)
	echo "#!/usr/bin/env $(LUA)" > $@
	cat src/fenneldoc.lua >> fenneldoc
	chmod 755 $@

${LUASOURCES}: $(FNLSOURCES)

%.lua: %.fnl
	$(FENNEL) $(foreach path,$(FNLPATHS),--add-fennel-path $(path)/?.fnl) --no-metadata --require-as-include --compile $< > $@

clean:
	rm -f fenneldoc $(wildcard src/*.lua)

docs: fenneldoc
	fenneldoc $(FNLSOURCES)

help:
	@echo "make       -- create executable lua script" >&2
	@echo "make clean -- remove lua files" >&2
	@echo "make help  -- print this message and exit" >&2

-include .depend.mk
