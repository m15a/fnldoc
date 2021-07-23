(import-macros {: defn} :cljlib)

(fn file-exists? [path]
  (if (or (= "./" path) (= "../" path))
      true
      (match (os.rename path path)
        (true _ 13) true
        (true _ _) true
        _ false)))

(defn create-dirs-from-path [file module-info config]
  ;; Creates path up to specified file.
  (let [sep (package.config:sub 1 1)
        path (.. config.out-dir sep (file:gsub (.. "[^" sep "]+.fnl$") ""))
        fname (-> (or module-info.module file)
                  (string.gsub (.. ".*[" sep "]+") "")
                  (string.gsub ".fnl$" "")
                  (.. ".md"))]
    (var p "")
    (each [dir (path:gmatch (.. "[^" sep "]+"))]
      (set p (.. p dir sep))
      (when (not (file-exists? p))
        (match (os.execute (.. "mkdir " p))
          (nil _ code) (lua "return nil, p"))))
    (-> (.. p sep fname)
        (string.gsub (.. "[" sep "]+") sep))))

(defn writer
  "Accepts `docs` as a vector of lines, and a path to a `file`.
Concatenates lines in `docs` with newline, and writes result to
`file`.  `module-info` must contain `module` key with file, and
`config` must contain `out-dir` key."
  [docs file module-info config]
  (match (create-dirs-from-path file module-info config)
    path (match (io.open path :w)
           f (with-open [file f]
               (file:write docs))
           (nil msg code) (do (io.stderr:write
                               (.. "Error opening file '" path "': " msg " (" code ")\n"))
                              (os.exit code)))

    (nil dir) (do (io.stderr:write
                   (.. "Error creating directory '" dir))
                  (os.exit code))))

writer

;; LocalWords:  fnl md dir msg config
