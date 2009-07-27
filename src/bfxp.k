;;
;; Copyright (C) 2009 Christopher Schuster <cs@livoris.de>
;; Released under the terms of the GNU GPL v2.0.
;;

;; Syntax and semantics for Brainfuck XP

;; Memory Layout:
;;
;; +------------------------------------------------+
;; | T3 | T2 | T1 | L | 1 | X0 | Y0 | X1 | Y1 | ... |
;; +------------------------------------------------+
;;
;; Tn : Temporary Storage for Computing
;; L  : Last Computed Result and Origin Position
;; 1  : The "One-Cell" that always contains "1"
;; Xn : Memory Cell with address n
;; Yn : Tag Cell with address n
;; CC : Current Cell

;; ----Imports----

(define Integer (import "Integer"))
(define Dictionary (import "Dictionary"))

;; ----Global Symbol Table----

(define SymbolTable [Dictionary new])

;; ----Helpers----

(define add-var
  (lambda (name)
    [SymbolTable at: name put: [SymbolTable size * 2]]))

(define get-var
  (lambda (name)
    [SymbolTable at: name]))

(syntax timesrepeat ;; may be using a define here?
  ;; call: (timesrepeat n tree)
  ;; prerequisites: none
  ;; result: repeats the tree n times
  (lambda (node compiler)
    `(let ((a 0))
      (while (< a ,[node second])
        ,[node third]
        (set a (+ a 1))))))


;; ----Brainfuck 2000----

(syntax bf2k-inc
  ;; call: (bf2k-inc n)
  ;; prerequisites: none
  ;; result: increments value of CC with n
  (lambda (node compiler)
    `(timesrepeat
      ,[node second]
      (bf-inc))))
 
(syntax bf2k-dec
  ;; call: (bf2k-dec n)
  ;; prerequisites: none
  ;; result: decrements value of CC with n
  (lambda (node compiler)
    `(timesrepeat
      ,[node second]
      (bf-dec))))

(syntax bf2k-seti
  ;; call: (bf2k-seti n)
  ;; prerequisites: none
  ;; result: sets the value of CC to n
  (lambda (node compiler)
    `(let ()
      (bf-while)
      (bf-dec)
      (bf-wend)
      (bf2k-inc ,[node second]))))

(syntax bf2k-puti
  ;; call: (bf2k-puti)
  ;; prerequisites: none
  ;; result: prints the value of CC as digit (0-9)
  (lambda (node compiler)
    `(let ()
      (bf2k-inc 48)
      (bf-putc)
      (bf2k-dec 48))))

(syntax bf2k-puts
  ;; call: (bf2k-puts)
  ;; prerequisites: pointer at start of null-terminated string
  ;; result: prints the string
  ;;         stops the pointer at the null-char
  (lambda (node compiler)
    `(let ()
      (bf-while)
      (bf-putc)
      (bf-next)
      (bf-wend))))

(syntax bf2k-sets
  ;; call: (bf2k-sets "My String")
  ;; prerequisites: none
  ;; result: stores the string null-terminates in the next cells
  ;;         returns the pointer to its original position
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
  ;; call: (bfxp-next 5)
  ;; prerequisites: none
  ;; result: moves the pointer 5 cells to the right
  (lambda (node compiler)
    `(timesrepeat
      ,[node second]
      (bf-next))))
 
(syntax bfxp-prev
  ;; call: (bfxp-prev 5)
  ;; prerequisites: none
  ;; result: moves the pointer 5 cells to the left
  (lambda (node compiler)
    `(timesrepeat
      ,[node second]
      (bf-prev))))

(syntax bfxp-goback
  ;; call: (bfxp-goback)
  ;; prerequisites: pointer at Yn or 1
  ;; result: moves the pointer to L
  (lambda (node compiler)
    `(let ()
      (bf-dec)
      (bf-while)
        (bf-inc)
        (bf-prev)
        (bf-dec)
      (bf-wend)
      (bf-inc)
      (bf-prev))))

(syntax bfxp-goto
  ;; call: (bfxp-goto)
  ;; prerequisites: pointer at L
                      
  ;; result: moves the pointer to Xn
  (lambda (node compiler)
    `(let ()
      (bf-while)
        (bf-prev)
        (bf-prev)
      (bf-wend)
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
