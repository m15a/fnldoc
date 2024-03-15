;;;; Markdown-specific text processing facilities.

(local {: assert-type} (require :fnldoc.utils.assert))
(local {: indent : lines->text} (require :fnldoc.utils.text))

(lambda heading [level title]
  "Make a heading of specified `level` by prepending `#` in front of the `title`."
  (assert-type :number level)
  (assert-type :string title)
  (let [title (title:gsub "\n+" " ")]
    (if (< level 1)
        title
        (let [nsigns (faccumulate [h "" _ 1 level] (.. h "#"))]
          (.. nsigns " " title)))))

(lambda ordered-list [texts]
  "Make an ordered list from the sequential table of `texts`.

1. Apple
2. Banana
3. Orange"
  (assert-type :table texts)
  (-> (icollect [i text (ipairs texts)]
        (let [line (string.gsub (assert-type :string text) "\n+" " ")]
          (.. i ". " line)))
      (lines->text)))

(lambda unordered-list [texts]
  "Make an unordered list from the sequential table of `texts`.

- Apple
- Banana
- Orange"
  (assert-type :table texts)
  (-> (icollect [_ text (ipairs texts)]
        (let [line (string.gsub (assert-type :string text) "\n+" " ")]
          (.. "- " line)))
      (lines->text)))

(lambda bold [text]
  "Make a **bold** `text`."
  (assert-type :string text)
  (.. "**" text "**"))

(lambda italic [text]
  "Make an *italic* `text`."
  (assert-type :string text)
  (.. "*" text "*"))

(lambda bold-italic [text]
  "Make a ***bold italic*** `text`."
  (assert-type :string text)
  (.. "***" text "***"))

(lambda code [text]
  "Show `text` as an inline `code`."
  (assert-type :string text)
  (var backticks "`")
  (while (text:match backticks)
    (set backticks (.. "`" backticks)))
  (.. backticks text backticks))

(lambda link [text url]
  "Make a hyperlink of `text` pointing to the `url`."
  (assert-type :string text)
  (assert-type :string url)
  (.. "[" text "](" (url:gsub "\n+" "") ")"))

(lambda string->anchor [str]
  "Translate the `string` to Markdown valid anchor id.

Empty ids may occur if we pass only restricted chars. Such ids are ignored."
  {:fnl/arglist [string]}
  (assert-type :string str)
  (let [id (-> str
               (string.gsub "%." "")
               (string.gsub " " "-")
               (string.gsub "[^%w-]" "")
               (string.gsub "[-]+" "-")
               (string.gsub "^[-]*(.-)[-]*$" "%1")
               (string.lower))]
    (when (not= "" id)
      (.. "#" id))))

(lambda code-block [text]
  "Indent `text` by four spaces."
  (assert-type :string text)
  (indent 4 text))

(lambda code-fence [text ?annotation]
  "Enclose `text` by at least three backticks; optionally attaching `?annotation`."
  (assert-type :string text)
  (var backticks "```")
  (while (text:match backticks)
    (set backticks (.. "`" backticks)))
  (-> [(if ?annotation
           (.. backticks (string.gsub (assert-type :string ?annotation) "\n+"
                                      ""))
           backticks)
       text
       backticks]
      (lines->text)))

(fn promote-top-heading [nsigns text]
  (if (text:match "^[ \t]*#+ ")
      (pick-values 1 (text:gsub "^(%s*#+) " (.. "%1" nsigns " ")))
      text))

(fn promote-line-start-headings [nsigns text]
  (if (text:match "\n[ \t]*#+ ")
      (pick-values 1 (text:gsub "\n(%s*#+) " (.. "\n%1" nsigns " ")))
      text))

(lambda promote-headings [level text]
  "Promote headings included in the `text` by speficied `level`."
  (assert-type :number level)
  (assert-type :string text)
  (let [nsigns (faccumulate [n "" _ 1 level] (.. n "#"))]
    (->> text
         (promote-top-heading nsigns)
         (promote-line-start-headings nsigns))))

{: heading
 : ordered-list
 : unordered-list
 : bold
 : italic
 : bold-italic
 : code
 : link
 : string->anchor
 : code-block
 : code-fence
 : promote-headings}
