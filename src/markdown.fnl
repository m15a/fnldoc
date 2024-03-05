(import-macros
 {: defn- : defn : fn* : ns : if-let}
 (doto :lib.cljlib require))

(ns markdown
  "Functions for generating Markdown"
  (:require
   [lib.cljlib
    :refer
    [distinct apply seq sort conj string? concat]]))

(defn- gen-info-comment [lines config]
  (if config.insert-comment
      (conj lines
            ""
            (.. "<!-- Generated with Fenneldoc " config.fenneldoc-version)
            "     https://gitlab.com/andreyorst/fenneldoc -->"
            "")
      lines))


(defn- gen-function-signature*
  "Generate function signature for `function` from `arglist` accordingly to `config`."
  [lines item arglist config]
  (if-let [arglist (and config.function-signatures
                        arglist
                        (table.concat arglist " "))]
    (conj lines
          "Function signature:"
          ""
          "```"
          (.. "(" item (if (= arglist "") "" " ")  arglist ")")
          "```"
          "")
    lines))


(defn- gen-license-info [lines license config]
  (if (and config.insert-license license)
      (conj lines (.. "License: " license) "")
      lines))


(defn- gen-copyright-info [lines copyright config]
  (if (and config.insert-copyright copyright)
      (conj lines copyright "")
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
  "Generate documentation from `docstring` and `conj` it to `lines`.

`lines` must be a sequential table.
`toc` is a table of headings to ids.
`mode` is a mode to handle inline references."
  [lines docstring toc mode]
  (conj lines
        (if (string? docstring)
            (-> docstring
                (remove-test-skip)
                (increment-section-header-level)
                (gen-cross-links toc mode))
            "**Undocumented**")
        ""))


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
        sorted-items (sort (sorter config) (icollect [k _ (pairs module-info.items)] k))]
    (distinct (concat ordered-items sorted-items))))

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
                      (conj lines
                            "**Table of contents**"
                            "")
                      lines)
            lines (if (and config.toc toc (next toc))
                      (accumulate [lines lines _ item (ipairs (seq ordered-items))]
                        (match (. toc item)
                          link (conj lines (.. "- [`" item "`](" link ")"))
                          _ (conj lines (.. "- `" item "`"))))
                      lines)]
        (conj lines ""))
      lines))


(defn- gen-items-doc [lines ordered-items toc module-info config]
  (accumulate [lines lines _ item (ipairs (seq ordered-items))]
    (match (. module-info.items item)
      info (-> (conj lines (.. "## `" item "`"))
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
                  (->> (gen-cross-links module-info.description
                                        toc-table
                                        config.inline-references)
                       (conj lines))
                  lines)
        lines (-> (conj lines "")
                  (gen-toc toc-table ordered-items config)
                  (gen-items-doc ordered-items toc-table module-info config))

        lines (if (and (or module-info.copyright module-info.license)
                       (or config.insert-copyright config.insert-license))
                  (-> (conj lines
                            ""
                            "---"
                            "")
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
