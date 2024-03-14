(local {: assert-type} (require :fnldoc.utils))

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

{: escape-regex}
