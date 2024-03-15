(local t (require :test.faith))
(local us (require :fnldoc.utils.string))

(fn test-escape-regex []
  (let [full-regex "^$()%.[]*+-?"]
    (t.= "%^%$%(%)%%%.%[%]%*%+%-%?" (us.escape-regex full-regex))))

(fn test-capitalize []
  (t.= :Snakecase (us.capitalize :snakeCase))
  (t.= " Snakecase " (us.capitalize " snakeCase "))
  (t.= "UPPER lower" (us.capitalize "UPPER lower")))

{: test-escape-regex : test-capitalize}
