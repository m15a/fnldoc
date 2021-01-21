(local fenneldoc {:_VERSION "0.0.7"
                  :_COPYRIGHT "Copyright (C) 2020 Andrey Orst"
                  :_LICENSE "[MIT](https://gitlab.com/andreyorst/fenneldoc/-/raw/master/LICENSE)"
                  :_DESCRIPTION "Fenneldoc - generate documentation for Fennel projects.

Generates documentation for Fennel libraries by analyzing project
metadata at runtime.

**Documentation for other modules**

- [config.fnl](./config.md) - processes configuration file.
- [parser.fnl](./parser.md) - loads the file and analyzes its metadata providing `module-info`.
- [markdown.fnl](./markdown.md) - generates Markdown from `module-info`."})

(local process-file (require :parser))
(local process-config (require :config))
(local process-args (require :args))

(let [(files config) (-> fenneldoc._VERSION
                         process-config
                         process-args)]
  (each [_ file (ipairs files)]
    (process-file file config)))

fenneldoc
