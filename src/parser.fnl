;;;; A module that evaluates Fennel code and obtains documentation for each
;;;; item in the module.  Supports sandboxing.

(local {: dofile : metadata : macro-loaded} (require :fennel))
(local compiler (require :fennel.compiler))
(local {: gen-function-signature : gen-item-documentation} (require :markdown))

(fn sandbox-module [module file]
  (setmetatable
   {}
   {:__index (fn []
               (io.stderr:write
                (.. "ERROR: access to '" module
                    "' module detected in file: " file
                    " while loading\n"))
               (os.exit 1))}))

(fn create-sandbox [file overrides]
  "Create sandboxed environment to run `file` containing documentation,
and tests from that documentation.

Does not allow any IO, loading files or Lua code via `load`,
`loadfile`, and `loadstring`, using `rawset`, `rawset`, and `module`,
and accessing such modules as `os`, `debug`, `package`, `io`.

This means that your files must not use these modules on the top
level, or run any code when file is loaded that uses those modules.

You can provide an `overrides` table, which contains function name as
a key, and function as a value.  This function will be used instead of
specified function name in the sandbox.  For example, you can wrap IO
functions to only throw warning, and not error."
  (case overrides
    overrides
    (let [env {: assert                  ; allowed modules
               :bit32 _G.bit32 ; Lua 5.2 only
               : collectgarbage
               : coroutine
               : dofile
               : error
               : getmetatable
               : ipairs
               : math
               : next
               : pairs
               : pcall
               : rawequal
               :rawlen _G.rawlen ; Lua >=5.2
               : require
               : select
               : setmetatable
               : string
               : table
               : tonumber
               : tostring
               : type
               :unpack _G.unpack ; Lua 5.1 only
               :utf8 _G.utf8 ; Lua >= 5.3
               : xpcall

               :load nil                 ; disallowed modules
               :loadfile nil
               :loadstring nil
               :rawget nil
               :rawset nil
               :module nil

               :arg []                   ; sandboxed modules
               :print (fn []
                        (io.stderr:write "ERROR: IO detected in file: " file " while loading\n")
                        (os.exit 1))
               :os (sandbox-module :os file)
               :debug (sandbox-module :debug file)
               :package (sandbox-module :package file)
               :io (sandbox-module :io file)}]
      (set env._G env)
      (each [k v (pairs overrides)]
        (tset env k v))
      env)
    _ (create-sandbox file {})))

(fn function-name-from-file [file]
  (let [sep (package.config:sub 1 1)]
    (-> file
        (string.gsub (.. ".*" sep) "")
        (string.gsub "%.fnl$" ""))))

(fn get-module-docs [docs module config parent seen]
  (each [id val (pairs module)]
   (when (not= (string.sub id 1 1) :_)
     (match (type val)
       :table
       (when (not (. seen val))
         (let [docstring (metadata:get val :fnl/docstring)
               arglist (metadata:get val :fnl/arglist)]
           (when (or docstring arglist)
             (tset docs
                   (if parent (.. parent "." id) id)
                   {:docstring docstring :arglist arglist})))
         (get-module-docs docs val config id (doto seen (tset val true))))
       :function
       (tset docs
             (if parent (.. parent "." id) id)
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
  (collect [k v (pairs (or t2 {}))
            :into (collect [k v (pairs t1)]
                    k v)]
    k v))

(fn require-module [file config]
  "Require file as module in protected call.  Returns multiple values
with first value corresponding to pcall result."
  (let [env (when config.sandbox
              (create-sandbox file))
        module-name (module-from-file file)]
    (match (pcall dofile
                  file
                  {:useMetadata true
                   :env env
                   :allowedGlobals false}
                  module-name)
      (true ?module) (let [module (or ?module {})]
                       (values (type module) module :functions
                               (. macro-loaded module-name)))
      ;; try again, now with compiler env
      (false) (match (pcall dofile
                            file
                            {:useMetadata true
                             :env :_COMPILER
                             :allowedGlobals false
                             :scope (. compiler :scopes :compiler)}
                            module-name)
                (true module) (values (type module) module :macros)
                (false msg) (values false msg)))))

(local
  warned {})

(fn module-info [file config]
  "Returns table containing all relevant information accordingly to
`config` about the module in `file` for which documentation is
generated."
  (match (require-module file config)
    (:table module module-type ?macros)
    {:module (or (?. config :modules-info file :name)
                 file)
     :file file
     :type module-type
     :f-table (if (= module-type :macros) {} module)
     :requirements (or (?. config :test-requirements file) "")
     :version (or (?. config :modules-info file :version)
                  config.project-version)
     :description (?. config :modules-info file :description)
     :copyright (or (?. config :modules-info file :copyright)
                    config.project-copyright)
     :license (or (?. config :modules-info file :license)
                  config.project-license)
     :items (get-module-docs {} (merge module ?macros) config nil {})
     :doc-order (or (?. config :modules-info file :doc-order)
                    (?. config :project-doc-order file)
                    [])}
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
       :file file
       :f-table {fname function}
       :type :function-module
       :requirements (or (?. config :test-requirements file) "")
       :documented? (not (not docstring)) ;; convert to Boolean
       :description (.. (or (?. config :modules-info file :description) "")
                        "\n"
                        (gen-function-signature fname arglist config)
                        "\n"
                        (gen-item-documentation docstring config.inline-references))
       : arglist
       :items {}})
    (false err) (do (io.stderr:write "Error loading " file "\n" err "\n")
                    nil)
    _ (do (io.stderr:write "Error loading " file "\nunhandled error!\n" (tostring _))
          nil)))

{: create-sandbox : module-info}

;; LocalWords:  sandboxed Lua loadfile loadstring rawset os io config
;; LocalWords:  metadata docstring fenneldoc
