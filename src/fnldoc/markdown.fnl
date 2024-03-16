;;;; Functions for generating Markdown.

(local {: view} (require :fennel))
(local {: assert-type} (require :fnldoc.utils.assert))
(local console (require :fnldoc.console))
(local {: exit/error} (require :fnldoc.debug))
(local {: comparator/table} (require :fnldoc.utils.table))
(local {: basename} (require :fnldoc.utils.file))
(local {: capitalize : escape-regex} (require :fnldoc.utils.string))
(local {: lines->text} (require :fnldoc.utils.text))
(local {: bold
        : code
        : code-fence
        : string->anchor
        : link
        : heading
        : unordered-list
        : promote-headings}
       (require :fnldoc.utils.markdown))

(fn comparator/fallback [order ?fallback-order ?debug]
  (case order
    :alphabetic nil
    :reverse-alphabetic #(> $1 $2)
    (where tbl (= :table (type tbl)))
    (comparator/table tbl (when ?fallback-order
                            (comparator/fallback ?fallback-order)))
    (where fun (= :function (type fun))) fun
    else (let [msg (.. "unsupported order: " (view else))]
           (exit/error msg ?debug))))

(lambda sorted-item-index [modinfo config]
  "Extract the item index of `module-info` and return it as a sequential table.

The result is sorted according to the `order` specified in `module-info` or `config`."
  {:fnl/arglist [module-info config]}
  (doto (icollect [k _ (pairs modinfo.metadata)] k)
    (table.sort (comparator/fallback modinfo.order config.order))))

(lambda title-heading [title ?version]
  "Translate module `title` to Markdown level 1 heading.

`?version` string may be attached if any. The `title` may be a file path
or specified in `.fenneldoc`."
  (->> (.. (capitalize title)
           (if ?version
               (.. " (" (assert-type :string ?version) ")")
               ""))
       (heading 1)))

(lambda item-index->anchor-map [item-index mdata]
  "Get mapping from item to its HTML internal link anchor for the `item-index`.

`metadata` is used to make anchor depending on function's type: function or macro."
  {:fnl/arglist [item-index metadata]}
  (let [map {} seen {}]
    (each [_ item (ipairs item-index)]
      (match (string->anchor (.. (or (?. mdata item :type) :function) ": " item))
        anchor (let [id (. seen anchor)
                     anchor (.. anchor (if id (.. "-" id) ""))]
                 (tset seen anchor (+ (or id 0) 1))
                 (tset map item anchor))))
    map))

(lambda table-of-contents [item-index mdata]
  "Generate Table of contents for the `item-index`.

It returns multiple values in which firstly the ToC itself, and secondary
corresponding anchor mapping.

`metadata` is used to show each function's type: function or macro."
  {:fnl/arglist [item-index metadata]}
  (let [anchor-map (item-index->anchor-map item-index mdata)
        toc (-> [(bold "Table of contents")
                 ""
                 (unordered-list (icollect [_ item (ipairs item-index)]
                                   (let [ftype (case (?. mdata item :type)
                                                 :macro :Macro
                                                 _ :Function)]
                                     (.. ftype ": " (match (. anchor-map item)
                                                      anchor (link (code item) anchor)
                                                      _ (code item))))))]
                (lines->text))]
    (values toc anchor-map)))

(lambda function-signature [function arglist]
  "Make a signature line of `function` with the `arglist`."
  (let [arglist (table.concat arglist " ")
        signature (.. "(" function (if (= "" arglist) "" (.. " " arglist)) ")")]
    (lines->text ["Signature:"
                  ""
                  (code-fence signature)])))

(lambda remove-test-skip [text]
  "Remove all `:skip-test` annotations from markdown fences in the `text`."
  (if (text:match "```%s*fennel[ \t]+:skip%-test")
      (pick-values 1 (text:gsub "(```%s*fennel)[ \t]+:skip%-test" "%1"))
      text))

(lambda inline-references [text]
  "Collect all inline references (e.g., `ref') in the `text`."
  (icollect [ref (text:gmatch "`([%a_][^`']-)'")] ref))

(lambda replace-inline-references [text anchor-map mode]
  "Replace inline references in the `text` using `anchor-map`.

`mode` should be either `:link` or `:code`."
  (accumulate [text text _ ref (ipairs (inline-references text))]
    (let [pat (.. "`" (escape-regex ref) "'")]
      (match mode
        :link (match (. anchor-map ref)
                anchor (text:gsub pat (link (code ref) anchor))
                _ (text:gsub pat (code ref)))
        :code (text:gsub pat (code ref))
        _ text))))

(fn postprocess [text anchor-map config]
  (-> text
      (remove-test-skip)
      (replace-inline-references anchor-map config.inline-references)))

(lambda item-documentation [item mdata anchor-map config]
  "Generate documentation for the `item` with `metadata` accordingly to `config`.

`anchor-map` is used to translate ```item'`` to internal link."
  {:fnl/arglist [item metadata anchor-map config]}
  (let [lines []
        ftype (case mdata.type
                :macro :Macro
                _ :Function)]
    (doto lines
      (table.insert (heading 2 (.. ftype ": " (code item))))
      (table.insert ""))
    (when (and config.function-signatures? mdata.arglist)
      (doto lines
        (table.insert (function-signature item mdata.arglist))
        (table.insert "")))
    (if mdata.docstring
        (doto lines
          (table.insert (promote-headings 2 mdata.docstring)))
        (doto lines
          (table.insert (bold :Undocumented))))
    (-> (lines->text lines)
        (postprocess anchor-map config))))

(lambda copyright-and-license [?copyright ?license]
  "Generate `?copyright` and/or `?license` text."
  (let [lines ["---"]]
    (when ?copyright
      (doto lines
        (table.insert "")
        (table.insert ?copyright)))
    (when ?license
      (doto lines
        (table.insert "")
        (table.insert (.. "License: " ?license))))
    (lines->text lines)))

(lambda final-comment [fnldoc-version]
  "Generate the final comment with `fnldoc-version`, i.e., `<!-- Generated by ...`."
  (let [lines [(.. "<!-- Generated with Fnldoc " fnldoc-version)
               "     https://sr.ht/~m15a/fnldoc/ -->"]]
    (lines->text lines)))

(macro add-section-to [lines section]
  `(doto ,lines
     (table.insert ,section)
     (table.insert "")))

(lambda module-info->markdown [modinfo config]
  "Generate markdown from `module-info` accordingly to `config`."
  {:fnl/arglist [module-info config]}
  (let [item-index (sorted-item-index modinfo config)
        (toc anchor-map) (table-of-contents item-index modinfo.metadata)
        lines []]
    (add-section-to lines
      (title-heading (or modinfo.name (basename modinfo.file))
                     (and config.version? modinfo.version)))
    (when modinfo.description
      (add-section-to lines
        (-> modinfo.description
            (postprocess anchor-map config))))
    (when (and config.toc? (next item-index))
      (add-section-to lines toc))
    (each [_ item (ipairs item-index)]
      (case (. modinfo.metadata item)
        mdata (add-section-to lines
                (item-documentation item mdata anchor-map config))
        _ (console.warn "could not find '" item "' in " modinfo.file)))
    (when (and (or config.copyright? config.license?)
               (or modinfo.copyright modinfo.license))
      (add-section-to lines
        (copyright-and-license (and config.copyright? modinfo.copyright)
                               (and config.license? modinfo.license))))
    (when config.final-comment?
      (add-section-to lines
        (final-comment config.fnldoc-version)))
    (lines->text lines)))

{: sorted-item-index
 : title-heading
 : item-index->anchor-map
 : table-of-contents
 : function-signature
 : remove-test-skip
 : inline-references
 : replace-inline-references
 : item-documentation
 : copyright-and-license
 : final-comment
 : module-info->markdown}

;; vim:set lw+=add-section-to:
