;; Semantics to execute a Brainfuck-AST
;; (c) 2009 Michael Haupt, Christopher Schuster

;;; bind library functions
(define putchar (dlsym "putchar"))
(define getchar (dlsym "getchar"))

;;; the memory
(define mem-size 32768)
(define memory (calloc mem-size 1))

;;; the pointer
(define P memory)

;;; convenience functions
(syntax inc (lambda (node compiler) `(set ,[node second] (+ ,[node second] ,[node third]))))
(syntax dec (lambda (node compiler) `(set ,[node second] (- ,[node second] ,[node third]))))

;; Actual implementation

(syntax bf-putc
  (lambda (node compiler)
    '(putchar (char@ P))))

(syntax bf-getc
  (lambda (node compiler)
    '(set (char@ P) (getchar))))

(syntax bf-prev
  (lambda (node compiler)
    '(dec P 1)))

(syntax bf-prevn
  (lambda (node compiler)
    `(dec P ,[node second])))

(syntax bf-next
  (lambda (node compiler)
    '(inc P 1)))

(syntax bf-nextn
  (lambda (node compiler)
    `(inc P ,[node second])))

(syntax bf-while
  (lambda (node compiler)
    `(while (!= 0 (char@ P))
      ,@[node copyFrom: '1])))

(syntax bf-inc
  (lambda (node compiler)
    '(inc (char@ P) 1)))

(syntax bf-incn
  (lambda (node compiler)
    `(inc (char@ P) ,[node second])))

(syntax bf-dec
  (lambda (node compiler)
    '(dec (char@ P) 1)))

(syntax bf-decn
  (lambda (node compiler)
    `(dec (char@ P) ,[node second])))