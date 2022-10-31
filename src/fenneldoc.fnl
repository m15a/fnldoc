(import-macros {: defn : ns} :cljlib)
(ns fenneldoc
  "main ns"
  (:require
   [config :refer [process-config]]
   [argparse :refer [process-args]]
   [doctest :refer [test]]
   [parser :refer [module-info]]
   [markdown :refer [gen-markdown]]
   [writer :refer [write-docs]]))

(defn process-file
  "Accepts `file` as path to some Fennel module, and `config` table.
Generates module documentation and writes it to `file` with `.md`
extension, creating it if not exists."
  [file config]
  (match (module-info file config)
    module (do (when (not= config.mode :doc)
                 (test module config))
               (let [markdown (gen-markdown module config)]
                 (when (not= config.mode :check)
                   (write-docs markdown file module config))))
    _ (io.stderr:write "skipping " file "\n")))

(let [(files config) (-> FENNELDOC_VERSION
                         process-config
                         process-args)]
  (each [_ file (ipairs files)]
    (process-file file config)))

;; LocalWords:  Andrey Listopadov Fenneldoc metadata runtime config md
;; LocalWords:  fnl args doctest
