;;;; A module that evaluates Fennel code and obtains documentation for each
;;;; item in the module.  Supports sandboxing.

(local {: dofile : metadata : macro-loaded} (require :fennel))
(local compiler (require :fennel.compiler))
(local {: sandbox} (require :fnldoc.sandbox))
(local {: gen-function-signature : gen-item-documentation}
       (require :fnldoc.markdown))
(local console (require :fnldoc.console))

(fn function-name-from-file [file]
  (let [sep (package.config:sub 1 1)]
    (-> file
        (string.gsub (.. ".*" sep) "")
        (string.gsub "%.fnl$" ""))))

(fn get-module-docs [docs module config parent seen]
  (each [id val (pairs module)]
    (when (not= (string.sub id 1 1) "_")
      (match (type val)
        :table (when (not (. seen val))
                 (let [docstring (metadata:get val :fnl/docstring)
                       arglist (metadata:get val :fnl/arglist)]
                   (when (or docstring arglist)
                     (tset docs (if parent (.. parent "." id) id)
                           {: docstring : arglist})))
                 (get-module-docs docs val config id
                                  (doto seen (tset val true))))
        :function (tset docs (if parent (.. parent "." id) id)
                        {:docstring (metadata:get val :fnl/docstring)
                         :arglist (metadata:get val :fnl/arglist)}))))
  docs)

(fn module-from-file [file]
  (let [sep (package.config:sub 1 1)
        module (-> file
                   (string.gsub sep ".")
                   (string.gsub "%.fnl$" ""))]
    module))

(fn merge [t1 t2]
  (collect [k v (pairs (or t2 {})) :into (collect [k v (pairs t1)]
                                           k
                                           v)]
    k
    v))

(fn require-module [file config]
  "Require file as module in protected call.  Returns multiple values
with first value corresponding to pcall result."
  (let [env (when config.sandbox?
              (sandbox file))
        module-name (module-from-file file)]
    (match (pcall dofile file {:useMetadata true : env :allowedGlobals false}
                  module-name)
      (true ?module)
      (let [module (or ?module {})]
        (values (type module) module :functions (. macro-loaded module-name)))
      ;; try again, now with compiler env
      (false)
      (match (pcall dofile file
                    {:useMetadata true
                     :env :_COMPILER
                     :allowedGlobals false
                     :scope (. compiler :scopes :compiler)}
                    module-name)
        (true module) (values (type module) module :macros)
        (false msg) (values false msg)))))

(fn module-info [file config]
  "Returns table containing all relevant information accordingly to
`config` about the module in `file` for which documentation is
generated."
  (match (require-module file config)
    (:table module module-type ?macros)
    {:module (or (?. config :modules-info file :name) file)
     : file
     :type module-type
     :functions (if (= module-type :macros) {} module)
     :test-requirements (or (?. config :test-requirements file) "")
     :version (or (?. config :modules-info file :version)
                  config.project-version)
     :description (?. config :modules-info file :description)
     :copyright (or (?. config :modules-info file :copyright)
                    config.project-copyright)
     :license (or (?. config :modules-info file :license)
                  config.project-license)
     :metadata (get-module-docs {} (merge module ?macros) config nil {})
     :order (or (case (?. config :modules-info file :doc-order)
                  any (do
                        (console.warn "the 'doc-order' key in 'modules-info' was "
                                      "deprecated and no longer supported - use "
                                      "the 'order' key instead.")
                        any))
                (?. config :modules-info file :order)
                config.order)}
    ;; function modules have no version, license, or description keys,
    ;; as there's no way of adding this as a metadata or embed into
    ;; function itself.  So module description is set to a combination
    ;; of function docstring and signature if allowed by config.
    ;; Table of contents is also omitted.
    (:function function)
    (let [docstring (metadata:get function :fnl/docstring)
          arglist (metadata:get function :fnl/arglist)
          fname (function-name-from-file file)]
      {:module (or (?. config :modules-info file :name) file)
       : file
       :functions {fname function}
       :type :function-module
       :test-requirements (or (?. config :test-requirements file) "")
       :documented? (not (not docstring))
       ;; convert to Boolean
       :description (.. (or (?. config :modules-info file :description) "")
                        "\n" (gen-function-signature fname arglist config) "\n"
                        (gen-item-documentation docstring
                                                config.inline-references))
       : arglist
       :metadata {}})
    (false err)
    (do
      (io.stderr:write "Error loading " file "\n" err "\n")
      nil)
    _
    (do
      (io.stderr:write "Error loading " file "\nunhandled error!\n"
                       (tostring _))
      nil)))

{: module-info}
