(import-macros {: testing} :test.utils)
(local t (require :test.faith))
(local console (require :fnldoc.console))

(fn log+ [{: level} msg]
  (with-open [out (io.tmpfile)]
    (console.log* {: level : out :color? false} msg)
    (out:seek :set)
    (out:read :*a)))

(testing :log
  (it "prints plain log" []
    (t.= "fnldoc: no level\n"
         (log+ {} "no level")))

  (it "prints info" []
    (t.= "fnldoc [INFO]: info\n"
         (log+ {:level :info} :info)))

  (it "prints warning" []
    (t.= "fnldoc [WARNING]: warn\n"
         (log+ {:level :warn} :warn)))

  (it "prints error" []
    (t.= "fnldoc [ERROR]: error\n"
         (log+ {:level :error} :error))))

;; vim: lw+=testing,test,it
