(local utils (require :fennel.utils))


(fn append [t val]
  (doto t (table.insert val)))


(fn gen-info-comment [lines config]
  (when config.insert-comment
    (-> lines
        (append (.. "<!-- Generated with Fenneldoc " config.fenneldoc-version))
        (append     "     https://gitlab.com/andreyorst/fenneldoc -->")
        (append "")))
  lines)


(fn gen-function-signature [lines item arglist config]
  (when (and config.function-signatures arglist)
    (let [arglist (table.concat arglist " ")]
      (-> lines
          (append "Function signature:")
          (append "")
          (append "```")
          (append (.. "(" item (if (= arglist "") "" " ")  arglist ")"))
          (append "```")
          (append ""))))
  lines)


(fn gen-toc [lines contents config]
  (when (and config.toc contents (next contents))
    (append lines "**Table of contents**")
    (each [item _ (utils.stablepairs contents)]
      (append lines (.. "- [`" item "`](#" item ")")))
    (append lines ""))
  lines)


(fn gen-item-documentation [lines docstring]
  "Generate documentation feom `docstring` and append it to `lines`.

`lines` must be a sequential table."
  (-> lines
      (append (if docstring (pick-values 1 (docstring:gsub "\n#" "\n###"))
                  "**Undocumented**"))
      (append "")))


(fn gen-markdown [module-info config]
  "Generate markdown feom `module-info` accordingly to `config`."
  (let [lines [(.. "# " module-info.module
                   (match module-info.version
                     version (.. " (" version ")")
                     _ ""))]]
    (-?>> module-info.description
          (append lines))

    (-> lines
        (append "")
        (gen-toc module-info.items config))

    (each [item {: docstring : arglist} (utils.stablepairs module-info.items)]
      (-> lines
          (append (.. "## `" item "`"))
          (gen-function-signature item arglist config)
          (gen-item-documentation docstring)))

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
 :_DESCRIPTION
 "Functions for generating Markdown"}
