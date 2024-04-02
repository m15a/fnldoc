;;;; Functions related to writing generated documentation into respecting files.

(local {: assert-type} (require :fnldoc.utils.assert))
(local {: dirname : make-directory} (require :fnldoc.utils.file))
(import-macros {: exit/error} :fnldoc.debug)

(lambda write! [text path]
  "Write out the contents of `text` string to the `path`."
  (assert-type :string text)
  (let [dir (dirname path)]
    (if (not (make-directory dir :parents))
        (exit/error "error creating directory '" dir "'")
        (case (io.open path :w)
          file (with-open [out file]
                 (if (out:write text)
                     true
                     (exit/error "error writing file '" path "'")))
          (_ msg code)
          (exit/error "error opening file '" path "': " msg " (" code ")")))))

{: write!}
