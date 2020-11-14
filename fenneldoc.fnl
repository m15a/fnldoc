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
               :verbose true})


(fn process-config []
  (match (pcall fennel.dofile :.fenneldoc)
    (true rc) (each [k v (pairs rc)]
                (tset config k v))
    (false msg) (when (not (msg:match ".fenneldoc: No such file or directory"))
                  (io.stderr:write (.. msg "\n")))))


(fn help []
  (print "Usage: fenneldoc [flags] [files]
Create documentation for your project.

  --version-key _VERSION         : What key to use to look for version of the module.
  --description-key _DESCRIPTION : What key to use to look for description of the module.

  --silent                       : Do not report errors
  --no-function-signatures       : Do not generate function signatures in documentation.
  --no-final-comment             : Do not insert final comment with fenneldoc version

  --help                         : print this message and exit")
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
      :--silent (set default-config.verbose false)
      :--no-function-signatures (set config.function-signatures false)
      :--no-final-comment (set config.insert-comment false)
      :--help (help)
      _ (table.insert files v))
    (set (i v) (next arg i)))
  ;; clean args (for generating documentation for fenneldoc itself)
  (each [i _ (pairs arg)]
    (tset arg i nil)))


(fn capitalize [str]
  (.. (string.upper (string.sub str 1 1))
      (string.sub str 2 -1)))


(fn require-module [module]
  "Require module in protected call.  Returns vector with first value
corresponding to pcall result."
  (let [(module? mod) (pcall require module)]
    [module? mod]))


(fn process-file [file]
  (let [[module? module] (-> file
                             (string.gsub "/" ".")
                             (string.gsub ".fnl$" "")
                             require-module)]
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


(fn add-item-documentation [lines item docs]
  (lines:append (if docs (pick-values 1 (docs:gsub "\n#" "\n###"))
                    "**Undocumented**"))
  (lines:append ""))

(fn gen-markdown [module-info]
  (let [lines (setmetatable [(.. "# " module-info.module)]
                            {:__index table})]
    (-?>> module-info.description lines:append)
    (match module-info.version
      version (do (lines:append "")
                  (lines:append (.. "Documentation for version: " version))))
    (lines:append "")
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


(fn create-file-and-dirs [file version?]
  (let [path (file:gsub "[^\\/]+.fnl$" "")
        fname (-> file
                  (string.gsub path "")
                  (string.gsub ".fnl$" ".md"))
        dirs (-> (string.split path "\\/")
                 (table.append 1 "doc"))
        olddir (fs.currentdir)]
    (when version?
      (table.insert dirs 2 version?))
    (each [_ dir (ipairs dirs)]
      (fs.mkdir dir)
      (fs.chdir dir))
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
      (write-doc markdown (create-file-and-dirs file processed.version)))))

(main)

(setmetatable fenneldoc {:__call main})
