(local t (require :test.faith))
(local us (require :fnldoc.utils.string))

(fn test-escape-regex []
  (let [full-regex "^$()%.[]*+-?"]
    (t.= "%^%$%(%)%%%.%[%]%*%+%-%?" (us.escape-regex full-regex))))

{: test-escape-regex}
