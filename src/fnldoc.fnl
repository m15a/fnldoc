;;;; Fnldoc - generate documentation for Fennel projects.

;;;; **Documentation for other modules**
;;;;
;;;; - [fnldoc/argparse.fnl](./fnldoc/argparse.md) -
;;;;   Process command line arguments.
;;;; - [fnldoc/argparse/cooker.fnl](./fnldoc/argparse/cooker.md) -
;;;;   Macros to define command line argument options.
;;;; - [fnldoc/argparse/eater.fnl](./fnldoc/argparse/eater.md) -
;;;;   Command line argument consumers.
;;;; - [fnldoc/config.fnl](./fnldoc/config.md) -
;;;;   Process configuration file.
;;;; - [fnldoc/console.fnl](./fnldoc/console.md) -
;;;;   Print messages to console.
;;;; - [fnldoc/debug.fnl](./fnldoc/debug.md) -
;;;;   Utilities for debugging.
;;;; - [fnldoc/doctest.fnl](./fnldoc/doctest.md) -
;;;;   Run documentation testing.
;;;; - [fnldoc/markdown.fnl](./fnldoc/markdown.md) -
;;;;   Generate Markdown documentation from module information.
;;;; - [fnldoc/modinfo.fnl](./fnldoc/modinfo.md) -
;;;;   Analyze Fennel file and provide module information.
;;;; - [fnldoc/processor.fnl](./fnldoc/processor.md) -
;;;;   Orchestrate tasks.
;;;; - [fnldoc/utils/*.fnl](./fnldoc/utils/) -
;;;;   Miscellaneous utilities.
;;;; - [fnldoc/writer.fnl](./fnldoc/writer.md) -
;;;;   Write Markdown documentation into files.

(local unpack (or table.unpack _G.unpack))
(local {: merge!} (require :fnldoc.utils.table))
(local console (require :fnldoc.console))
(local config (require :fnldoc.config))
(local argparse (require :fnldoc.argparse))
(local {: process!} (require :fnldoc.processor))

(local fnldoc-version :1.1.0-dev)

(fn show-version []
  (io.stdout:write fnldoc-version "\n")
  (os.exit 0))

(fn show-help []
  (let [color? (console.isatty? 1)]
    (io.stdout:write (argparse.help color?) "\n"))
  (os.exit 0))

(fn main []
  "Run Fnldoc application."
  (let [config/file (config.init! {:version fnldoc-version})
        {: show-version?
         : show-help?
         : write-config?
         :config config/arg
         : files} (argparse.parse [(unpack arg 1)])
        config (doto config/file (merge! config/arg))]
    (when show-help?
      (show-help))
    (when show-version?
      (show-version))
    (when write-config?
      (config:write!))
    (each [_ file (ipairs files)]
      (process! file config))))

{:version fnldoc-version : main}
