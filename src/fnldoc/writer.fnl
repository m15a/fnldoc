;;;; Functions related to writing generated documentation into respecting files.

(local {: assert-type} (require :fnldoc.utils))
(local console (require :fnldoc.console))
(local {: dirname : make-directory} (require :fnldoc.utils.file))

(lambda write! [text path]
  "Write out the contents of `text` string to the `path`."
  (assert-type :string text)
  (let [dir (dirname path)]
    (if (not (make-directory dir :parents))
        (do
          (console.error "error creating directory '" dir "'")
          (os.exit 1))
        (case (io.open path :w)
          fh (with-open [out fh]
               (out:write text))
          (_ msg code)
          (do
            (console.error "error opening file '" path "': " msg
                           " (" code ")")
            (os.exit 1))))))

{: write!}
