;;;; Colorize console messages using ANSI escape code.

(fn reset []
  "Reset color."
  "\x1B[0m")

(lambda bold [text]
  "Show `text` in bold style."
  (.. "\x1B[1m" text "\x1B[22m"))

(lambda italic [text]
  "Show `text` in italic style."
  (.. "\x1B[3m" text "\x1B[23m"))

(lambda underline [text]
  "Show `text` in underlined style."
  (.. "\x1B[4m" text "\x1B[24m"))

(lambda inverse [text]
  "Show `text` with foreground and background colors inversed."
  (.. "\x1B[7m" text "\x1B[27m"))

(lambda black [text]
  "Show `text` in black foreground color."
  (.. "\x1B[30m" text "\x1B[39m"))

(lambda red [text]
  "Show `text` in red foreground color."
  (.. "\x1B[31m" text "\x1B[39m"))

(lambda green [text]
  "Show `text` in green foreground color."
  (.. "\x1B[32m" text "\x1B[39m"))

(lambda yellow [text]
  "Show `text` in yellow foreground color."
  (.. "\x1B[33m" text "\x1B[39m"))

(lambda blue [text]
  "Show `text` in blue foreground color."
  (.. "\x1B[34m" text "\x1B[39m"))

(lambda magenta [text]
  "Show `text` in magenta foreground color."
  (.. "\x1B[35m" text "\x1B[39m"))

(lambda cyan [text]
  "Show `text` in cyan foreground color."
  (.. "\x1B[36m" text "\x1B[39m"))

(lambda white [text]
  "Show `text` in white foreground color."
  (.. "\x1B[37m" text "\x1B[39m"))

(lambda background-black [text]
  "Show `text` in black background color."
  (.. "\x1B[40m" text "\x1B[49m"))

(lambda background-red [text]
  "Show `text` in red background color."
  (.. "\x1B[41m" text "\x1B[49m"))

(lambda background-green [text]
  "Show `text` in green background color."
  (.. "\x1B[42m" text "\x1B[49m"))

(lambda background-yellow [text]
  "Show `text` in yellow background color."
  (.. "\x1B[43m" text "\x1B[49m"))

(lambda background-blue [text]
  "Show `text` in blue background color."
  (.. "\x1B[44m" text "\x1B[49m"))

(lambda background-magenta [text]
  "Show `text` in magenta background color."
  (.. "\x1B[45m" text "\x1B[49m"))

(lambda background-cyan [text]
  "Show `text` in cyan background color."
  (.. "\x1B[46m" text "\x1B[49m"))

(lambda background-white [text]
  "Show `text` in white background color."
  (.. "\x1B[47m" text "\x1B[49m"))

{: reset
 : bold
 : italic
 : underline
 : inverse
 : black
 : red
 : green
 : yellow
 : blue
 : magenta
 : cyan
 : white
 : background-black
 : background-red
 : background-green
 : background-yellow
 : background-blue
 : background-magenta
 : background-cyan
 : background-white}
