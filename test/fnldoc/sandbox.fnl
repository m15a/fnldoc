(import-macros {: testing} :test.utils)
(local t (require :test.faith))
(local {: sandbox : sandbox/overrides} (require :fnldoc.sandbox))

(local file "test/fixture/some.fnl")

(testing :sandbox
  (it "creates sandbox" []
    (t.is (sandbox file)))

  (it "has empty arg" []
    (let [sbox (sandbox file)]
      (t.= [] sbox.arg)))

  (it "denies access to print" []
    (let [sbox (sandbox file)]
      (t.error "access to denied IO detected"
               #(sbox.print :hello))))

  (it "denies access to modules: io, os, debug, and package" []
    (let [sbox (sandbox file)]
      (t.error "access to denied 'io' module"
               #(sbox.io.open :file))
      (t.error "access to denied 'os' module"
               #(sbox.os.remove :file))
      (t.error "access to denied 'debug' module"
               #(sbox.debug.setmetatable {} {:__index true}))
      (t.error "access to denied 'package' module detected"
               #sbox.package.path)))

  (it "nullifies access to load, loadfile, etc." []
    (let [sbox (sandbox file)]
      (each [_ x (ipairs [:load :loadfile :loadstring :module :rawget
                          :rawset])]
        (t.= nil (. sbox x)))))

  (it "can override access/deny rules" []
    (let [sbox (sandbox/overrides file {:io :hello})]
      (t.is sbox.io))))

;; vim: lw+=testing,test,it spell
