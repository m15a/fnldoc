(import-macros {: cooking : recipe} :fnldoc.argparse.cooker)
(local {: bless : option-descriptions/order} (require :fnldoc.argparse.eater))
(local {: clone} (require :fnldoc.utils.table))
(local {: indent : wrap} (require :fnldoc.utils.text))

(local option-recipes
       (cooking
         (recipe :category :mode [:checkdoc :check :doc]
                 "Mode to operate in.
Supported modes:
    checkdoc - check documentation and generate markdown;
    check    - only check documentation; and
    doc      - only generate markdown.")
         (recipe :string :out-dir :DIR
                 "Output directory for generated documentation.")
         (recipe :category :order [:alphabetic :reverse-alphabetic]
                 "Sorting of items that were not given particular order.
Supported algorithms:
    alphabetic         - alphabetic order; and
    reverse-alphabetic - reverse alphabetic order.
You also can specify a custom sorting function in `.fenneldoc' file.")
         (recipe :category :inline-references [:link :code :keep]
                 "How to handle inline references.
Supported modes:
    link - convert inline references to markdown links;
    code - convert inline references to inline code; and
    keep - keep inline references as is.")
         (recipe :string :project-version :VERSION
                 "Project version to include in the documentation files.")
         (recipe :string :project-license :LICENSE
                 "Project license to include in the documentation files. Markdown style links are supported.")
         (recipe :string :project-copyright :COPYRIGHT
                 "Project copyright to include in the documentation files.")
         (recipe :bool :toc "Whether to generate table of contents.")
         (recipe :bool :function-signatures
                 "Whether to generate function signatures in documentation.")
         (recipe :bool :copyright
                 "Whether to insert copyright information.")
         (recipe :bool :license "Whether to insert license information.")
         (recipe :bool :version "Whether to insert version information.")
         (recipe :bool :final-comment
                 "Whether to insert final comment with Fnldoc version.")
         (recipe :bool :sandbox
                 "Whether to sandbox loaded code and documentation tests.")))

;; TODO: Enable `recipe` to handle these options.
(local meta-option-recipes
       {:--
        {:description "    --\tTreat remaining arguments as FILEs."}
        :--fnldoc-version
        {:description "    --fnldoc-version\tPrint Fnldoc version and exit."}
        :--help
        {:description "    --help\tPrint this message and exit."}
        :--config
        {:description "    --config\tParse all regular options and update `.fenneldoc' at the current directory."}})

(local help
       (-> ["Usage: fnldoc [OPTIONS] [FILE]..."
            ""
            "Create documentation for your Fennel project."
            ""
            "Arguments:"
            (indent 2 "[FILE]...  File(s to generate documentation.")
            ""
            "Options:"
            (indent 2 (option-descriptions/order [:--out-dir
                                                  :--mode
                                                  :--toc
                                                  :--function-signatures
                                                  :--order
                                                  :--inline-references
                                                  :--copyright
                                                  :--license
                                                  :--version
                                                  :--final-comment
                                                  :--project-copyright
                                                  :--project-license
                                                  :--project-version
                                                  :--sandbox]
                                                 option-recipes))
            "Other options:"
            (indent 2 (option-descriptions/order ["--"
                                                  :--config
                                                  :--fnldoc-version
                                                  :--help]
                                                 meta-option-recipes))
            (wrap 80 (.. "All options have corresponding entry in `.fenneldoc' "
                         "configuration file, and arguments passed via command line have "
                         "higher precedence, therefore will override following values in "
                         "`.fenneldoc'."))
            ""
            (wrap 80
                  (.. "Each boolean option has two variants with and without `no'. "
                      "For example, passing `--no-toc' will disable generation of "
                      "contents table, and `--toc` will enable it."))]
           (table.concat "\n")))

(fn parse [args]
  "Parse command line `args` and return the result.

The result contains attributes:

- `write-config?: Whether to write the final config, after merged with that comming
  from `.fenneldoc`, to `.fenneldoc`.
- `show-help?: Whether to show Fnldoc help and exit.
- `show-version?: Whether to show Fnldoc version and exit.
- `config`: Parsed config that will be merged into that comming from `.fenneldoc`.
- `files`: Target Fennel file names to be proccessed."
  (let [args (clone args)
        state {:config {} :files []}]
    (while (and (not state.show-version?)
                (not state.show-help?)
                (next args))
      (let [flag|file (table.remove args 1)]
        (if state.ignore-options?
            (table.insert state.files flag|file)
            (case flag|file
              :-- (set state.ignore-options? true)
              :--config (set state.write-config? true)
              :--help (set state.show-help? true)
              :--fnldoc-version (set state.show-version? true)
              _ (let [option-recipe (. option-recipes flag|file)]
                  (if (not option-recipe)
                      (table.insert state.files flag|file)
                      (let [eater (bless option-recipe {:flag flag|file})]
                        (eater:parse! state.config args))))))))
    (doto state
      (tset :ignore-options? nil))))

{: help : parse}

;; vim:set lw+=recipe:
