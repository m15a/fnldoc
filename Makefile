LUA ?= lua
FENNEL ?= fennel
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
	$(FENNEL) --add-fennel-path src/?.fnl --no-metadata --require-as-include --compile $< > $@

clean:
	rm -f $(LUASOURCES) fenneldoc

help:
	@echo "make                -- create executable lua script" >&2
	@echo "make clean          -- remove lua files" >&2
	@echo "make help           -- print this message and exit" >&2

-include .depend.mk
