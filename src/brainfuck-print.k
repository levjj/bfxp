; Brainfuck "print" semantics
; first version of a simple imperative language
; (c) 2009 Michael Haupt, Christopher Schuster
; michael.haupt@hpi.uni-potsdam.de
; cs@livoris.de

(syntax bf-putc
  (lambda (node compiler)
    '['46 put]))
    
(syntax bf-getc
  (lambda (node compiler)
    '['44 put]))

(syntax bf-prev
  (lambda (node compiler)
    '['60 put]))

(syntax bf-prevn
  (lambda (node compiler)
    `[[String new: ,[node second] withAll: '60] put]))

(syntax bf-next
  (lambda (node compiler)
    '['62 put]))

(syntax bf-nextn
  (lambda (node compiler)
    `[[String new: ,[node second] withAll: '62] put]))

(syntax bf-while
  (lambda (node compiler)
    `(let ()
      ['91 put]
      ,@[node copyFrom: '1]
      ['93 put])))

(syntax bf-inc
  (lambda (node compiler)
    '['43 put]))

(syntax bf-incn
  (lambda (node compiler)
    `[[String new: ,[node second] withAll: '43] put]))
 
(syntax bf-dec
  (lambda (node compiler)
    '['45 put]))

(syntax bf-decn
  (lambda (node compiler)
    `[[String new: ,[node second] withAll: '45] put]))
