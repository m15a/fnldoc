(local fennel (require :fennel))

(local config {:insert-comment true
               :insert-version true
               :version-key :_VERSION
               :description-key :_DESCRIPTION
               :function-signatures true
               :silent false
               :toc true})

(fn process-config []
  (match (pcall fennel.dofile :.fenneldoc)
    (true rc) (each [k v (pairs rc)]
                (tset config k v))
    (false msg) (when (not (msg:match ".fenneldoc: No such file or directory"))
                  (io.stderr:write (.. msg "\n"))))
  config)
