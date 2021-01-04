(local fennel (require :fennel))
(local compiler (require :fennel.compiler))
(local fs (require :lfs))
(local {: gen-markdown
        : gen-function-signature
        : gen-item-documentation}
       (require :markdown))

(fn function-name-from-file [file]
  (-> file
      (string.gsub ".*/" "")
      (string.gsub ".fnl$" "")))

(fn create-dirs-from-path [file module config]
  "Creates path up to specified file."
  (let [sep (package.config:sub 1 1)
        path (.. config.out-dir sep (file:gsub (.. "[^" sep "]+.fnl$") ""))
        fname (-> (or module.module file)
                  (string.gsub (.. ".*[" sep "]+") "")
                  (string.gsub ".fnl$" "")
                  (.. ".md"))]
    (var p "")
    (each [dir (path:gmatch (.. "[^" sep "]+"))]
      (set p (.. p dir sep))
      (match (fs.mkdir p)
        (nil "File exists" 17) nil
        (nil msg code) (lua "return nil, dir, msg, code")))
    (-> (.. p sep fname)
        (string.gsub (.. "[" sep "]+") sep))))


(fn write-doc [docs file module config]
  "Accepts `docs` as a vector of lines, and a path to a `file`.
Concatenates lines in `docs` with newline, and writes result to
`file`."
  (match (create-dirs-from-path file module config)
    path (match (io.open path :w)
           f (with-open [file f]
               (file:write docs))
           (nil  msg code) (do (io.stderr:write (.. "Error opening file '" path "': " msg " (" code ")\n"))
                               (os.exit code)))

    (nil dir msg code) (do (io.stderr:write (.. "Error creating directory '" dir "': " msg " (" code ")\n"))
                           (os.exit code))))


(fn get-module-docs [module config]
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

(fn get-module-info [module key fallback]
  (let [info (. module key)]
    (match (type info)
      :function (info) ;; hack for supporting this in macro modules
      :string info
      :table info
      :nil fallback
      _ nil)))

(fn module-info [file config]
  (match (require-module file)
    ;; Ordinary module that returns a table.  If module has keys that
    ;; are specified within the `:keys` section of `.fenneldoc` those
    ;; are looked up in the module for additional info.
    [:table module] {:module (get-module-info module config.keys.module-name file)
                     :type :module
                     :version (get-module-info module config.keys.version)
                     :description (get-module-info module config.keys.description)
                     :copyright (get-module-info module config.keys.copyright)
                     :license (get-module-info module config.keys.license)
                     :items (get-module-docs module config)
                     :doc-order (get-module-info module config.keys.doc-order)}
    ;; function modules have no version, license, or description keys,
    ;; as there's no way of adding this as a metadata or embed into
    ;; function itself.  So module description is set to a combination
    ;; of function docstring and signature if allowed by config.
    ;; Table of contents is also omitted.
    [:function function] {:module file
                          :type :function-module
                          :description (.. (gen-function-signature
                                            (function-name-from-file file)
                                            (fennel.metadata:get function :fnl/arglist)
                                            config)
                                           "\n"
                                           (gen-item-documentation
                                            (fennel.metadata:get function :fnl/docstring)))
                          :items {}}
    [false err] (io.stderr:write (.. "Error loading file " file "\n" err "\n"))))


(fn generate-doc [file config]
  "Accepts `file` as path to some Fennel module, and `config` table.
Generates module documentation and writes it to `file` with `.md`
extension, creating it if not exists."
  (let [module (module-info file config)
        markdown (gen-markdown module config)]
    (write-doc markdown file module config)))
