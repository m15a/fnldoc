# Config.fnl
Function signature:

```
(config)
```

Process configuration file and merge it with default configuration.
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
 :out-dir "./doc"
 :silent false}
```



<!-- Generated with Fenneldoc 0.0.4
     https://gitlab.com/andreyorst/fenneldoc -->
