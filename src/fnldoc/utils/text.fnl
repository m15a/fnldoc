;;;; Utilities for text processing.
;;;;
;;;; FIXME: Support Windows line ending.

(local {: assert-type} (require :fnldoc.utils))
(local {: view} (require :fennel))

(lambda indent [width text]
  "Indent `text` by `width`."
  (let [level (faccumulate [s "" _ 1 width] (.. s " "))]
    (pick-values 1 (-> text
                       (string.gsub "^" level)
                       (string.gsub "(\n)" (.. "%1" level))))))

(fn remove-last-empty-if-any [lines]
  (let [n (length lines)]
    (if (= "" (. lines n))
        (doto lines
          (table.remove n))
        lines)))

(lambda text->lines [text ?eol]
  "Split `text` by `?eol` (default: `\"\\n\"`) into a sequential table of lines.

The last empty after the last end of line (i.e., \"\") will be removed."
  (let [eol (or ?eol "\n")
        lines []]
    (each [line (string.gmatch text (.. "([^" eol "]*)\n?"))]
      (table.insert lines line))
    (remove-last-empty-if-any lines)))

(lambda lines->text [lines ?eol]
  "Concatenate a sequential table of `lines` with `?eol` into a `text`.

`?eol` defaults to `\"\\n\"`"
  (let [eol (or ?eol "\n")]
    (table.concat lines eol)))

(lambda wrap/line [line width ?eol]
  "Wrap a `line` into lines of the maximum `width` separated by `?eol`.

`?eol` defaults to `\"\\n\"`.

FIXME: This is buggy if `width` is too short."
  (let [eol (or ?eol "\n")]
    (if (<= (length line) width)
        line
        (let [head (line:sub 1 width)
              tail (line:sub (+ width 1))]
          (var cursor width)
          (while (and (< 1 cursor)
                      (string.match (head:sub cursor cursor) "[^%s]"))
            (set cursor (- cursor 1)))
          (let [head* (head:sub 1 (- cursor 1))
                tail* (.. (head:sub (+ cursor 1)) tail)]
            (.. head* eol (wrap/line tail* width eol)))))))

(lambda wrap [width text ?eol]
  "Wrap each line in the `text` if the line length is longer than `width`.

`?eol` defaults to `\"\\n\"`."
  (let [eol (or ?eol "\n")
        lines (text->lines text)
        wrapped-lines []]
    (each [_ line (ipairs lines)]
      (table.insert wrapped-lines (wrap/line line width eol)))
    (table.concat wrapped-lines eol)))

(fn pad* [padder width text ?pad-char]
  (when ?pad-char
    (assert-type :string ?pad-char)
    (assert (= 1 (length ?pad-char))
            (string.format "invalid ?pad-char length: %s" (view ?pad-char))))
  (let [pad-char (or ?pad-char " ")
        l (length text)]
    (if (<= width l)
        text
        (let [padding (faccumulate [s pad-char _ 1 (- width l 1)]
                        (.. s pad-char))]
          (padder padding text)))))

(lambda pad [width text ?pad-char]
  "Pad `text` on the left side with `?pad-char` (default: \" \") up to `width`."
  (pad* (fn [padding text] (.. padding text)) width text ?pad-char))

(lambda pad/right [width text ?pad-char]
  "Pad `text` on the right side with `?pad-char` (default: \" \") up to `width`."
  (pad* (fn [padding text] (.. text padding)) width text ?pad-char))

{: indent : text->lines : lines->text : wrap/line : wrap : pad : pad/right}