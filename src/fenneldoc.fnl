(local utils (require :fennel.utils))

(fn table.append [t pos val]
  (if val
      (doto t (table.insert pos val))
      (doto t (table.insert pos))))


(fn add-info-comment [lines config]
  (when config.insert-comment
    (lines:append "")
    (lines:append (.. "<!-- Generated with Fenneldoc " config.fenneldoc-version))
    (lines:append (.. "     https://gitlab.com/andreyorst/fenneldoc -->")))
  lines)


(fn add-function-signature [lines item args config]
  (when (and config.function-signatures args)
    (lines:append "Function signature:")
    (lines:append "")
    (lines:append "```")
    (lines:append (.. "(" item " " (table.concat args " ") ")"))
    (lines:append "```")
    (lines:append ""))
  lines)


(fn add-toc [lines contents config]
  (when (and config.toc contents (next contents))
    (lines:append "**Table of contents**")
    (each [item _ (utils.stablepairs contents)]
      (lines:append (.. "- [`" item "`](#" item ")")))
    (lines:append "")))


(fn add-item-documentation [lines item docs]
  (lines:append (if docs (pick-values 1 (docs:gsub "\n#" "\n###"))
                    "**Undocumented**"))
  (lines:append ""))


(fn fenneldoc [module-info config]
  (let [lines (setmetatable [(.. "# " module-info.module (match module-info.version
                                                           version (.. " (" version ")")
                                                           _ ""))]
                            {:__index table})]
    (-?>> module-info.description lines:append)

    (-> (lines:append "")
        (add-toc module-info.docs config))

    (each [item {: docs : args} (utils.stablepairs module-info.docs)]
      (-> (lines:append (.. "## `" item "`"))
          (add-function-signature item args config)
          (add-item-documentation item docs config)))
    (add-info-comment lines config)))
