# Eater.fnl (1.1.0-dev)

Various option recipe consumers that help command line argument processing.

**Table of contents**

- Function: [bless](#function-bless)
- Function: [option-descriptions/order](#function-option-descriptionsorder)
- Function: [parse!](#function-parse)
- Function: [preprocess](#function-preprocess)
- Function: [validate](#function-validate)

## Function: bless

```fennel
(bless option-recipe extra)
```

Enable the `option-recipe` table to process command line argument.

By blessing an option recipe, it can [`parse!`](#function-parse) command line argument.
It merges `extra` key-value pairs to the table.
To be blessed, `key` and `flag` entries are mandatory.

## Function: option-descriptions/order

```fennel
(option-descriptions/order order recipes color?)
```

Gather descriptions among option `recipes` and enumerate them in the given `order`.

If `color?` is truthy, it uses ANSI escape code.

## Function: parse!

```fennel
(parse! self config args)
```

Update the `config` possibly with consuming the head of `args`.

If `self`, an option recipe, has `value`, append it to the `config` using
`self.key`. If not, consume the head of `args`, possibly [`preprocess`](#function-preprocess),
[`validate`](#function-validate), and append it to the `config` accordingly.
If the head of `args` is missing, report error and exit with failing status.

## Function: preprocess

```fennel
(preprocess self next-arg)
```

Preprocess the `next-arg` and return the processed value.

If option recipe `self` has `preprocessor`, call it against the `next-arg`;
otherwise pass through it.
In addition, remember the `next-arg` in the `processed-arg` attribute.

## Function: validate

```fennel
(validate self value)
```

Validate the `value` and return it if fine.

If option recipe `self` has `validator`, call it against the `value`;
otherwise pass through it.
If validation fails, report error and exit with failing status.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
