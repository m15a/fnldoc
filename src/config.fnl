(local fennel (require :fennel))

(local config {:keys {:version :_VERSION
                      :description :_DESCRIPTION
                      :license :_LICENSE
                      :copyright :_COPYRIGHT
                      :doc-order :_DOC_ORDER
                      :module-name :_MODULE_NAME}
               :insert-comment true
               :insert-version true
               :insert-license true
               :insert-copyright true
               :function-signatures true
               :order :aplhabetic
               :toc true
               :out-dir "./doc"
               :fennel-path []
               :silent false})

(fn process-config [version]
  "Process configuration file and merge it with default configuration.
Configuration is stored in `.fenneldoc` which is looked up in the
working directory.

Default configuration:

``` fennel
{:keys {:version :_VERSION
        :description :_DESCRIPTION
        :license :_LICENSE
        :copyright :_COPYRIGHT
        :doc-order :_DOC_ORDER}
 :insert-comment true
 :insert-version true
 :insert-license true
 :insert-copyright true
 :function-signatures true
 :order :aplhabetic
 :toc true
 :out-dir \"./doc\"
 :fennel-path []
 :silent false}
```"
  (match (pcall fennel.dofile :.fenneldoc)
    (true rc) (each [k v (pairs rc)]
                (tset config k v))
    (false msg) (when (not (msg:match ".fenneldoc: No such file or directory"))
                  (io.stderr:write (.. msg "\n"))))

  (each [_ path (pairs config.fennel-path)]
    (set fennel.path (.. path ";" fennel.path)))

  (set config.fenneldoc-version version)
  config)
