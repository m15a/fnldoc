(local fenneldoc {:_VERSION "0.0.2"
                  :_DESCRIPTION "Fenneldoc - generate documentation for Fennel projects."
                  :_COPYRIGHT "Copyright (C) 2020 Andrey Orst"})

(local process-file (require :parser))
(local process-config (require :config))

(fn help []
  (print "Usage: fenneldoc [flags] [files]

Create documentation for your project.

Value flags:
  --version-key     _VERSION     : key to use to get the version of the module.
  --description-key _DESCRIPTION : key to use to get the description of the module.

Toggle flags:
  --[no-]silent                  : (don't) report errors
  --[no-]function-signatures     : (don't) generate function signatures in documentation.
  --[no-]final-comment           : (don't) insert final comment with fenneldoc version
  --[no-]toc                     : (don't) generate table of contents

  --help                         : print this message and exit

All keys have higher precedence than configuration file, therefore
values passed with keys will override folowing values in
docjmentation.

Each toggle key has two variants with and without `no'.  For example,
passing `--no-toc' will disable generation of contents table, and
`--toc` will anable it.")
  (os.exit 0))


(fn process-args [config]
  "Process command line arguments"
  (let [files []]
    (var (i v) (next arg))
    (while (and i (> i 0))
      (match v
        :--version-key (do (tset arg i nil)
                           (set (i v) (next arg i))
                           (if i (set config.version-key v)
                               (error "expected value for --version-key")))
        :--description-key (do (tset arg i nil)
                               (set (i v) (next arg i))
                               (if i (set config.description-key v)
                                   (error "expected value for --description-key")))
        :--silent    (set default-config.silent true)
        :--no-silent (set default-config.silent false)
        :--function-signatures    (set config.function-signatures true)
        :--no-function-signatures (set config.function-signatures false)
        :--final-comment    (set config.insert-comment true)
        :--no-final-comment (set config.insert-comment false)
        :--toc    (set config.toc true)
        :--no-toc (set config.toc false)
        :--help (help)
        _ (table.insert files v))
      (tset arg i nil)
      (set (i v) (next arg i)))
    (tset config :fenneldoc-version fenneldoc._VERSION)
    (values files config)))


(let [(files config) (process-args (process-config))]
  (each [_ file (ipairs files)]
    (process-file file config)))

fenneldoc
