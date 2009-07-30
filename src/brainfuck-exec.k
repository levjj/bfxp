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
