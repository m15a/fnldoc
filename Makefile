LUA ?= lua
FENNEL ?= fennel
FNLSOURCES = fenneldoc.fnl
LUASOURCES = $(FNLSOURCES:.fnl=.lua)

.PHONY: build clean help

build: fenneldoc

fenneldoc: fenneldoc.lua
	echo "#!/usr/bin/env $(LUA)" > $@
	cat fenneldoc.lua >> fenneldoc
	chmod 755 $@

fenneldoc.lua: $(FNLSOURCES)
	$(FENNEL) --no-metadata --require-as-include --compile $< > $@

clean:
	rm -f $(LUASOURCES)

help:
	@echo "make                -- create executable lua script" >&2
	@echo "make clean          -- remove lua files" >&2
	@echo "make help           -- print this message and exit" >&2
