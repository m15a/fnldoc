(local fennel (require :fennel))
(local fs (require :lfs))
(local {: gen-markdown
        : gen-function-signature
        : gen-item-documentation}
       (require :markdown))


(fn string.split [s seps]
  (let [seps (or seps "%s")
        res []]
    (each [s _ (s:gmatch (.. "[^" seps "]+"))]
      (table.insert res s))
    res))


(fn create-dirs-from-path [file]
  (let [path (file:gsub "[^\\/]+.fnl$" "")
        fname (-> file
                  (string.gsub path "")
                  (string.gsub ".fnl$" ".md"))
        dirs (-> (string.split path "\\/")
                 (doto (table.insert 1 "doc")))
        olddir (fs.currentdir)]
    (each [i dir (ipairs dirs)]
      (if (not= dir :src)
          (do (fs.mkdir dir)
              (fs.chdir dir))
          (tset dirs i nil)))
    (fs.chdir olddir)
    (.. (table.concat dirs "/") "/" fname)))


(fn write-doc [docs file]
  "Accepts `docs` as a vector of lines, and a path to a `file`.
Concatenates lines in `docs` with newline, and writes result to
`file`."
  (with-open [file (io.open (create-dirs-from-path file) :w)]
    (file:write docs)))


(fn capitalize [str]
  (.. (string.upper (str:sub 1 1))
      (str:sub 2 -1)))


(fn require-module [file]
  "Require file as module in protected call.  Returns vector with first value
corresponding to pcall result."
  (let [(module? module) (pcall fennel.dofile file {:useMetadata true})]
    [(and module? (type module)) module]))


(fn module-heading [file]
  (-> file
      (string.gsub ".*/" "")
      (capitalize)))

(fn function-name-from-file [file]
  (-> file
      (string.gsub ".*/" "")
      (string.gsub ".fnl$" "")))

(fn module-docs [module config]
  (let [docs {}]
    (each [id val (pairs module)]
      (when (and (not= (string.sub id 1 1) :_)
                 (not= id config.version-key))
        (tset docs id {:docstring (fennel.metadata:get val :fnl/docstring)
                       :arglist (fennel.metadata:get val :fnl/arglist)})))
    docs))


(fn gen-module-info [file config]
  (match (require-module file)
    [:table module] {:module (module-heading file)
                     :type :module
                     :version (. module config.version-key)
                     :description (. module config.description-key)
                     :items (module-docs module config)}
    [:function function] {:module (module-heading file)
                          :type :function-module
                          :description (.. (gen-function-signature
                                            (function-name-from-file file)
                                            (fennel.metadata:get function :fnl/arglist)
                                            config)
                                           (gen-item-documentation
                                            (fennel.metadata:get function :fnl/docstring)))
                          :items {}}
    [false err] (io.stderr:write (.. "Error loading file " file "\n" err))))


(fn generate-doc [file config]
  "Accepts `file` path, and `config`. Generates module documentation
and writes it to `file` creating it if not exists."
  (-?> file
       (gen-module-info config)
       (gen-markdown config)
       (write-doc file)))
