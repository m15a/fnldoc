(local {: assert-type} (require :fnldoc.utils.assert))

(fn escape-regex [str]
  "Escape magic characters of Lua regex pattern in the `string`.

Return the escaped string.
The magic characters are namely `^$()%.[]*+-?`.
See the [Lua manual][1] for more detail.

[1]: https://www.lua.org/manual/5.4/manual.html#6.4.1

# Examples

```fennel
(assert (= \"%.fnl%$\" (escape-regex \".fnl$\")))
```"
  {:fnl/arglist [string]}
  (assert-type :string str)
  (pick-values 1 (str:gsub "([%^%$%(%)%%%.%[%]%*%+%-%?])" "%%%1")))

(lambda capitalize/word [word]
  "Capitalize the `word`.

# Examples

```fennel
(assert (= \"String\" (capitalize/word \"string\")))
(assert (= \"String\" (capitalize/word \"sTrInG\")))
```"
  (assert-type :string word)
  (.. (string.upper (word:sub 1 1)) (string.lower (word:sub 2))))

{: escape-regex : capitalize/word}
