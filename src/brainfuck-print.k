;;
;; Copyright (C) 2009 Christopher Schuster <cs@livoris.de>
;; Released under the terms of the GNU GPL v2.0.
;;

;; Semantics to print a Brainfuck-AST

(syntax bf-putc
  (lambda (node compiler)
    `['46 put]))
    
(syntax bf-getc
  (lambda (node compiler)
    `['44 put]))

(syntax bf-prev
  (lambda (node compiler)
    `['60 put]))

(syntax bf-next
  (lambda (node compiler)
    `['62 put]))

(syntax bf-while
  (lambda (node compiler)
    `['91 put]))

(syntax bf-wend
  (lambda (node compiler)
    `['93 put]))

(syntax bf-inc
  (lambda (node compiler)
    `['43 put]))
 
(syntax bf-dec
  (lambda (node compiler)
    `['45 put]))
