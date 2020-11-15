(local fennel (require :fennel))
(local fs (require :lfs))
(local fenneldoc (require :fenneldoc))


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
                 (table.append 1 "doc"))
        olddir (fs.currentdir)]
    (each [_ dir (ipairs dirs)]
      (when (not= dir :src)
        (fs.mkdir dir)
        (fs.chdir dir)))
    (fs.chdir olddir)
    (.. (table.concat dirs "/") "/" fname)))


(fn write-doc [docs file]
  "Accepts `docs` as a vector of lines, and a path to a `file`.
Concatenates lines in `docs` with newline, and writes result to
`file`."
  (with-open [file (io.open (create-dirs-from-path file) :w)]
    (file:write (docs:concat "\n"))))


(fn capitalize [str]
  (.. (string.upper (str:sub 1 1))
      (str:sub 2 -1)))


(fn require-module [file]
  "Require file as module in protected call.  Returns vector with first value
corresponding to pcall result."
  (let [(module? mod) (pcall fennel.dofile file {:useMetadata true})]
    [module? mod]))


(fn gen-module-info [file config]
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


(fn process-file [file config]
  "Accepts `file` path, and `config`. Generates module documentation
and writes it to `file` creating it if not exists."
  (-> file
      (gen-module-info config)
      (fenneldoc config)
      (write-doc file)))
