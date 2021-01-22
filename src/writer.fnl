(local fs (require :lfs))

(fn create-dirs-from-path [file module config]
  "Creates path up to specified file."
  (let [sep (package.config:sub 1 1)
        path (.. config.out-dir sep (file:gsub (.. "[^" sep "]+.fnl$") ""))
        fname (-> (or module.module file)
                  (string.gsub (.. ".*[" sep "]+") "")
                  (string.gsub ".fnl$" "")
                  (.. ".md"))]
    (var p "")
    (each [dir (path:gmatch (.. "[^" sep "]+"))]
      (set p (.. p dir sep))
      (match (fs.mkdir p)
        (nil "File exists" 17) nil
        (nil msg code) (lua "return nil, dir, msg, code")))
    (-> (.. p sep fname)
        (string.gsub (.. "[" sep "]+") sep))))

(fn write-doc [docs file module config]
  "Accepts `docs` as a vector of lines, and a path to a `file`.
Concatenates lines in `docs` with newline, and writes result to
`file`."
  (match (create-dirs-from-path file module config)
    path (match (io.open path :w)
           f (with-open [file f]
               (file:write docs))
           (nil msg code) (do (io.stderr:write
                               (.. "Error opening file '" path "': " msg " (" code ")\n"))
                              (os.exit code)))

    (nil dir msg code) (do (io.stderr:write
                            (.. "Error creating directory '" dir "': " msg " (" code ")\n"))
                           (os.exit code))))
