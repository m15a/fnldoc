fenneldoc: src/fenneldoc.lua
src/args.lua: src/args.fnl cljlib/macros.fnl cljlib/init.fnl
src/config.lua: src/config.fnl cljlib/macros.fnl
src/doctest.lua: src/doctest.fnl src/parser.lua cljlib/macros.fnl cljlib/init.fnl
src/fenneldoc.lua: src/fenneldoc.fnl src/config.lua src/args.lua src/doctest.lua  src/writer.lua src/parser.lua src/markdown.lua cljlib/macros.fnl
src/markdown.lua: src/markdown.fnl cljlib/macros.fnl cljlib/init.fnl
src/parser.lua: src/parser.fnl src/markdown.lua cljlib/macros.fnl cljlib/init.fnl
src/writer.lua: src/writer.fnl cljlib/macros.fnl
