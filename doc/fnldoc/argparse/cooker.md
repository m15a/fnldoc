# Cooker.fnl (1.1.0-dev)


Generate command line argument option recipes.

Macros defined here generate a table that maps command line argument
flag to its *recipe*, which will be used later in command line argument
parsing.

You can generate option recipes, for example, by

```fennel
(cooking
  (recipe :boolean :ramen
    "Whether you like to have ramen noodles")
  (recipe :category :taste :t [:shoyu :miso :tonkotsu]
    "Which type of ramen you like to have")
  (recipe :number :bowls :n :NUM
    "How many ramen bowls you like to have"))
```

And, it yields

```fennel
{:--ramen {:description "--[no-]ramen\t\tWhether you like to have ramen noodles"
           :key :ramen?
           :value true}
 :--no-ramen {:key :ramen?
              :value false}
 :--taste {:description "-t, --taste\t[shoyu|miso|tonkotsu]\tWhich type of ramen you like to have (default: nil)"
           :key :taste
           :validator #<function: 0x7ffa16ead208>}
 :-t {:key :taste
      :validator #<function: 0x7ffa16e31310>}
 :--bowls {:description "-n, --bowls\tNUM\tHow many ramen bowls you like to have (default: nil)"
           :key :bowls
           :preprocessor #<function: builtin#17>
           :validator #<function: 0x7ffa16f984e8>}
 :-n {:key :bowls
      :preprocessor #<function: builtin#17>
      :validator #<function: 0x7ffa16de4a98>}}
```

It gives you no dishes, only recipes, unfortunately.

A recipe is a table that possibly contains the following entries,
depending on the needs.

- `key`: Corresponding key name in Fnldoc's configuration loaded from
  `.fenneldoc`.
- `description`: Text that explain the flag, which will be shown in help.
  Flag(s), argument if any, and description are separated by tab (`\t`).
- `value`: Options that do not require argument (e.g., boolean flags)
  have this entry. Its value will be set at the `key`'s field in
  configuration. If `value` is missing, the next command line argument
  will be parsed and set into configuration, possibly after calling
  `preprocessor` and `validator`.
- `preprocessor`: Function that converts the next command line argument
  string to a value that can be set into configuration. Currently only
  used for number options.
- `validator`: Function that checks if preprocessed value is valid.
  Currently only used for category and number options.

Read the document of [`recipe`](#macro-recipe) for more details of various option recipe
types.

**Table of contents**

- Macro: [`cooking`](#macro-cooking)
- Macro: [`recipe`](#macro-recipe)

## Macro: `cooking`

```
(cooking & recipes)
```

A helper macro to collect option `recipes` into one table.

## Macro: `recipe`

```
(recipe recipe-type & recipe-spec)
```

Make an option recipe of the given `recipe-type`.

The recipe type can be one of

- `boolean` (or `bool` for short-hand notation),
- `category` (or `cat`),
- `string` (or `str`), or
- `number` (or `num`).

### Boolean option recipe

Recipe for options that are either on or off.
`recipe-spec` should be *name description* or *name short-name description*.
The `name` will be expanded to positive flag `--name` and negative flag
`--no-name`. If it has `short-name`, a short name flag `-x`, where `x` is
the value of `short-name`, will also be created.

In command line argument parsing, a positive flag or a short name flag will
set corresponding entry in configuration (e.g., if a flag's `name` is
`:apple`, its `key` in the configuration is `:apple?`) to `true`, and a
negative flag set it to `false`.

### Category option recipe

Recipe for options whose value can be any one of a finite set.
`recipe-spec` should be *name domain description* or *name short-name domain
description*. The `name` will be expanded to flag `--name`. If it has
`short-name`, a short name flag will also be created.
The `domain` should be a sequential table of strings (e.g., `[:apple :banana
:orange]`).

In command line argument parsing, an option of this type will consume the
next argument, validate if the argument is one of `domain`'s items, and set
the corresponding entry in configuration to the argument's value.

### String option recipe

Recipe for simple string options.
`recipe-spec` should be *name VARNAME description* or *name short-name
VARNAME description*. The `name` will be expanded to flag `--name`. If it has
`short-name`, a short name flag will also be created.
`VARNAME` will be used to indicate the next command line argument that will
be consumed by this option parsing.

In command line argument parsing, this option will consume the next argument
and set corresponding entry in configuration to the argument's value.

### Number option recipe

Recipe for number options. `recipe-spec` is the same as the string option
recipe's.

In command line argument parsing, this option will consume the next argument,
convert the argument to a number, validate if it has been converted to number,
and set the corresponding entry in configuration to the converted number.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
