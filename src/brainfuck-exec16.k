;; Semantics to execute a Brainfuck-AST
;; (c) 2009 Michael Haupt, Christopher Schuster

;;; bind library functions
(define putchar (dlsym "putchar"))
(define getchar (dlsym "getchar"))

;;; the memory
(define mem-size 32768)
(define memory (calloc mem-size 2))

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
    '(dec P 2)))

(syntax bf-next
  (lambda (node compiler)
    '(inc P 2)))

(syntax bf-while
  (lambda (node compiler)
    `(while (!= 0 (short@ P))
      ,@[node copyFrom: '1])))

(syntax bf-inc
  (lambda (node compiler)
    '(inc (short@ P) 1)))

(syntax bf-dec
  (lambda (node compiler)
    '(dec (short@ P) 1)))

