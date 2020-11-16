(local fennel (require :fennel))
(local compiler (require :fennel.compiler))
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


(fn create-dirs-from-path [file config]
  (let [path (file:gsub "[^\\/]+.fnl$" "")
        fname (-> file
                  (string.gsub path "")
                  (string.gsub ".fnl$" ".md"))
        dirs (-> (string.split path "\\/")
                 (doto (table.insert 1 config.out-dir)))
        olddir (fs.currentdir)]
    (each [i dir (ipairs dirs)]
      (if (not= dir :src)
          (match (fs.mkdir dir)
            (true) (fs.chdir dir)
            (nil "File exists" 17) (fs.chdir dir)
            (nil msg code) (do (fs.chdir olddir)
                               (lua "return nil, dir, msg, code")))
          (tset dirs i nil)))
    (fs.chdir olddir)
    (-> (table.concat dirs "/")
        (.. "/" fname)
        (string.gsub "[/]+" "/"))))


(fn write-doc [docs file config]
  "Accepts `docs` as a vector of lines, and a path to a `file`.
Concatenates lines in `docs` with newline, and writes result to
`file`."
  (let [(path dir msg code) (create-dirs-from-path file config)]
    (if path
        (let [(file msg code) (io.open path :w)]
          (if file
              (with-open [file file]
                (file:write docs))
              (do (io.stderr:write (.. "Error opening file '" path "': " msg " (" code ")\n"))
                  (os.exit code))))
        (do (io.stderr:write (.. "Error creating directory '" dir "': " msg " (" code ")\n"))
            (os.exit code)))))


(fn capitalize [str]
  (.. (string.upper (str:sub 1 1))
      (str:sub 2 -1)))


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
      (when (and (not= (string.sub id 1 1) :_) ;; ignore keys starting with `_`
                 (not (. config.keys id)))     ;; ignore special keys, like `:version`
        (tset docs id {:docstring (fennel.metadata:get val :fnl/docstring)
                       :arglist (fennel.metadata:get val :fnl/arglist)})))
    docs))


(fn require-module [file]
  "Require file as module in protected call.  Returns vector with first value
corresponding to pcall result."
  (match (pcall fennel.dofile file {:useMetadata true})
    (true module) [(type module) module]
    ;; try again, now with compiler env
    (false msg) (match (pcall fennel.dofile file {:useMetadata true
                                                  :env :_COMPILER
                                                  :scope (. compiler :scopes :compiler)})
                  (true module) [(type module) module]
                  (false msg) [false msg])))


(fn gen-module-info [file config]
  (match (require-module file)
    ;; Ordinary module that returns a table.  If module has keys that
    ;; are specified within the `:keys` section of `.fenneldoc` those
    ;; are looked up in the module for additional info.
    [:table module] {:module (module-heading file)
                     :type :module
                     :version (. module config.keys.version)
                     :description (. module config.keys.description)
                     :copyright (. module config.keys.copyright)
                     :license (. module config.keys.license)
                     :items (module-docs module config)}
    ;; function modules have no version, license, or description keys,
    ;; as there's no way of adding this as a metadata or embed into
    ;; function itself.  So module description is set to a combination
    ;; of function docstring and signature if allowed by config.
    ;; Table of contents is also omitted.
    [:function function] {:module (module-heading file)
                          :type :function-module
                          :description (.. (gen-function-signature
                                            (function-name-from-file file)
                                            (fennel.metadata:get function :fnl/arglist)
                                            config)
                                           "\n"
                                           (gen-item-documentation
                                            (fennel.metadata:get function :fnl/docstring)))
                          :items {}}
    [false err] (io.stderr:write (.. "Error loading file " file "\n" err))))


(fn generate-doc [file config]
  "Accepts `file` as path to some Fennel module, and `config` table.
Generates module documentation and writes it to `file` with `.md`
extension, creating it if not exists."
  (-?> file
       (gen-module-info config)
       (gen-markdown config)
       (write-doc file config)))
