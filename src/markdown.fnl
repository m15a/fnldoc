(import-macros {: into} :cljlib-macros)
(local {: ordered-set
        : apply
        : seq
        : conj
        : keys
        : string?}
       (require :cljlib))


(fn gen-info-comment [lines config]
  (when config.insert-comment
    (conj lines
          ""
          (.. "<!-- Generated with Fenneldoc " config.fenneldoc-version)
          "     https://gitlab.com/andreyorst/fenneldoc -->"
          ""))
  lines)


(fn gen-function-signature [lines item arglist config]
  (when (and config.function-signatures arglist)
    (let [arglist (table.concat arglist " ")]
      (conj lines
            "Function signature:"
            ""
            "```"
            (.. "(" item (if (= arglist "") "" " ")  arglist ")")
            "```"
            "")))
  lines)


(fn gen-license-info [lines license config]
  (when (and config.insert-license license)
    (conj lines (.. "License: " license) ""))
  lines)


(fn gen-copyright-info [lines copyright config]
  (when (and config.insert-copyright copyright)
    (conj lines copyright ""))
  lines)


(fn gen-item-documentation [lines docstring]
  "Generate documentation from `docstring` and `conj` it to `lines`.

`lines` must be a sequential table."
  (conj lines
        (if (string? docstring)
            (docstring:gsub "# " "### ")
            "**Undocumented**")
        ""))


(fn sorter [config]
  (match config.doc-order
    :alphabetic nil
    :reverse-alphabetic #(> $1 $2)
    (func ? (= (type func) :function)) func
    else (do (io.stderr:write (.. "Unsupported sorting algorithm: '"
                                  else
                                  "'\nSupported alghorithms: alphabetic, reverse-alphabetic, or function.\n"))
             (os.exit -1))
    nil nil))


(fn get-ordered-items [module-info config]
  (let [ordered-items (apply ordered-set (or module-info.doc-order []))
        sorted-items (doto (keys module-info.items)
                       (table.sort (sorter config)))]
    (into [] (into ordered-items sorted-items))))


(fn gen-toc [lines items config]
  (when (and config.toc items (next items))
    (conj lines
          "**Table of contents**"
          "")
    (each [_ item (ipairs items)]
      (conj lines (.. "- [`" item "`](#" item ")")))
    (conj lines ""))
  lines)


(fn gen-items-doc [lines ordered-items module-info config]
  (each [_ item (ipairs ordered-items)]
    (match (. module-info.items item)
      info (-> (conj lines (.. "## `" item "`"))
               (gen-function-signature item info.arglist config)
               (gen-item-documentation info.docstring))
      nil (print (.. "WARNING: Could not find '" item "' in " module-info.module)))))


(fn module-version [module-info]
  (match module-info.version
    version (.. " (" version ")")
    _ ""))


(fn capitalize [str]
  (.. (string.upper (str:sub 1 1)) (str:sub 2 -1)))


(fn module-heading [file]
  (.. "# " (capitalize (string.gsub file ".*/" ""))))


(fn gen-markdown [module-info config]
  "Generate markdown feom `module-info` accordingly to `config`."
  (let [ordered-items (get-ordered-items module-info config)
        lines [(.. (module-heading module-info.module) (module-version module-info))]]

    (-?>> module-info.description
          (conj lines))

    (-> (conj lines "")
        (gen-toc ordered-items config)
        (gen-items-doc ordered-items module-info config))

    (when (and (or module-info.copyright module-info.license)
               (or config.insert-copyright config.insert-license))
      (-> (conj lines
                ""
                "---"
                "")
          (gen-copyright-info module-info.copyright config)
          (gen-license-info module-info.license config)))

    (-> lines
        (gen-info-comment config)
        (table.concat "\n"))))

{: gen-markdown
 :gen-item-documentation
 (fn [docstring]
   "Generate documentation from `docstring`."
   (table.concat
    (gen-item-documentation [] docstring)
    "\n"))
 :gen-function-signature
 (fn [function arglist config]
   "Generate function signature for `function` from `arglist` accordingly to `config`."
   (table.concat
    (gen-function-signature [] function arglist config)
    "\n"))
 :_DOC_ORDER [:gen-markdown :gen-function-signature]
 :_DESCRIPTION
 "Functions for generating Markdown"}
