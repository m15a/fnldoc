(local fennel (require :fennel))
(import-macros {: into : fn*} :cljlib.macros)
(local {: hash-set
        : inc
        : conj
        : keys
        : vals
        : mapv
        : first}
       (require :cljlib))

;; format: {:key [default-value descr validate-fn]}

(local key-flags {:--license-key     [:_LICENSE "license information of the module."]
                  :--description-key [:_DESCRIPTION "the description of the module."]
                  :--copyright-key   [:_COPYRIGHT "copyright information of the module."]
                  :--doc-order-key   [:_DOC_ORDER "order of items of the module."]
                  :--version-key     [:_VERSION "the version of the module."]})

(local value-flags {:--out-dir ["./doc" "output directory for generated documentation."]
                    :--order   ["alphabetic" "sorting of items that were not given particular order.
                                              Supported algorithms: alphabetic, reverse-alphabetic.
                                              You also can specify a custom sorting function
                                              in .fenneldoc file."
                                #(when (not ((hash-set :alphabetic :reverse-alphabetic) $))
                                   (io.stderr:write "Error: wrong value specified for key --order '" $"'\n"
                                                    "supported orders: alphabetic, reverse-alphabetic\n")
                                   (os.exit 1))]
                    :--mode    ["checkdoc" "mode to operate in.  Supported modes:
                                            checkdoc - check documentation and generate markdown;
                                            check    - only check documentation;
                                            doc      - only generate markdown."
                                #(when (not ((hash-set :checkdoc :check :doc) $))
                                   (io.stderr:write "Error wrong value specified for key --mode '" $"'\n"
                                                    "supported modes: checkdoc, check, doc.\n")
                                   (os.exit 1))]
                    :--inline-references ["link" "how to handle inline references. Supported modes:
                                                  link - convert inline references to markdown links;
                                                  code - convert inline references to inline code;
                                                  keep - keep inline references as is."
                                          #(when (not ((hash-set :link :code :keep) $))
                                             (io.stderr:write "Error wrong value specified for key --inline-references '" $"'\n"
                                                              "supported modes: link, code, keep.\n")
                                             (os.exit 1))]})

(local bool-flags {:--function-signatures [true "(don't) generate function signatures in documentation."]
                   :--final-comment       [true "(don't) insert final comment with fenneldoc version."]
                   :--copyright           [true "(don't) insert copyright information."]
                   :--license             [true "(don't) insert license information from the module."]
                   :--toc                 [true "(don't) generate table of contents."]
                   :--sandbox             [true "(don't) sandbox loaded code and documentation tests."]})

(fn* longest-length [items]
  (var len 0)
  (each [_ x (ipairs items)]
    (set len (math.max len (length (tostring x)))))
  (+ len 1))

(fn* gen-help-info [flags]
  (let [lines []
        longest-flag (longest-length (keys flags))
        longest-default (longest-length (mapv first (vals flags)))]
    (each [flag [default docstring] (pairs flags)]
      (let [default (tostring (or default ""))
            flag-pad (string.rep " " (- longest-flag (length flag)))
            doc-pad (string.rep " " (- longest-default (length default)))
            [doc-line & doc-lines] (icollect [s (docstring:gmatch "[^\r\n]+")]
                                     (s:gsub "^%s*(.-)%s*$" "%1"))]
        (var doc-line (.. "  " flag flag-pad default doc-pad doc-line))
        (when (next doc-lines)
          (each [_ line (ipairs doc-lines)]
            (set doc-line (.. doc-line "\n  " (string.rep " " (- (length flag) 1))
                              flag-pad (string.rep " " (- (length default) 1))
                              doc-pad "  " line))))
        (table.insert lines doc-line)))
    (table.sort lines)
    (table.concat lines "\n")))

(fn* help []
  (print (.. "Usage: fenneldoc [flags] [files]

Create documentation for your Fennel project.

Key lookup flags:
"
             (gen-help-info key-flags)
             "

Option flags:
"
             (gen-help-info value-flags)
             "

Toggle flags:
"
             (gen-help-info
              (into {} (mapv (fn [[k [default docstring]]]
                               [(k:gsub "^[-][-]" "--[no-]") ["" docstring]])
                             bool-flags)))
             "

Other flags:
  --                treat remaining flags as files.
  --config consume all regular flags and write to config file.
                    Updates current config if .fenneldoc already exists at
                    current directory.
  --help            print this message and exit.

All keys have corresponding entry in `.fenneldoc' configuration file,
and args passed via command line have higher precedence, therefore
will override following values in `.fenneldoc'.

Each toggle key has two variants with and without `no'.  For example,
passing `--no-toc' will disable generation of contents table, and
`--toc` will enable it."))
  (os.exit 0))

(local bool-flags-set (hash-set))
(each [flag [toggle?] (pairs bool-flags)]
  (conj bool-flags-set flag)
  (when toggle?
    (let [inverse-flag (flag:gsub "^[-][-]" "--no-")]
      (conj bool-flags-set inverse-flag))))

(fn* handle-bool-flag [flag config]
  ;; Boolean flags can start with `--no-` prefix, meaning that we want to
  ;; disable feature.
  (match (string.sub flag 1 4)
    :--no (tset config (string.sub flag 6) false)
    _ (tset config (string.sub flag 3) true)))

(fn* handle-value-flag [i flag config]
  ;; value flags are followed with value
  (let [[_ _ validate-fn] (. value-flags flag)
        flag (string.sub flag 3 -1)]
    (match (. arg i)
      val (do (when validate-fn
                (validate-fn val))
              (tset config flag val))
      nil (do (io.stderr:write "fenneldoc: expected value for " flag "\n")
              (os.exit -1)))))

(fn* handle-key-flag [i flag config]
  ;; key flags start with `--` and end with `-key`, and are stored
  ;; under `config.keys` without `-key` suffix. they are also followed with value, therefore
  (let [flag (string.sub flag 3 -5)]
    (match (. arg i)
      val (tset config.keys flag val)
      nil (do (io.stderr:write "fenneldoc: expected value for " flag "\n")
              (os.exit -1)))))

(fn* handle-file
  ([file files] (handle-file file files false))
  ([file files no-check]
   (when (and (not no-check) (= (string.sub file 1 2) :--))
     (io.stderr:write "fenneldoc: unknown flag " file "\n")
     (os.exit -1))
   (table.insert files file)))

(fn* handle-fennel-path [i]
  (match (. arg (inc i))
    val (set fennel.path (.. val ";" fennel.path))
    nil (do (io.stderr:write "fenneldoc: expected value for --add-fennel-path\n")
            (os.exit -1))))

(fn* write-config [config]
  (match (io.open ".fenneldoc" :w)
    f (with-open [file f]
        (let [version config.fenneldoc-version]
          (set config.fenneldoc-version nil)
          (file:write ";; -*- mode: fennel; -*- vi:ft=fennel\n"
                      ";; Configuration file for Fenneldoc " version "\n"
                      ";; https://gitlab.com/andreyorst/fenneldoc\n\n"
                      (pick-values 1 (: (fennel.view config) :gsub "\\\n" "\n"))
                      "\n")
          (set config.fenneldoc-version version)))
    (nil msg code) (do (io.stderr:write "Error opening file '.fenneldoc': " msg " (" code ")\n")
                       (os.exit code))))

(fn* process-args
  "Process command line arguments based on `config`. "
  [config]
  (let [files []
        arglen (length arg)]
    (var i 1)
    (var write-config? false)
    (while (<= i arglen)
      (match (. arg i)
        (flag ? (. bool-flags-set flag)) (handle-bool-flag flag config)
        (flag ? (. key-flags flag)) (do (set i (inc i))
                                        (handle-key-flag i flag config))
        (flag ? (. value-flags flag)) (do (set i (inc i))
                                          (handle-value-flag i flag config))
        :--add-fennel-path (do (set i (inc i))
                               (handle-fennel-path i))
        :--config (set write-config? true)
        :-- (do (set i (inc i))
                (lua :break))
        :--check-only (handle-bool-flag :--check-only config)
        :--skip-check (handle-bool-flag :--skip-check config)
        :--help (help)
        file (handle-file file files))
      (set i (inc i)))

    (when write-config?
      (write-config config))

    ;; in case `--` was passed we need to add remaining keys as files
    (while (<= i arglen)
      (handle-file (. arg i) files true)
      (set i (inc i)))

    (for [i 1 arglen]
      (tset arg i nil))

    (values files config)))

process-args

;; LocalWords:  descr fn fenneldoc checkdoc config args
