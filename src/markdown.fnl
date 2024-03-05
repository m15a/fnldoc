(import-macros
 {: defn- : defn : fn* : ns : if-let}
 (doto :lib.cljlib require))

(ns markdown
  "Functions for generating Markdown"
  (:require
   [lib.cljlib
    :refer
    [seq]]))

(defn- gen-info-comment [lines config]
  (if config.insert-comment
      (doto lines
        (table.insert "")
        (table.insert (.. "<!-- Generated with Fenneldoc " config.fenneldoc-version))
        (table.insert "     https://gitlab.com/andreyorst/fenneldoc -->")
        (table.insert ""))
      lines))


(defn- gen-function-signature*
  "Generate function signature for `function` from `arglist` accordingly to `config`."
  [lines item arglist config]
  (if-let [arglist (and config.function-signatures
                        arglist
                        (table.concat arglist " "))]
    (doto lines
      (table.insert "Function signature:")
      (table.insert "")
      (table.insert "```")
      (table.insert (.. "(" item (if (= arglist "") "" " ")  arglist ")"))
      (table.insert "```")
      (table.insert ""))
    lines))


(defn- gen-license-info [lines license config]
  (if (and config.insert-license license)
      (doto lines
        (table.insert (.. "License: " license))
        (table.insert ""))
      lines))


(defn- gen-copyright-info [lines copyright config]
  (if (and config.insert-copyright copyright)
      (doto lines
        (table.insert copyright)
        (table.insert ""))
      lines))


(defn- extract-inline-code-references [docstring]
  (icollect [s (docstring:gmatch "`([%a_][^`']-)'")]
    s))


(defn- gen-cross-links [docstring toc mode]
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

(defn- remove-test-skip [docstring]
  (if (string.match docstring "\n?%s*```%s*fennel[ \t]+:skip%-test")
      (pick-values 1 (string.gsub docstring "(\n?%s*```%s*fennel)[ \t]+:skip%-test" "%1"))
      docstring))

(defn- increment-section-header-level [docstring]
  (let [increment-top-section-header-level
        #(if (: $ :match "^%s*#+ ") (: $ :gsub "(^%s*#+) " "%1## ") $)
        increment-line-start-section-header-level
        #(if (: $ :match "\n%s*#+ ") (: $ :gsub "(\n%s*#+) " "%1## ") $)]
    (-> docstring
        (increment-top-section-header-level)
        (increment-line-start-section-header-level))))

(defn- gen-item-documentation*
  "Generate documentation from `docstring` and append it to `lines`.

`lines` must be a sequential table.
`toc` is a table of headings to ids.
`mode` is a mode to handle inline references."
  [lines docstring toc mode]
  (doto lines
    (table.insert (if (= :string (type docstring))
                      (-> docstring
                          (remove-test-skip)
                          (increment-section-header-level)
                          (gen-cross-links toc mode))
                      "**Undocumented**"))
    (table.insert "")))


(defn- sorter [config]
  (match config.doc-order
    :alphabetic nil
    :reverse-alphabetic #(> $1 $2)
    (func ? (= (type func) :function)) func
    else (do (io.stderr:write "Unsupported sorting algorithm: '"
                              else
                              "'\nSupported algorithms: alphabetic, reverse-alphabetic, or function.\n")
             (os.exit -1))
    nil nil))


(defn- get-ordered-items [module-info config]
  (let [ordered-items (or module-info.doc-order [])
        sorted-items (doto (icollect [k _ (pairs module-info.items)] k)
                       (table.sort (sorter config)))
        found {}
        result []]
    (each [_ item (ipairs ordered-items)]
      (when (not (. found item))
        (tset found item true)
        (table.insert result item)))
    (each [_ item (ipairs sorted-items)]
      (when (not (. found item))
        (tset found item true)
        (table.insert result item)))
    result))

(defn- heading-link
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

(defn- toc-table [items]
  (let [toc {}
        seen-headings {}]
    (each [_ item (ipairs items)]
      (match (heading-link item)
        heading (let [id (. seen-headings heading)
                      link (.. heading (if id (.. "-" id) ""))]
                  (tset seen-headings heading (+ (or id 0) 1))
                  (tset toc item link))))
    toc))

(defn- gen-toc [lines toc ordered-items config]
  (if (and config.toc toc (next toc))
      (let [lines (if (and config.toc toc (next toc))
                      (doto lines
                        (table.insert "**Table of contents**")
                        (table.insert ""))
                      lines)
            lines (if (and config.toc toc (next toc))
                      (accumulate [lines lines _ item (ipairs (seq ordered-items))]
                        (match (. toc item)
                          link (doto lines (table.insert (.. "- [`" item "`](" link ")")))
                          _ (doto lines (table.insert (.. "- `" item "`")))))
                      lines)]
        (doto lines (table.insert "")))
      lines))


(defn- gen-items-doc [lines ordered-items toc module-info config]
  (accumulate [lines lines _ item (ipairs (seq ordered-items))]
    (match (. module-info.items item)
      info (-> (doto lines (table.insert (.. "## `" item "`")))
               (gen-function-signature* item info.arglist config)
               (gen-item-documentation* info.docstring toc config.inline-references))
      nil (do (print (.. "WARNING: Could not find '" item "' in " module-info.module))
              lines))))


(defn- module-version [module-info]
  (match module-info.version
    version (.. " (" version ")")
    _ ""))


(defn- capitalize [str]
  (.. (string.upper (str:sub 1 1)) (str:sub 2 -1)))


(defn- module-heading [file]
  (.. "# " (capitalize (pick-values 1 (string.gsub file ".*/" "")))))

(defn gen-markdown
  "Generate markdown feom `module-info` accordingly to `config`."
  [module-info config]
  (let [ordered-items (get-ordered-items module-info config)
        toc-table (toc-table ordered-items)
        lines [(.. (module-heading module-info.module) (module-version module-info))]
        lines (if module-info.description
                  (doto lines
                    (table.insert (gen-cross-links module-info.description
                                                   toc-table
                                                   config.inline-references)))
                  lines)
        lines (-> (doto lines (table.insert ""))
                  (gen-toc toc-table ordered-items config)
                  (gen-items-doc ordered-items toc-table module-info config))

        lines (if (and (or module-info.copyright module-info.license)
                       (or config.insert-copyright config.insert-license))
                  (-> (doto lines
                        (table.insert "")
                        (table.insert "---")
                        (table.insert ""))
                      (gen-copyright-info module-info.copyright config)
                      (gen-license-info module-info.license config))
                  lines)]
    (-> lines
        (gen-info-comment config)
        (table.concat "\n"))))

(defn gen-item-documentation
  "Generate documentation from `docstring`, and handle inline references
based on `mode`."
  [docstring mode]
  (table.concat
   (gen-item-documentation* [] docstring {} mode)
   "\n"))

(defn gen-function-signature
  "Generate function signature for `function` from `arglist` accordingly to `config`."
  [function arglist config]
  (table.concat
   (gen-function-signature* [] function arglist config)
   "\n"))

markdown

;; LocalWords:  Fenneldoc Lua's docstring arglist config
