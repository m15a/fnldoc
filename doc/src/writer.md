# Writer.fnl

Function signature:

```
(writer ([docs file module-info config]))
```

Accepts `docs` as a vector of lines, and a path to a `file`.
Concatenates lines in `docs` with newline, and writes result to
`file`.  `module-info` must contain `module` key with file, and
`config` must contain `out-dir` key.



<!-- Generated with Fenneldoc v0.1.8
     https://gitlab.com/andreyorst/fenneldoc -->
