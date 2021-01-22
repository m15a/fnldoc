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

(local process-config (require :config))
(local process-args (require :args))
(local test-module (require :doctest))
(local write-doc (require :writer))
(local {: module-info} (require :parser))
(local {: gen-markdown} (require :markdown))

(fn process-file [file config]
  "Accepts `file` as path to some Fennel module, and `config` table.
Generates module documentation and writes it to `file` with `.md`
extension, creating it if not exists."
  (when (and config.skip-check config.check-only)
    (io.stderr:write "options skip-check and chec-only can't be used together\n")
    (os.exit 1))
  (match (module-info file config)
    module (do (when (not config.skip-check)
                 (test-module module))
               (let [markdown (gen-markdown module config)]
                 (when (not config.check-only)
                   (write-doc markdown file module config))))
    _ (io.stderr:write "skipping " file "\n")))

(let [(files config) (-> fenneldoc._VERSION
                         process-config
                         process-args)]
  (each [_ file (ipairs files)]
    (process-file file config)))

fenneldoc
