(local t (require :test.faith))
(local console (require :fnldoc.console))

(fn log+ [{: level} msg]
  (with-open [out (io.tmpfile)]
    (console.log* {: level : out :color? false} msg)
    (out:seek :set)
    (out:read :*a)))

(fn test-log* []
  (t.= "fnldoc: no level\n"
       (log+ {} "no level"))
  (t.= "fnldoc [INFO]: info\n"
       (log+ {:level :info} :info))
  (t.= "fnldoc [WARNING]: warn\n"
       (log+ {:level :warn} :warn))
  (t.= "fnldoc [WARNING]: warning\n"
       (log+ {:level :warning} :warning))
  (t.= "fnldoc [ERROR]: error\n"
       (log+ {:level :error} :error)))

{: test-log*}
