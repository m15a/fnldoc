(local {: assert-type} (require :fnldoc.utils.assert))
(local {: merge!} (require :fnldoc.utils.table))
(local {: exit/error} (require :fnldoc.debug))

(lambda deny-access [reason file ?debug]
  (let [msg (.. "access to denied " reason " detected while loading " file)]
    #(exit/error msg ?debug)))

(lambda deny-access/module [module file ?debug]
  (let [msg (.. "access to denied '" module "' module detected while loading "
                file)]
    (setmetatable {} {:__index #(exit/error msg ?debug)})))

;; TODO: strict check for each Lua version/implementation.
(lambda sandbox [file ?debug]
  "Create a sandboxed environment to run `file` for doctests.

Does not allow any IO, loading files or Lua code via `load`,
`loadfile`, and `loadstring`, using `rawset`, `rawset`, and `module`,
and accessing such modules as `os`, `debug`, `package`, and `io`.

This means that your files must not use these modules on the top
level, or run any code when file is loaded that uses those modules.

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit."
  (assert-type :string file)
  (let [allowed {: assert
                 : collectgarbage
                 : dofile
                 : error
                 : getmetatable
                 : ipairs
                 : next
                 : pairs
                 : pcall
                 : rawequal
                 :rawlen _G.rawlen ; Lua >=5.2
                 : require
                 : select
                 : setmetatable
                 : tonumber
                 : tostring
                 : type
                 :unpack _G.unpack ; Lua 5.1 only
                 : xpcall
                 :bit32 _G.bit32 ; Lua 5.2 only
                 : coroutine
                 : string
                 :utf8 _G.utf8 ; Lua >= 5.3
                 : table
                 : math}
        disallowd {:load nil
                   :loadfile nil
                   :loadstring nil
                   :module nil
                   :rawget nil
                   :rawset nil}
        sandboxed {:arg []
                   :print (deny-access :IO file ?debug)
                   :package (deny-access/module :package file ?debug)
                   :io (deny-access/module :io file ?debug)
                   :os (deny-access/module :os file ?debug)
                   :debug (deny-access/module :debug file ?debug)}
        env (doto allowed
              (merge! disallowd sandboxed))]
    (set env._G env)
    env))

(lambda sandbox/overrides [file overrides ?debug]
  "A variant of `sandbox' that will be overridden before running `file`.

You can provide an `overrides` table, which contains function name as
a key, and function as a value. This function will be used instead of
specified function name in the sandbox. For example, you can wrap IO
functions to only throw warning, and not error.

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit."
  (let [env (sandbox file ?debug)]
    (merge! env overrides)
    env))

{: sandbox : sandbox/overrides}
