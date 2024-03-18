;;;; Analyze Fennel code and extract module information.

;;;; ## Overview

;;;; ### Module types
;;;;
;;;; There are three module types for generating documentation:
;;;;
;;;; - a table of *functions*,
;;;; - a table of *macros*, and
;;;; - just a *function*.
;;;;
;;;; These types are detected by trying to `require-file' and see its
;;;; result.

;;;; ### Extracting metadata
;;;;
;;;; In general, a module may contain any type of object, but we only
;;;; need to care about table and function, since Fennel attaches
;;;; metadata only to functions. Tables are recursively searched for
;;;; metadata by `find-metadata'.
;;;;
;;;; Each function may have metadata, which contains `:fnl/arglist`
;;;; and/or `:fnl/docstring`. These two entries are extracted by
;;;; `extract-metadata' and used for rendering function/macro signature
;;;; and description.
;;;;
;;;; In addition, Fnldoc has its own metadata entry `:fnldoc/type`,
;;;; which will also be extracted and used to show which type the
;;;; function is. An example usage:
;;;;
;;;; ```fennel :skip-test
;;;; (fn a-macro []
;;;;   {:fnldoc/type :macro}
;;;;   `(print :a-macro))
;;;; ```
;;;;
;;;; However, `:fnldoc/type` annotation is not mandatory for *macros*
;;;; module, since it is clear that functions in a *macros* module are
;;;; macros, and it will properly detected.

;;;; ### Module description
;;;;
;;;; In addition to `require-file', Fnldoc does
;;;; `extract-module-description' by scanning the file and searching
;;;; for top-level module description. The module description should
;;;; begin with four semicolons `;;;; `.

;;;; ### Module information
;;;;
;;;; Analyzed information in the above sections will be combined into
;;;; module information, which is a table that summarizes the module
;;;; and contains all relevant metadata. This task is done by
;;;; `module-info' function.

(local {: dofile : metadata : macro-loaded} (require :fennel))
(local compiler (require :fennel.compiler))
(local {: sandbox} (require :fnldoc.sandbox))
(local console (require :fnldoc.console))
(local {: exit/error} (require :fnldoc.debug))
(local {: file-exists?} (require :fnldoc.utils.file))
(local {: merge!} (require :fnldoc.utils.table))
(local {: lines->text} (require :fnldoc.utils.text))
(local {: path->function-name : path->module-name} (require :fnldoc.utils.file))
(local {: item-index->anchor-map : item-documentation}
       (require :fnldoc.markdown))

(lambda extract-metadata [value]
  "Extract metadata from the `value`; return `nil` if not found."
  (let [docstring (metadata:get value :fnl/docstring)
        arglist (metadata:get value :fnl/arglist)
        ftype (metadata:get value :fnldoc/type)]
    (when (or docstring arglist ftype)
      {: docstring : arglist :type ftype})))

(lambda find-metadata [module]
  "Find metadata contained in the `module` table recursively.

It returns a table that maps module (table or function) name to
its metadata."
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

Return multiple values with the first value corresponding to `pcall`
result. The second value is a table that contains the following
entries.

- `type`: Module's value type, i.e., `:table`, `:string`, etc.
- `module`: Module contents.
- `macros?`: Indicates whether this is a *macros* module.
- `loaded-macros`: Macros if any loaded found."
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

(lambda extract-module-description [file]
 "Extract module description from the top of the `file`.

It collects top comments beginning with `^%s*;;;; ` and returns a
string in which `;;;; ` is stripped from each line. Lines that match
`^%s*;;;;$` or `^%s*$` are counted as empty lines in the string.

# Example

In the following Fennel module file,

```fennel :skip-test
;;;; A paragraph.

;;;; Another paragraph.
;;;;
;; This is usual comment.
;;;; More paragraph.

(fn f [] (print :hello))

;;;; This line will be ignored. Only top comments are scanned.

{: f}
```

Module description is collected as:

```
A paragraph.

Another paragraph.

More paragraph.
```"
  (case (io.open file)
    in (with-open [in in]
         (let [lines []
               empty-line "^%s*$"
               another-empty-line "^%s*;;;;$"
               description-line "^%s*;;;; "
               comment-line "^%s*;"]
           (var parsing? true)
           (var empty-lines-count 0)
           (while parsing?
             (case (in:read)
               line (if (line:match description-line)
                        (do
                          (for [_ 1 empty-lines-count]
                            (table.insert lines ""))
                          (set empty-lines-count 0)
                          (doto lines
                            (table.insert (line:match (.. description-line "(.*)$")))))
                        (line:match empty-line)
                        (set empty-lines-count (+ 1 empty-lines-count))
                        (line:match another-empty-line)
                        (set empty-lines-count (+ 1 empty-lines-count))
                        (line:match comment-line)
                        (do :ignore-it!)
                        (set parsing? nil))
               _ (set parsing? nil)))
           (when (< 0 (length lines))
             (lines->text lines))))
    _ (do
        (console.error "error readling file: " file)
        nil)))

(lambda module-info [file config ?debug]
  "Return a table containing all relevant information accordingly
to `config` about the module in the `file` for which documentation is
generated. The result contains the following entries.

- `name`: Module name if specified in `.fenneldoc`.
- `description`: Module description, specified in `.fenneldoc` or
  extracted from the top comments of the file.
- `type`: Module type, either `:functions`, `:macros`, or `:function`.
- `items`: Module contents, which will be used for doctest-ing.
- `test-requirements`: Doctest requirements if specified in `.fenneldoc`.
- `metadata`: Recursively extracted metadata of module items.
- `order`: Item sorting order if specified in `.fenneldoc`.
- `copyright`: Copyright information if specified in `.fenneldoc`.
- `license`: License information if specified in `.fenneldoc`.
- `version`: Version information if specified in `.fenneldoc`.

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit."
  (match (require-file file config.sandbox?)
    (where (true result) (= :table result.type))
    {:name (?. config :modules-info file :name)
     :description (or (?. config :modules-info file :description)
                      (extract-module-description file))
     : file
     :type (if result.macros? :macros :functions)
     :items (if result.macros? {} result.module)
     :test-requirements (?. config :test-requirements file)
     :metadata (let [mdata (find-metadata (doto result.module
                                            (merge! result.loaded-macros)))]
                 (when result.macros?
                   (each [item (pairs mdata)]
                     (when (not (?. mdata item :type))
                       (tset mdata item :type :macro))))
                 mdata)
     :order (or (case (?. config :modules-info file :doc-order)
                  any (do
                        (console.warn "the 'doc-order' key in 'modules-info' "
                                      "was deprecated and no longer supported"
                                      " - use the 'order' key instead.")
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
                          anchors (item-index->anchor-map [fname] {fname mdata})]
                      (if desc
                          (-> [desc
                               ""
                               (item-documentation fname mdata anchors config)]
                              (lines->text))
                          (item-documentation fname mdata anchors config)))
       : file
       :type :function
       :items {fname result.module}
       :test-requirements (?. config :test-requirements file)
       :metadata {}
       :documented? (if mdata.docstring true false)
       :arglist mdata.arglist})
    (true result)
    (do
      (console.info "skipping a module of type '" result.type "': " file)
      nil)
    (false msg)
    (exit/error (.. "error loading " file ": " msg) ?debug)
    _
    (exit/error (.. "UNHANDLED ERROR LOADING " file ": " (tostring _)) ?debug))) 

{: extract-metadata
 : find-metadata
 : require-file
 : extract-module-description
 : module-info}
