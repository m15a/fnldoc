(import-macros {: testing : test} :test.utils)
(local t (require :test.faith))
(local console (require :fnldoc.console))

(fn log+ [{: level} msg]
  (with-open [out (io.tmpfile)]
    (console.log* {: level : out :color? false} msg)
    (out:seek :set)
    (out:read :*a)))

(testing
  (test :plain-log []
    (t.= "fnldoc: no level\n"
         (log+ {} "no level")))

  (test :info-log []
    (t.= "fnldoc [INFO]: info\n"
         (log+ {:level :info} :info)))

  (test :warning-log []
    (t.= "fnldoc [WARNING]: warn\n"
         (log+ {:level :warn} :warn)))

  (test :error-log []
    (t.= "fnldoc [ERROR]: error\n"
         (log+ {:level :error} :error))))

;; vim: lw+=testing,test,it
