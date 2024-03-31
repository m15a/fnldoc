;;;; Functions related to writing generated documentation into respecting files.

(local {: assert-type} (require :fnldoc.utils.assert))
(local {: dirname : make-directory} (require :fnldoc.utils.file))
(import-macros {: exit/error} :fnldoc.debug)

(lambda write! [text path]
  "Write out the contents of `text` string to the `path`."
  (assert-type :string text)
  (let [dir (dirname path)]
    (if (not (make-directory dir :parents))
        (let [msg (string.format "error creating directory '%s'" dir)]
          (exit/error msg))
        (case (io.open path :w)
          file (with-open [out file]
                 (if (out:write text)
                     true
                     (let [msg (string.format "error writing file '%s'" path)]
                       (exit/error msg))))
          (_ msg code)
          (let [msg (string.format "error opening file '%s': %s (%s)" path msg code)]
            (exit/error msg))))))

{: write!}
