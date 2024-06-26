;;;; Process command line arguments.

(import-macros {: cooking : recipe} :fnldoc.argparse.cooker)
(local color (require :fnldoc.utils.color))
(local {: bless : option-descriptions/order} (require :fnldoc.argparse.eater))
(local {: clone} (require :fnldoc.utils.table))
(local {: indent : wrap : lines->text} (require :fnldoc.utils.text))

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
         (recipe :string :src-dir :DIR
           "Path where source files located if any. This will be stripped from destination to generate documentation files.")
         (recipe :category :order [:alphabetic :reverse-alphabetic]
           "Sorting of items that were not given particular order.
Supported algorithms:
    alphabetic         - alphabetic order; and
    reverse-alphabetic - reverse alphabetic order.
You also can specify a custom sorting function in '.fenneldoc' file.")
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
         (recipe :bool :toc
           "Whether to generate table of contents.")
         (recipe :bool :function-signatures
           "Whether to generate function signatures in documentation.")
         (recipe :bool :copyright
           "Whether to insert copyright information.")
         (recipe :bool :license
           "Whether to insert license information.")
         (recipe :bool :version
           "Whether to insert version information.")
         (recipe :bool :final-comment
           "Whether to insert final comment with Fnldoc version.")
         (recipe :bool :sandbox
           "Whether to sandbox loaded code and documentation tests.")))

;; TODO: Enable `recipe` to handle these options.
(local meta-recipes
       {:--
        {:description
         "    --\tTreat remaining arguments as FILEs."}
        :--fnldoc-version
        {:description
         "    --fnldoc-version\tPrint Fnldoc version and exit."}
        :--help
        {:description
         "    --help\tPrint this message and exit."}
        :--config
        {:description
         "    --config\tParse all regular options and update '.fenneldoc' at the current directory."}})

(fn help [color?]
  "Generate help message, decorated with ANSI escape code if `color?` is truthy."
  (let [underline (if color? color.underline #$)
        italic (if color? color.italic #$)]
    (-> [(.. (underline "Usage:") " fnldoc " (italic "[OPTIONS] [FILE]..."))
         ""
         "Create documentation for your Fennel project."
         ""
         (underline "Arguments:")
         (indent 2 (.. (italic "[FILE]...") "  File(s) to generate documentation."))
         ""
         (underline "Options:")
         (indent 2 (option-descriptions/order
                     [:--out-dir
                      :--src-dir
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
                     option-recipes color?))
         (underline "Other options:")
         (indent 2 (option-descriptions/order
                     [:--
                      :--config
                      :--fnldoc-version
                      :--help]
                     meta-recipes color?))
         (wrap 80 (.. "All options have respective entries in '.fenneldoc' "
                      "configuration file, and arguments passed via command line "
                      "have higher precedence, therefore will override following "
                      "values in '.fenneldoc'."))
         ""
         (wrap 80 (.. "Each boolean option has two variants with and without 'no'. "
                      "For example, passing '--no-toc' will disable generation of "
                      "contents table, and '--toc' will enable it."))]
        (lines->text))))

(fn parse [args]
  "Parse command line `args` and return its result.

The result contains attributes:

- `write-config?`: Whether to write configuration, after merged with that
  coming from `.fenneldoc`, to `.fenneldoc`.
- `show-help?`: Whether to show Fnldoc help and exit.
- `show-version?`: Whether to show Fnldoc version and exit.
- `config`: Parsed configuration that will be merged into that coming from
  `.fenneldoc`.
- `files`: Target Fennel file names, which will be processed by Fnldoc."
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
              _ (case (. option-recipes flag|file)
                  recipe* (let [eater (bless recipe* {:flag flag|file})]
                            (eater:parse! state.config args))
                  _ (table.insert state.files flag|file))))))
    (doto state
      (tset :ignore-options? nil))))

{: option-recipes : help : parse}

;; vim:set lw+=recipe:
