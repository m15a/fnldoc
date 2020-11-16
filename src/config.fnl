(local fennel (require :fennel))

(local default-config {:keys {:version :_VERSION
                              :description :_DESCRIPTION
                              :license :_LICENSE
                              :copyright :_COPYRIGHT}
                       :insert-comment true
                       :insert-version true
                       :insert-license true
                       :insert-copyright true
                       :function-signatures true
                       :toc true
                       :out-dir "./doc"
                       :silent false})

(fn process-config []
  "Process configuration file and merge it with default configuration.
Configuration is stored in `.fenneldoc` which is looked up in the
working directory.

Default configuration:

``` fennel
{:keys {:version :_VERSION
        :description :_DESCRIPTION
        :license :_LICENSE
        :copyright :_COPYRIGHT}
 :insert-comment true
 :insert-version true
 :insert-license true
 :insert-copyright true
 :function-signatures true
 :toc true
 :out-dir \"./doc\"
 :silent false}
```"
  (match (pcall fennel.dofile :.fenneldoc)
    (true rc) (each [k v (pairs rc)]
                (tset default-config k v))
    (false msg) (when (not (msg:match ".fenneldoc: No such file or directory"))
                  (io.stderr:write (.. msg "\n"))))
  default-config)
