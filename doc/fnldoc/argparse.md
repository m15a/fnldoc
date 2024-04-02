# Argparse.fnl (1.1.0-dev)

Process command line arguments.

**Table of contents**

- Function: [help](#function-help)
- Function: [option-recipes.--inline-references.validator](#function-option-recipes-inline-referencesvalidator)
- Function: [option-recipes.--mode.validator](#function-option-recipes-modevalidator)
- Function: [option-recipes.--order.validator](#function-option-recipes-ordervalidator)
- Function: [parse](#function-parse)

## Function: help

```fennel
(help color?)
```

Generate help message, decorated with ANSI escape code if `color?` is truthy.

## Function: option-recipes.--inline-references.validator

```fennel
(option-recipes.--inline-references.validator x_17_auto)
```

**Undocumented**

## Function: option-recipes.--mode.validator

```fennel
(option-recipes.--mode.validator x_17_auto)
```

**Undocumented**

## Function: option-recipes.--order.validator

```fennel
(option-recipes.--order.validator x_17_auto)
```

**Undocumented**

## Function: parse

```fennel
(parse args)
```

Parse command line `args` and return its result.

The result contains attributes:

- `write-config?`: Whether to write configuration, after merged with that
  coming from `.fenneldoc`, to `.fenneldoc`.
- `show-help?`: Whether to show Fnldoc help and exit.
- `show-version?`: Whether to show Fnldoc version and exit.
- `config`: Parsed configuration that will be merged into that coming from
  `.fenneldoc`.
- `files`: Target Fennel file names, which will be processed by Fnldoc.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
