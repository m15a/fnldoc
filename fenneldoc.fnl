(local fenneldoc {:_VERSION "0.0.1"
                  :_DESCRIPTION "Fenneldoc - generate documentation for Fennel projects."
                  :_COPYRIGHT "Copyright (C) 2020 Andrey Orst"})

(local fennel (require :fennel))
(local utils (require :fennel.utils))
(local fs (require :lfs))

(fn capitalize [str]
  (.. (string.upper (string.sub str 1 1))
      (string.sub str 2 -1)))

(fn require-module [module]
  (let [(module? mod#) (pcall require module)]
    [module? mod#]))

(fn process-file [file]
  (let [[module? module] (-> file
                             (string.gsub "/" ".")
                             (string.gsub ".fnl$" "")
                             require-module)
        result {:module (-> file
                            (string.gsub ".*/" "")
                            (capitalize))
                :docs {}}
        docs result.docs]
    (match (or module._DESCRIPTION
               module.description
               module.documentation
               module._DOCUMENTATION)
      descr (tset result :description descr))
    (match (or module._VERSION
               module.version)
      version (tset result :version version))
    (if module?
        (each [id val (pairs module)]
          (when (not= (string.sub id 1 1) :_)
            (tset docs id {:docs (fennel.metadata:get val :fnl/docstring)
                           :args (fennel.metadata:get val :fnl/arglist)})))
        (do (io.stderr:write (.. "Error loading file " file))
            (io.stderr:write module)))
    result))

(fn table.append [t pos val]
  (if val
      (doto t (table.insert pos val))
      (doto t (table.insert pos))))

(fn gen-markdown [module-info]
  (let [lines [(.. "# " module-info.module)]]
    (-?>> module-info.description
          (table.append lines))
    (match module-info.version
      version (-> lines
                  (table.append "")
                  (table.append (.. "Documentation for version: " version))))
    (table.append lines "")
    (each [item {: docs : args} (utils.stablepairs module-info.docs)]
      (table.append lines (.. "## `" item "`"))
      (when args
        (-> lines
            (table.append "Function signature:")
            (table.append "")
            (table.append "```")
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
    (-> lines
        (table.append "")
        (table.append (.. "<!-- Generated with Fenneldoc " fenneldoc._VERSION "-->")))
    lines))

(fn string.split [s seps]
  (let [seps (or seps "%s")
        res []]
    (each [s _ (s:gmatch (.. "[^" seps "]+"))]
      (table.insert res s))
    res))

(fn create-file-and-dirs [file version?]
  (let [path (file:gsub "[^\\/]+.fnl$" "")
        fname (-> file
                  (string.gsub path "")
                  (string.gsub ".fnl$" ".md"))
        dirs (-> (string.split path "\\/")
                 (table.append 1 "doc"))
        olddir (fs.currentdir)]
    (when version?
      (table.insert dirs 2 version?))
    (each [_ dir (ipairs dirs)]
      (fs.mkdir dir)
      (fs.chdir dir))
    (fs.chdir olddir)
    (.. (table.concat dirs "/") "/" fname)))

(fn write-doc [docs file]
  (with-open [file (io.open file :w)]
    (file:write (table.concat docs "\n"))))

(each [_ file (ipairs arg)]
  (let [processed (process-file file)
        markdown (gen-markdown processed)]
    (write-doc markdown (create-file-and-dirs file processed.version))))
