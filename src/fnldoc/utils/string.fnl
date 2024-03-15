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

(fn capitalize [str]
  "Capitalize the first word in the `string`.

However, if characters in the first word are all uppercase, it will be kept
as is.

# Examples

```fennel
(assert (= \"String\" (capitalize \"string\")))
(assert (= \"IO stuff\" (capitalize \"IO stuff\")))
(assert (= \"  One two  \" (capitalize \"  one two  \")))
```"
  {:fnl/arglist [string]}
  (assert-type :string str)
  (let [preceding-spaces (str:match "^%s*")
        first-word (str:match "^%s*([^%s]+)")
        rest (str:match "^%s*[^%s]+(.*)$")]
    (if (= first-word (first-word:upper))
        str
        (.. preceding-spaces
            (string.upper (first-word:sub 1 1))
            (string.lower (first-word:sub 2))
            rest))))

{: escape-regex : capitalize}
