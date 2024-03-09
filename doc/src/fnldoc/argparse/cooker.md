# Cooker.fnl (1.0.2-dev)
Generate command line argument flag recipes.

Macros defined here generate a table that maps command line argument flag
to its *recipe*, which will be used later in command line argument parsing.

You can start to define flags by

```fennel
(start-cooking)
```

Then, define a couple of flags such like

```fennel
(recipe :boolean :ramen
  "Whether you like to have ramen noodles")

(recipe :category :taste :t [:shoyu :miso :tonkotsu]
  "Which type of ramen you like to have")

(recipe :number :bowls :n
  "How many ramen bowls you like to have")
```

Finally, you can collect defined flag recipes by

```fennel
(collect-recipes)
```

which yields

```fennel
{:--ramen {:description "--[no-]ramen\tWhether you like to have ramen noodles"
           :key "ramen?"
           :value true}
 :--no-ramen {:key "ramen?"
              :value false}
 :--taste {:description "--taste, -t\tWhich type of ramen you like to have (one of [shoyu|miso|tonkotsu], default: nil)"
           :key "taste"
           :validate #<function: 0x7ffa16ead208>
           :consume-next? true}
 :-t {:key "taste"
      :validate #<function: 0x7ffa16e31310>
      :consume-next? true}
 :--bowls {:description "--bowls, -n\tHow many ramen bowls you like to have (default: nil)"
           :key "bowls"
           :preprocess #<function: builtin#17>
           :validate #<function: 0x7ffa16f984e8>
           :consume-next? true}
 :-n {:key "bowls"
      :preprocess #<function: builtin#17>
      :validate #<function: 0x7ffa16de4a98>
      :consume-next? true}}
```

It gives you no dishes, only recipes, unfortunately.

A recipe is a table that possibly contains the following entries depending on the needs.

- `:key`: The corresponding key in the `config` object, i.e., `.fenneldoc`.
- `:description`: a line that explain the flag, which will be shown in help.
- `:value`: If the flag is on, this value will be set.
- `:consume-next?`: If this is truthy, the next command line argument will be set to
  the `:value`, possibly after doing `:preprocess` and `:validate`.
- `:preprocess`: A function that converts the next command line argument string to
  the `:value`. Only used for number flags.
- `:validate`: A function that checks if the `:value` is valid. This will be called
  after `:preprocess` is done. Only used for category and number flags.

**Table of contents**

- [`collect-recipes`](#collect-recipes)
- [`recipe`](#recipe)
- [`start-cooking`](#start-cooking)

## `collect-recipes`
Function signature:

```
(collect-recipes)
```

Return all defined flag recipes as a table.

The implicit global `_G.FNLDOC_FLAG_RECIPES` will be cleared as well.

## `recipe`
Function signature:

```
(recipe recipe-type & recipe-spec)
```

Make a flag recipe of given `recipe-type`.

The recipe type can be one of

* `boolean` (or `bool` for short-hand notation),
* `category` (or `cat`),
* `string` (or `str`), or
* `number` (or `num`).

### Boolean flag recipe

`recipe-spec` should be `[name description]` or `[name short-name description]`.
The `name` will be expanded to positive flag `--name` and negative flag
`--no-name`. If it has `short-name`, a short name flag `-x`, where `x` is given
by the `short-name`, will also be created.

In command line argument parsing, the positive flag and short name flag will
set the `config` object's attribute corresponding to the `name` (e.g., if the
`name` is `apple`, the attribute is `apple?`) to `true`, and the negative flag
set it to `false`.

### Category flag recipe

`recipe-spec` should be `[name domain description]` or `[name short-name domain
description]`. The `name` will be expanded to flag `--name`. If it has
`short-name`, a short name flag will also be created.
The `domain` should be a sequential table of strings (e.g., `[:apple :banana
:orange]`).

In command line argument parsing, this flag will consumes the next
argument, validate if the argument is one of `domain`'s items, and set the
`config` object's corresponding attribute to the argument value.

### String flag recipe

`recipe-spec` should be `[name description]` or `[name short-name description]`.
The `name` will be expanded to flag `--name`. If it has `short-name`, a short
name flag will also be created.

In command line argument parsing, this flag will consumes the next
argument and set the `config` object's corresponding attribute to the argument
value.

### Number flag recipe

`recipe-spec` should be the same as the string flag recipe.

In command line argument parsing, this flag will consumes the next
argument, validate if it can be converted to number, and set the `config`
object's corresponding attribute to the converted number.

## `start-cooking`
Function signature:

```
(start-cooking)
```

Start declaration of command line argument flags.

It implicitly declares global table `_G.FNLDOC_FLAG_RECIPES`. Flag recipes
declared by `(recipe ...)` macro will be gathered into this global, and
later collected by calling `(collect-recipes)`.


---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)


<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
