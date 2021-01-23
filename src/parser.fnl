(local fennel (require :fennel))
(local compiler (require :fennel.compiler))
(local {: get-in} (require :cljlib))
(local {: gen-function-signature
        : gen-item-documentation}
       (require :markdown))

(fn sandbox-module [module file]
  (setmetatable
   {}
   {:__index (fn []
               (io.stderr:write
                (.. "ERROR: access to '" module
                    "' module detected in file: " file
                    "while loading\n"))
               (os.exit 1))}))

(fn create-sandbox [overrides]
  "Create sandboxed environment to run files containing documentation,
and tests from that documentation.

Does not allow any IO, loading files or Lua code via `load`,
`loadfile`, and `loadstring`, using `rawset`, `rawset`, and `module`,
and accessing such modules as `os`, `debug`, `package`, `io`.

This means that your files must not use these modules on the top
level, or run any code when file is loaded that uses those modules.

You can provide an `overrides` table, which contains function name as
a key, and function as a value.  This function will be used instead of
specified function name in the sandbox.  For example, you can wrap IO
functions to only throw warning, and not error. "
  (let [env {;; allowed modules
             : assert
             : bit32
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
             : rawlen
             : require
             : select
             : setmetatable
             : string
             : table
             : tonumber
             : tostring
             : type
             : unpack
             : utf8
             : xpcall
             ;; disallowed modules
             :load nil
             :loadfile nil
             :loadstring nil
             :rawget nil
             :rawset nil
             :module nil
             ;; sandboxed modules
             :arg []
             :print (fn []
                      (io.stderr:write "ERROR: IO detected in file: " file " while loading\n") (os.exit 1))
             :os (sandbox-module :os file)
             :debug (sandbox-module :debug file)
             :package (sandbox-module :package file)
             :io (sandbox-module :io file)}]
    (set env._G env)
    (each [k v (pairs (or overrides {}))]
      (tset env k v))
    env))

(fn function-name-from-file [file]
  (-> file
      (string.gsub ".*/" "")
      (string.gsub ".fnl$" "")))

(fn get-module-docs [module config]
  (let [docs {}]
    (each [id val (pairs module)]
      (when (and (not= (string.sub id 1 1) :_) ;; ignore keys starting with `_`
                 (not (. config.keys id)))     ;; ignore special keys, like `:version`
        (tset docs id {:docstring (fennel.metadata:get val :fnl/docstring)
                       :arglist (fennel.metadata:get val :fnl/arglist)})))
    docs))

(fn require-module [file config]
  "Require file as module in protected call.  Returns vector with first value
corresponding to pcall result."
  (let [sandbox (when config.sandbox (create-sandbox))]
    (match (pcall fennel.dofile file {:useMetadata true :env sandbox})
      (true module) (values (type module) module :functions)
      ;; try again, now with compiler env
      (false _) (match (pcall fennel.dofile file {:useMetadata true
                                                  :env :_COMPILER
                                                  :scope (. compiler :scopes :compiler)})
                  (true module) (values (type module) module :macros)
                  (false msg) (values false msg)))))

(fn get-module-info [module key fallback]
  (let [info (. module key)]
    (match (type info)
      :function (info) ;; hack for supporting this in macro modules
      :string info
      :table info
      :nil fallback
      _ nil)))

(fn module-info [file config]
  "Returns table containing all relevant information accordingly to
`config` about the module in `file` for which documentation is
generated."
  (match (require-module file config)
    ;; Ordinary module that returns a table.  If module has keys that
    ;; are specified within the `:keys` section of `.fenneldoc` those
    ;; are looked up in the module for additional info.
    (:table module module-type) {:module (get-module-info module config.keys.module-name file)
                                 :file file
                                 :type module-type
                                 :f-table (if (= module-type :macros) {} module)
                                 :requirements (get-in config [:test-requirements file] "")
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
    (:function function) (let [docstring (fennel.metadata:get function :fnl/docstring)
                               arglist (fennel.metadata:get function :fnl/arglist)
                               fname (function-name-from-file file)]
                           {:module file
                            :file file
                            :f-table {fname function}
                            :type :function-module
                            :requirements (get-in config [:test-requirements file] "")
                            :documented? (not (not docstring)) ;; convert to boolean
                            :description (.. (gen-function-signature fname arglist config)
                                             "\n"
                                             (gen-item-documentation docstring))
                            : arglist
                            :items {}})
    (false err) (io.stderr:write "Error loading " file "\n" err "\n")
    _ (io.stderr:write "Error loading " file "\nunhandled error!\n")))

{: create-sandbox
 : module-info}
