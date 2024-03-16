# Cooker.fnl (1.0.2-dev)

Generate command line argument flag recipes.

Macros defined here generate a table that maps command line argument flag
to its *recipe*, which will be used later in command line argument parsing.

You can generate flag recipes by

```fennel
(cooking
  (recipe :boolean :ramen
    "Whether you like to have ramen noodles")
  (recipe :category :taste :t [:shoyu :miso :tonkotsu]
    "Which type of ramen you like to have")
  (recipe :number :bowls :n :NUM
    "How many ramen bowls you like to have"))
```

which yields

```fennel
{:--ramen {:description "--[no-]ramen\t\tWhether you like to have ramen noodles"
           :key "ramen?"
           :value true}
 :--no-ramen {:key "ramen?"
              :value false}
 :--taste {:description "-t, --taste\t[shoyu|miso|tonkotsu]\tWhich type of ramen you like to have (default: nil)"
           :key "taste"
           :validator #<function: 0x7ffa16ead208>
           :consume-next? true}
 :-t {:key "taste"
      :validator #<function: 0x7ffa16e31310>
      :consume-next? true}
 :--bowls {:description "-n, --bowls\tNUM\tHow many ramen bowls you like to have (default: nil)"
           :key "bowls"
           :preprocessor #<function: builtin#17>
           :validator #<function: 0x7ffa16f984e8>
           :consume-next? true}
 :-n {:key "bowls"
      :preprocessor #<function: builtin#17>
      :validator #<function: 0x7ffa16de4a98>
      :consume-next? true}}
```

It gives you no dishes, only recipes, unfortunately.

A recipe is a table that possibly contains the following entries depending on the needs.

- `:key`: The corresponding key in the `config` object, i.e., `.fenneldoc`.
- `:description`: text that explain the flag, which will be shown in help. Flag(s),
  argument, and description are separated by tab character (`\t`).
- `:value`: If the flag is not nil, this value will be set; otherwise, the next command
  line argument will be set to the `:value`, possibly after calling `:preprocessor`
  and `:validator`.
- `:preprocessor`: A function that converts the next command line argument string to
  the `:value`. Only used for number flags.
- `:validator`: A function that checks if the `:value` is valid. This will be called
  after `:preprocessor` is called. Only used for category and number flags.

**Table of contents**

- [`cooking`](#cooking)
- [`recipe`](#recipe)

## `cooking`

Function signature:

```
(cooking & recipes)
```

A helper macro to collect option `recipes` into one table.

## `recipe`

Function signature:

```
(recipe recipe-type & recipe-spec)
```

Make an option recipe of given `recipe-type`.

The recipe type can be one of

* `boolean` (or `bool` for short-hand notation),
* `category` (or `cat`),
* `string` (or `str`), or
* `number` (or `num`).

### Boolean option recipe

`recipe-spec` should be `[name description]` or `[name short-name description]`.
The `name` will be expanded to positive flag `--name` and negative flag
`--no-name`. If it has `short-name`, a short name flag `-x`, where `x` is given
by the `short-name`, will also be created.

In command line argument parsing, a positive flag or a short name flag will
set the `config` object's corresponding attribute (e.g., if a flag's `name` is
`apple`, its attribute `key` in the `config` is `apple?`) to `true`, and a negative
flag set it to `false`.

### Category option recipe

`recipe-spec` should be `[name domain description]` or `[name short-name domain
description]`. The `name` will be expanded to flag `--name`. If it has
`short-name`, a short name flag will also be created.
The `domain` should be a sequential table of strings (e.g., `[:apple :banana
:orange]`).

In command line argument parsing, this option will consumes the next
argument, validate if the argument is one of `domain`'s items, and set the
`config` object's corresponding attribute to the argument value.

### String option recipe

`recipe-spec` should be `[name VARNAME description]` or `[name short-name VARNAME
description]`. The `name` will be expanded to flag `--name`. If it has `short-name`,
a short name flag will also be created. `VARNAME` will be used to indicate the next
command line argument that will be consumed by this option parsing.

In command line argument parsing, this option will consumes the next
argument and set the `config` object's corresponding attribute to the argument
value.

### Number option recipe

`recipe-spec` should be the same as the string option recipe.

In command line argument parsing, this option will consumes the next
argument, validate if it can be converted to number, and set the `config`
object's corresponding attribute to the converted number.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
