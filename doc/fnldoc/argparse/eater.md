# Eater.fnl (1.0.2-dev)

**Table of contents**

- [`bless`](#bless)
- [`option-descriptions/order`](#option-descriptionsorder)
- [`parse!`](#parse)
- [`preprocess`](#preprocess)
- [`validate`](#validate)

## `bless`

Function signature:

```
(bless option-recipe extra)
```

Enable the `option-recipe` table to consume command line arguments.

In addition, attach `extra` key-value pairs to the table.
To be blessed, `key` and `flag` attributes are mandatory.


## `option-descriptions/order`

Function signature:

```
(option-descriptions/order order recipes)
```

Gather descriptions among option `recipes` and enumerate them in the given `order`.

## `parse!`

Function signature:

```
(parse! self config args)
```

Update the `config` object possibly with consuming the head of `args`.

If the option recipe `self` has `value`, append it to the `config` using `self`'s
`key`. If not, consume the head of `args`, possibly preprocess, validate, and append
it to the `config` accordingly.
If the head of `args` is missing, report error and exit with failing status.

## `preprocess`

Function signature:

```
(preprocess self next-arg)
```

Preprocess the `next-arg` and return the processed value.

If an option recipe `self` has `preprocessor`, call it against the `next-arg`;
otherwise pass through it.
In addition, remember the `next-arg` in the `processed-arg` attribute.

## `validate`

Function signature:

```
(validate self value)
```

Validate the `value` and return it if successes.

If an option recipe `self` has `validator`, call it against the `value`;
otherwise pass through it.
If validation fails, report error and exit with failing status.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
