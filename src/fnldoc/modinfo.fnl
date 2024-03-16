;;;; A module that evaluates Fennel code and obtains documentation for each
;;;; item in the module.  Supports sandboxing.

(local {: dofile : metadata : macro-loaded} (require :fennel))
(local compiler (require :fennel.compiler))
(local {: sandbox} (require :fnldoc.sandbox))
(local console (require :fnldoc.console))
(local {: file-exists?} (require :fnldoc.utils.file))
(local {: merge!} (require :fnldoc.utils.table))
(local {: lines->text} (require :fnldoc.utils.text))
(local {: path->function-name : path->module-name} (require :fnldoc.utils.file))
(local {: item-index->anchor-map : item-documentation}
       (require :fnldoc.markdown))

(lambda extract-metadata [value]
  "Extract metadata from the `value`; return `nil` if not found."
  (let [docstring (metadata:get value :fnl/docstring)
        arglist (metadata:get value :fnl/arglist)]
    (when (or docstring arglist)
      {: docstring : arglist})))

(lambda find-metadata [module]
  "Find metadata contained in the `module` table recursively.

It returns a table that maps module (table or function) name to its metadata."
  (let [found {}
        seen {}]
    (fn find! [{: module : parent}]
      (each [id value (pairs module)]
        (when (not (string.match id "^_"))
          (let [id* (if parent (.. parent "." id) id)]
            (match (type value)
              :table (when (not (. seen value))
                       (tset found id* (extract-metadata value))
                       (tset seen value true)
                       (find! {:module value :parent id*}))
              :function (tset found id* (extract-metadata value)))))))
    (find! {: module})
    found))

(lambda require-file [file sandbox?]
  "Require `file` as module in protected call with/out `sandbox?`-ing.

Return multiple values with the first value corresponding to pcall result.
The second value is a table that contains

* `:type` - module's value type, i.e., `table`, `string`, etc.;
* `:module` - module contents;
* `:macros?` - indicates whether this is a macro module; and
* `:loaded-macros` - macros if any loaded found."
  (if (not (file-exists? file))
      (values false "file not found")
      (let [module-name (path->module-name file)
            try (fn [opts]
                  (merge! opts {:useMetadata true :allowedGlobals false})
                  (pcall dofile file opts module-name))]
        (case (try {:env (when sandbox? (sandbox file))})
          (true ?module)
          (values true {:type (type ?module)
                        :module ?module
                        :loaded-macros (. macro-loaded module-name)})
          ;; try again, now with compiler env
          (false)
          (case (try {:env :_COMPILER :scope compiler.scopes.compiler})
            (true ?module)
            (values true {:type (type ?module)
                          :module ?module
                          :macros? true})
            (false msg)
            (values false msg))))))

(lambda module-info [file config]
  "Returns table containing all relevant information accordingly to
`config` about the module in the `file` for which documentation is
generated."
  (match (require-file file config.sandbox?)
    (where (true result) (= :table result.type))
    {:name (?. config :modules-info file :name)
     :description (?. config :modules-info file :description)
     : file
     :type (if result.macros? :macros :functions)
     :items (if result.macros? {} result.module)
     :test-requirements (?. config :test-requirements file)
     :metadata (find-metadata (doto result.module
                                (merge! result.loaded-macros)))
     :order (or (case (?. config :modules-info file :doc-order)
                  any (do
                        (console.warn "the 'doc-order' key in 'modules-info' was "
                                      "deprecated and no longer supported - use "
                                      "the 'order' key instead.")
                        any))
                (?. config :modules-info file :order)
                config.order)
     :copyright (or (?. config :modules-info file :copyright)
                    config.project-copyright)
     :license (or (?. config :modules-info file :license)
                  config.project-license)
     :version (or (?. config :modules-info file :version)
                  config.project-version)}
    ;; function modules have no version, license, or description keys,
    ;; as there's no way of adding this as a metadata or embed into
    ;; function itself.  So module description is set to a combination
    ;; of function docstring and signature if allowed by config.
    ;; Table of contents is also omitted.
    (where (true result) (= :function result.type))
    (let [mdata (extract-metadata result.module)
          fname (path->function-name file)]
      {:name (?. config :modules-info file :name)
       :description (let [desc (?. config :modules-info file :description)
                          anchors (item-index->anchor-map [fname])]
                      (if desc
                          (-> [desc
                               ""
                               (item-documentation fname mdata anchors config)]
                              (lines->text))
                          (item-documentation fname mdata anchors config)))
       : file
       :type :function-module
       :items {fname result.module}
       :test-requirements (?. config :test-requirements file)
       :metadata {}
       :documented? (if mdata.docstring true false)
       :arglist mdata.arglist})
    (true result)
    (do
      (console.info "skipping a module of type '" (type result) "': " file)
      nil)
    (false msg)
    (do
      (console.error "error loading " file ": " msg)
      nil)
    _
    (do
      (console.error "UNHANDLED ERROR LOADING " file ": " (tostring _))
      nil)))

{: extract-metadata
 : find-metadata
 : require-file
 : module-info}
