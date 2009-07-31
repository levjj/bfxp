;; Semantics to execute a Brainfuck-AST

;;; bind library functions
(define putchar (dlsym "putchar"))
(define getchar (dlsym "getchar"))

;;; the memory
(define mem-size 32768)
(define memory (calloc mem-size 1))

;;; the pointer
(define P memory)

;;; convenience functions
(syntax inc (lambda (node compiler) `(set ,[node second] (+ ,[node second] 1))))
(syntax dec (lambda (node compiler) `(set ,[node second] (- ,[node second] 1))))

;; Actual implementation

(syntax bf-putc
  (lambda (node compiler)
    '(putchar (char@ P))))
    
(syntax bf-getc
  (lambda (node compiler)
    '(set (char@ P) (getchar))))

(syntax bf-prev
  (lambda (node compiler)
    '(dec P)))

(syntax bf-next
  (lambda (node compiler)
    '(inc P)))

(syntax bf-while
  (lambda (node compiler)
    `(while (!= 0 (char@ P))
      ,@[node copyFrom: '1])))

(syntax bf-inc
  (lambda (node compiler)
    '(inc (char@ P))))
 
(syntax bf-dec
  (lambda (node compiler)
    '(dec (char@ P))))

