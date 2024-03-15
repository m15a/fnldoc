(local t (require :test.faith))
(local um (require :fnldoc.utils.markdown))

(fn test-heading []
  (t.= "# heading 1" (um.heading 1 "heading 1"))
  (t.= "heading -1" (um.heading -1 "heading -1"))
  (t.= "# heading with newline" (um.heading 1 "heading with\nnewline"))
  (t.error "number expected" #(um.heading :a "")))

(fn test-ordered-list []
  (t.= "" (um.ordered-list []))
  (t.= "1. A\n2. B\n3. C" (um.ordered-list [:A :B :C]))
  (t.= "1. A B" (um.ordered-list ["A\nB"]))
  (t.error "string expected" #(um.ordered-list [1 :a]))
  (t.error "table expected" #(um.ordered-list 1)))

(fn test-unordered-list []
  (t.= "" (um.unordered-list []))
  (t.= "- A\n- B\n- C" (um.unordered-list [:A :B :C]))
  (t.= "- A B" (um.unordered-list ["A\nB"]))
  (t.error "string expected" #(um.unordered-list [1 :a]))
  (t.error "table expected" #(um.unordered-list 1)))

(fn test-bold []
  (t.= :**bold** (um.bold :bold))
  (t.= "**bol\nd**" (um.bold "bol\nd"))
  (t.error "string expected" #(um.bold 1)))

(fn test-italic []
  (t.= :*italic* (um.italic :italic))
  (t.= "*ital\nic*" (um.italic "ital\nic"))
  (t.error "string expected" #(um.italic 1)))

(fn test-bold-italic []
  (t.= :***bold-italic*** (um.bold-italic :bold-italic))
  (t.= :***bold-italic*** (um.bold-italic :bold-italic))
  (t.= :***bold&italic*** (um.bold (um.italic :bold&italic)))
  (t.error "string expected" #(um.bold-italic 1)))

(fn test-code []
  (t.= "`code`" (um.code :code))
  (t.= "`co\nde`" (um.code "co\nde"))
  (t.= "``co`de``" (um.code "co`de"))
  (t.= "```c``o`d``e```" (um.code "c``o`d``e"))
  (t.error "string expected" #(um.code 1)))

(fn test-link []
  (t.= "[text](url)" (um.link :text :url))
  (t.error "string expected" #(um.link 1 :url)))

(fn test-string->anchor []
  (t.= "#abc" (um.string->anchor :ABC))
  (t.= "#a-b-c" (um.string->anchor "a b  c"))
  (t.= "#a" (um.string->anchor "  a "))
  (t.= "#abc" (um.string->anchor :a.b.c))
  (t.= "#abc" (um.string->anchor :a/b/c))
  (t.= "#ab" (um.string->anchor :a&b))
  (t.error "string expected" #(um.string->anchor 1)))

(fn test-code-block []
  (t.= "    code\n    block" (um.code-block "code\nblock"))
  (t.error "string expected" #(um.code-block 1)))

(fn test-code-fence []
  (t.= "```\ncode\nfence\n```" (um.code-fence "code\nfence"))
  (t.= "```fennel\ncode fence\n```" (um.code-fence "code fence" :fennel))
  (t.= "```\ncode`fence\n```" (um.code-fence "code`fence"))
  (t.= "````\ncode```fence\n````" (um.code-fence "code```fence"))
  (t.error "string expected" #(um.code-fence 1)))

(fn test-promote-headings []
  (t.= "# A\n## B\n" (um.promote-headings 0 "# A\n## B\n"))
  (t.= "## A\n### B\n" (um.promote-headings 1 "# A\n## B\n")))

{: test-heading
 : test-ordered-list
 : test-unordered-list
 : test-bold
 : test-italic
 : test-bold-italic
 : test-code
 : test-link
 : test-string->anchor
 : test-code-block
 : test-code-fence
 : test-promote-headings}
