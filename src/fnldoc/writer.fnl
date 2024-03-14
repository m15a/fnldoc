;;;; Functions related to writing generated documentation into respecting files.

(local {: assert-type} (require :fnldoc.utils.assert))
(local {: dirname : make-directory} (require :fnldoc.utils.file))
(local {: exit/error} (require :fnldoc.debug))

(lambda write! [text path ?debug]
  "Write out the contents of `text` string to the `path`.

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit."
  (assert-type :string text)
  (let [dir (dirname path)]
    (if (not (make-directory dir :parents))
        (let [msg (string.format "error creating directory '%s'" dir)]
          (exit/error msg ?debug))
        (case (io.open path :w)
          file (with-open [out file]
                 (if (out:write text)
                     true
                     (let [msg (string.format "error writing file '%s'" path)]
                       (exit/error msg ?debug))))
          (_ msg code)
          (let [msg (string.format "error opening file '%s': %s (%s)" path msg code)]
            (exit/error msg ?debug))))))

{: write!}
