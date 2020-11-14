(local fennel (require :fennel))
(local utils (require :fennel.utils))

(fn capitalize [str]
  (.. (string.upper (string.sub str 1 1)) (string.sub str 2 -1)))

(fn process-file [file]
  (let [module (-> file
                   (string.gsub "/" ".")
                   (string.gsub ".fnl$" "")
                   require)
        result {:module (-> file
                            (string.gsub ".*/" "")
                            (capitalize))
                :docs {}}
        docs result.docs]
    (each [id val (pairs module)]
      (tset docs id {:docs  (fennel.metadata:get val :fnl/docstring)
                     :args (fennel.metadata:get val :fnl/arglist)}))
    result))

(fn table.append [t val]
  (doto t (table.insert val)))

(fn gen-markdown [module-info]
  (let [lines [(.. "# " module-info.module) ""]]
    (each [item {: docs : args} (utils.stablepairs module-info.docs)]
      (table.append lines (.. "## `" item "`"))
      (when args
        (-> lines
            (table.append "Function signature:")
            (table.append "")
            (table.append "``` fennel")
            (table.append (.. "(" item " " (table.concat args " ") ")"))
            (table.append "```")
            (table.append "")))
      (-> lines
          (table.append (if docs
                            (pick-values
                             1
                             (-> docs
                                 (string.gsub "^#" "##")))
                            "**Undocumented**"))
          (table.append "")))
    lines))

(each [_ file (ipairs arg)]
  (-> file
      process-file
      gen-markdown
      (table.concat "\n")
      print))
