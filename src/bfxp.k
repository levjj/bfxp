;;
;; Copyright (C) 2009 Christopher Schuster <cs@livoris.de>
;; Released under the terms of the GNU GPL v2.0.
;;

;; Syntax and semantics for Brainfuck 2000

;; ----Imports----

(define Integer (import "Integer"))
(define Dictionary (import "Dictionary"))

;; ----Global Symbol Table----

(define SymbolTable [Dictionary new])

;; ----Helpers----

(define add-var
  (lambda (name)
    [SymbolTable at: name put: [SymbolTable size]]))

(define get-var
  (lambda (name)
    [SymbolTable at: name]))

(syntax timesrepeat
  (lambda (node compiler)
    `(let ((a 0))
      (while (< a ,[node second])
        ,[node third]
        (set a (+ a 1))))))


;; ----Brainfuck 2000----

(syntax bf2k-inc
  (lambda (node compiler)
    `(timesrepeat
      ,[node second]
      (bf-inc))))
 
(syntax bf2k-dec
  (lambda (node compiler)
    `(timesrepeat
      ,[node second]
      (bf-dec))))

(syntax bf2k-seti
  (lambda (node compiler)
    `(let ()
      (bf-while)
      (bf-dec)
      (bf-wend)
      (bf2k-inc ,[node second]))))

(syntax bf2k-puti
  (lambda (node compiler)
    `(let ()
      (bf2k-inc 48)
      (bf-putc)
      (bf2k-dec 48))))

(syntax bf2k-puts
  (lambda (node compiler)
    `(let ()
      (bf-while)
      (bf-putc)
      (bf-next)
      (bf-wend))))

(syntax bf2k-sets
  (lambda (node compiler)
    `(let ((str ,[node second]) (i 0))
      (while (<= i ,[[node second] size])
        (bf2k-seti (char@ str i))
        (bf-next)
        (set i (+ i 1)))
      (set i 0)
      (while (<= i ,[[node second] size])
        (bf-prev)
        (set i (+ i 1))))))

;; ----Semantics----

(syntax bfxp-next
  (lambda (node compiler)
    `(timesrepeat
      ,[node second]
      (bf-next))))
 
(syntax bfxp-prev
  (lambda (node compiler)
    `(timesrepeat
      ,[node second]
      (bf-prev))))

(syntax bfxp-addforward ;; (bfxp-addforward 1)
                        ;; adds the current cell value to the next cell
  (lambda (node compiler)
    `(let ()
      (bf-while)
        (bf-dec)
        (bfxp-next ,[node second])
        (bf-inc)
        (bfxp-prev ,[node second])
      (bf-wend))))

(syntax bfxp-subforward ;; (bfxp-subforward 1)
                        ;; subs the current cell value to the next cell
  (lambda (node compiler)
    `(let ()
      (bf-while)
        (bf-dec)
        (bfxp-next ,[node second])
        (bf-dec)
        (bfxp-prev ,[node second])
      (bf-wend))))

(syntax bfxp-addbackward ;; (bfxp-addbackward 1)
                    ;; adds the current cell value to the previous cell
  (lambda (node compiler)
    `(let ()
      (bf-while)
        (bf-dec)
        (bfxp-prev ,[node second])
        (bf-inc)
        (bfxp-next ,[node second])
      (bf-wend))))
      
(syntax bfxp-addforward2 ;; (bfxp-addforward2 1 2)
                   ;; adds the current cell value to the next two cells
  (lambda (node compiler)
    `(let ()
      (bf-while)
        (bf-dec)
        (bfxp-next ,[node second])
        (bf-inc)
        (bfxp-prev ,[node second])
        (bfxp-next ,[node third])
        (bf-inc)
        (bfxp-prev ,[node third])
      (bf-wend))))

(syntax bfxp-cell ;; (bfxp-cell x) copies content of var x to last result
  (lambda (node compiler)
    `(let ()
      (bf2k-seti 0) ;; set last to zero
      (bf-prev) ;; go to temp 1
      (bf2k-seti 0) ;; set to temp 1 to zero
      (bfxp-next (+ 2 ,(get-var [node second]))) ;; go to var
      (bfxp-addbackward (+ 2 ,(get-var [node second])))
      (bfxp-prev (+ 2 ,(get-var [node second]))) ;; go to temp 1
      (bfxp-addforward2 1 (+ 2 ,(get-var [node second])))
      (bf-next))))

(syntax bfxp-add ;; (bfxp-add x) adds the last result to var x
  (lambda (node compiler)
    `(let ()
      (bfxp-addforward (+ 1 ,(get-var [node second]))))))

(syntax bfxp-sub ;; (bfxp-sub x) subs the last result from var x
  (lambda (node compiler)
    `(let ()
      (bfxp-subforward (+ 1 ,(get-var [node second]))))))

(syntax bfxp-move2 ;; (bfxp-move2 x) moves the last result to var x
  (lambda (node compiler)
    `(let ()
      (bfxp-next (+ 1 ,(get-var [node second])))
      (bf2k-seti 0)
      (bfxp-prev (+ 1 ,(get-var [node second])))
      (bfxp-addforward (+ 1 ,(get-var [node second]))))))
