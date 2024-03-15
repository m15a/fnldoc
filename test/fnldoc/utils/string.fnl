(local t (require :test.faith))
(local us (require :fnldoc.utils.string))

(fn test-escape-regex []
  (let [full-regex "^$()%.[]*+-?"]
    (t.= "%^%$%(%)%%%.%[%]%*%+%-%?" (us.escape-regex full-regex))))

(fn test-capitalize/word []
  (t.= :Snakecase (us.capitalize/word :snakeCase))
  (t.= " snakecase" (us.capitalize/word " snakeCase")))

{: test-escape-regex : test-capitalize/word}
