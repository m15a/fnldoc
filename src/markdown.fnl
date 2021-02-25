(import-macros {: into : fn*} :cljlib.macros)
(local {: ordered-set
        : apply
        : seq
        : conj
        : keys
        : string?}
       (require :cljlib))


(fn* gen-info-comment [lines config]
  (when config.insert-comment
    (conj lines
          ""
          (.. "<!-- Generated with Fenneldoc " config.fenneldoc-version)
          "     https://gitlab.com/andreyorst/fenneldoc -->"
          ""))
  lines)


(fn* gen-function-signature [lines item arglist config]
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


(fn* gen-license-info [lines license config]
  (when (and config.insert-license license)
    (conj lines (.. "License: " license) ""))
  lines)


(fn* gen-copyright-info [lines copyright config]
  (when (and config.insert-copyright copyright)
    (conj lines copyright ""))
  lines)


(fn* extract-inline-code-references [docstring]
  (icollect [s (docstring:gmatch "`([%a_][^`']-)'")]
    s))


(fn* gen-cross-links [docstring toc mode]
  (var docstring docstring)
  (each [_ item (ipairs (extract-inline-code-references docstring))]
    (let [pat (item:gsub "([().%+-*?[^$])" "%%%1")] ; escaping Lua's patterns with `%`
      (set docstring
           (match mode
             :link (match (. toc item)
                     link-id (docstring:gsub (.. "`" pat "'") (.. "[`" item "`](" link-id ")"))
                     _ (docstring:gsub (.. "`" pat "'") (.. "`" item "`")))
             :code (docstring:gsub (.. "`" pat "'") (.. "`" item "`"))
             _ docstring))))
  docstring)


(fn* gen-item-documentation [lines docstring toc mode]
  "Generate documentation from `docstring` and `conj` it to `lines`.

`lines` must be a sequential table.
`toc` is a table of headings to ids.
`mode` is a mode to handle inline references."
  (conj lines
        (if (string? docstring)
            (-> (docstring:gsub "# " "### ")
                (gen-cross-links toc mode))
            "**Undocumented**")
        ""))


(fn* sorter [config]
  (match config.doc-order
    :alphabetic nil
    :reverse-alphabetic #(> $1 $2)
    (func ? (= (type func) :function)) func
    else (do (io.stderr:write "Unsupported sorting algorithm: '"
                              else
                              "'\nSupported algorithms: alphabetic, reverse-alphabetic, or function.\n")
             (os.exit -1))
    nil nil))


(fn* get-ordered-items [module-info config]
  (let [ordered-items (apply ordered-set (or module-info.doc-order []))
        sorted-items (doto (keys module-info.items)
                       (table.sort (sorter config)))]
    (into [] (into ordered-items sorted-items))))

(fn* heading-link
  "Markdown valid heading."
  [heading]
  (let [link (-> heading
                 (string.gsub "%." "")
                 (string.gsub " " "-")
                 (string.gsub "[^%w-]" "")
                 (string.gsub "[-]+" "-")
                 (string.gsub "^[-]*(.+)[-]*$" "%1")
                 string.lower)]
    (when (not= "" link)
      ;; Empty links may occur if we pass only restricted chars.
      ;; Such links are ignored.
      (.. "#" link))))

(fn* toc-table [items]
  (let [toc {}
        seen-headings {}]
    (each [_ item (ipairs items)]
      (match (heading-link item)
        heading (let [id (. seen-headings heading)
                      link (.. heading (if id (.. "-" id) ""))]
                  (tset seen-headings heading (+ (or id 0) 1))
                  (tset toc item link))))
    toc))

(fn* gen-toc [lines toc ordered-items config]
  (when (and config.toc toc (next toc))
    (conj lines
          "**Table of contents**"
          "")
    (each [_ item (ipairs ordered-items)]
      (match (. toc item)
        link (conj lines (.. "- [`" item "`](" link ")"))
        _ (conj lines (.. "- `" item "`"))))
    (conj lines ""))
  lines)


(fn* gen-items-doc [lines ordered-items toc module-info config]
  (each [_ item (ipairs ordered-items)]
    (match (. module-info.items item)
      info (-> (conj lines (.. "## `" item "`"))
               (gen-function-signature item info.arglist config)
               (gen-item-documentation info.docstring toc config.inline-references))
      nil (print (.. "WARNING: Could not find '" item "' in " module-info.module)))))


(fn* module-version [module-info]
  (match module-info.version
    version (.. " (" version ")")
    _ ""))


(fn* capitalize [str]
  (.. (string.upper (str:sub 1 1)) (str:sub 2 -1)))


(fn* module-heading [file]
  (.. "# " (capitalize (pick-values 1 (string.gsub file ".*/" "")))))

(fn* gen-markdown
  "Generate markdown feom `module-info` accordingly to `config`."
  [module-info config]
  (let [ordered-items (get-ordered-items module-info config)
        toc-table (toc-table ordered-items)
        lines [(.. (module-heading module-info.module) (module-version module-info))]]

    (when module-info.description
      (->> (gen-cross-links module-info.description
                            toc-table
                            config.inline-references)
           (conj lines)))

    (-> (conj lines "")
        (gen-toc toc-table ordered-items config)
        (gen-items-doc ordered-items toc-table module-info config))

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

(setmetatable
 {: gen-markdown
  :gen-item-documentation
  (fn* [docstring mode]
       "Generate documentation from `docstring`, and handle inline references
based on `mode`."
       (table.concat
        (gen-item-documentation [] docstring {} mode)
        "\n"))
  :gen-function-signature
  (fn* [function arglist config]
       "Generate function signature for `function` from `arglist` accordingly to `config`."
       (table.concat
        (gen-function-signature [] function arglist config)
        "\n"))}
 {:__index {:_DESCRIPTION "Functions for generating Markdown"}})

;; LocalWords:  Fenneldoc Lua's docstring arglist config
