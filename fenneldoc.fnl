(local fenneldoc {:_VERSION "0.0.1"
                  :_DESCRIPTION "Fenneldoc - generate documentation for Fennel projects."
                  :_COPYRIGHT "Copyright (C) 2020 Andrey Orst"})

(local fennel (require :fennel))
(local utils (require :fennel.utils))
(local fs (require :lfs))

(local files [])
(local config {:insert-comment true
               :insert-version true
               :version-key :_VERSION
               :description-key :_DESCRIPTION
               :function-signatures true
               :silent false
               :toc true})


(fn process-config []
  (match (pcall fennel.dofile :.fenneldoc)
    (true rc) (each [k v (pairs rc)]
                (tset config k v))
    (false msg) (when (not (msg:match ".fenneldoc: No such file or directory"))
                  (io.stderr:write (.. msg "\n")))))


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

(fn process-args []
  "Process command line arguments"
  (var (i v) (next arg))
  (while (and i (> i 0))
    (match v
      :--version-key (do (set (i v) (next arg i))
                         (if i (set config.version-key v)
                             (error "expected value for --version-key")))
      :--description-key (do (set (i v) (next arg i))
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
    (set (i v) (next arg i)))
  ;; clean args (for generating documentation for fenneldoc itself)
  (each [i _ (pairs arg)]
    (tset arg i nil)))


(fn capitalize [str]
  (.. (string.upper (string.sub str 1 1))
      (string.sub str 2 -1)))

(fn require-module [file]
  "Require file as module in protected call.  Returns vector with first value
corresponding to pcall result."
  (let [(module? mod) (pcall fennel.dofile file {:useMetadata true})]
    [module? mod]))


(fn process-file [file]
  (let [[module? module] (require-module file)]
    (if (not module?) (io.stderr:write (.. "Error loading file " file "\n" module))
        (let [result {:module (-> file
                                  (string.gsub ".*/" "")
                                  (capitalize))
                      :docs {}}
              docs result.docs]
          (match (. module config.description-key)
            descr (tset result :description descr))
          (match (. module config.version-key)
            version (tset result :version version))
          (each [id val (pairs module)]
            (when (and (not= (string.sub id 1 1) :_)
                       (not= id config.version-key))
              (tset docs id {:docs (fennel.metadata:get val :fnl/docstring)
                             :args (fennel.metadata:get val :fnl/arglist)})))
          result))))

(fn table.append [t pos val]
  (if val
      (doto t (table.insert pos val))
      (doto t (table.insert pos))))


(fn add-info-comment [lines]
  (when config.insert-comment
    (lines:append "")
    (lines:append (.. "<!-- Generated with Fenneldoc " fenneldoc._VERSION))
    (lines:append (.. "     https://gitlab.com/andreyorst/fenneldoc -->")))
  lines)


(fn add-function-signature [lines item args]
  (when (and config.function-signatures args)
    (lines:append "Function signature:")
    (lines:append "")
    (lines:append "```")
    (lines:append (.. "(" item " " (table.concat args " ") ")"))
    (lines:append "```")
    (lines:append ""))
  lines)


(fn add-toc [lines contents]
  (when (and config.toc contents (next contents))
    (lines:append "**Table of contents**")
    (each [item _ (utils.stablepairs contents)]
      (lines:append (.. "- [`" item "`](#" item ")")))
    (lines:append "")))


(fn add-item-documentation [lines item docs]
  (lines:append (if docs (pick-values 1 (docs:gsub "\n#" "\n###"))
                    "**Undocumented**"))
  (lines:append ""))


(fn gen-markdown [module-info]
  (let [lines (setmetatable [(.. "# " module-info.module (match module-info.version
                                                           version (.. " (" version ")")
                                                           _ ""))]
                            {:__index table})]
    (-?>> module-info.description lines:append)

    (-> (lines:append "")
        (add-toc module-info.docs))

    (each [item {: docs : args} (utils.stablepairs module-info.docs)]
      (-> (lines:append (.. "## `" item "`"))
          (add-function-signature item args)
          (add-item-documentation item docs)))
    (add-info-comment lines)))


(fn string.split [s seps]
  (let [seps (or seps "%s")
        res []]
    (each [s _ (s:gmatch (.. "[^" seps "]+"))]
      (table.insert res s))
    res))


(fn create-file-and-dirs [file]
  (let [path (file:gsub "[^\\/]+.fnl$" "")
        fname (-> file
                  (string.gsub path "")
                  (string.gsub ".fnl$" ".md"))
        dirs (-> (string.split path "\\/")
                 (table.append 1 "doc"))
        olddir (fs.currentdir)]
    (each [_ dir (ipairs dirs)]
      (when (not= dir :src)
        (fs.mkdir dir)
        (fs.chdir dir)))
    (fs.chdir olddir)
    (.. (table.concat dirs "/") "/" fname)))


(fn write-doc [docs file]
  (with-open [file (io.open file :w)]
    (file:write (table.concat docs "\n"))))


(fn main []
  (process-config)
  (process-args)
  (each [_ file (ipairs files)]
    (let [processed (process-file file)
          markdown (gen-markdown processed)]
      (write-doc markdown (create-file-and-dirs file)))))

(main)

(setmetatable fenneldoc {:__call main})
