# Config.fnl
Function signature:

```
(config version)
```

Process configuration file and merge it with default configuration.
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
 :out-dir "./doc"
 :fennel-path []
 :silent false}
```



<!-- Generated with Fenneldoc 0.0.7
     https://gitlab.com/andreyorst/fenneldoc -->
