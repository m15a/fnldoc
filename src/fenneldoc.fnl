(local fenneldoc {})

(local process-config (require :config))
(local process-args (require :args))
(local test-module (require :doctest))
(local write-doc (require :writer))
(local {: module-info} (require :parser))
(local {: gen-markdown} (require :markdown))

(import-macros {: defn} :cljlib)

(defn process-file
  "Accepts `file` as path to some Fennel module, and `config` table.
Generates module documentation and writes it to `file` with `.md`
extension, creating it if not exists."
  [file config]
  (match (module-info file config)
    module (do (when (not= config.mode :doc)
                 (test-module module config))
               (let [markdown (gen-markdown module config)]
                 (when (not= config.mode :check)
                   (write-doc markdown file module config))))
    _ (io.stderr:write "skipping " file "\n")))

(let [(files config) (-> FENNELDOC_VERSION
                         process-config
                         process-args)]
  (each [_ file (ipairs files)]
    (process-file file config)))

fenneldoc

;; LocalWords:  Andrey Listopadov Fenneldoc metadata runtime config md
;; LocalWords:  fnl args doctest
