; bfxp semantics
; first version of a simple imperative language
; (c) 2009 Michael Haupt, Christopher Schuster
; michael.haupt@hpi.uni-potsdam.de
; cs@livoris.de

;;  -------------
;;  Memory Layout
;;  -------------

; +-----------------------------------------------------+
; | ... | T2 | T1 | L | 1 | A | X0 | D0 | X1 | D1 | ... |
; +-----------------------------------------------------+
;
; Tn : Temporary Storage for Computing
; L  : Last Computed Result and Origin Position
; 1  : The "One-Cell" that always contains "1"
; Xn : Tag Cell with address n (used for navigating)
; Dn : Data Cell with address n
; CC : Current Cell

;;  ---------
;;  Constants
;;  ---------

(define TemporaryFields 5)

;;  -------
;;  Imports
;;  -------

(define Integer (import "Integer"))
(define Dictionary (import "Dictionary"))

;;  ------------
;;  Global State
;;  ------------

(define UsedMemory '0)
(define SymbolTable [Dictionary new])

;;  --------------
;;  Static Helpers
;;  --------------

(define add-var
  (lambda (name size)
    (let ()
      [SymbolTable at: name put: UsedMemory]
      (set UsedMemory [UsedMemory + size]))))

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

;;  ---------------------
;;  Brainfuck 2000 Macros
;;  ---------------------

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
      (bf-while ; while (CC > 0)
        (bf-dec)) ;   CC := CC - 1;
      (bf2k-inc ,[node second]))))

(syntax bf2k-puti
  ;; call: (bf2k-puti)
  ;; prerequisites: none
  ;; result: prints the value of CC as digit (0-9)
  (lambda (node compiler)
    `(let ()
      (bf2k-inc 48) ; convert byte value 0 to ascii value '0'
      (bf-putc)
      (bf2k-dec 48)))) ; recover old cell

(syntax bf2k-puts
  ;; call: (bf2k-puts)
  ;; prerequisites: pointer at start of null-terminated string
  ;; result: prints the string
  ;;         stops the pointer at the null-char
  (lambda (node compiler)
    `(let ()
      (bf-while
        (bf-putc)
        (bf-next)))))

(syntax bf2k-sets
  ;; call: (bf2k-sets "My String")
  ;; prerequisites: none
  ;; result: stores the string null-terminates in the next cells
  ;;         returns the pointer to its original position
  (lambda (node compiler)
    `(let ((str ,[node second]) (i 0))
      (while (<= i ,[[node second] size]) ; set string char by char
        (bf2k-seti (char@ str i))
        (bf-next)
        (set i (+ i 1)))
      (set i 0)
      (while (<= i ,[[node second] size]) ; return the pointer
        (bf-prev)
        (set i (+ i 1))))))

;;  ------------------------------------
;;  Brainfuck XP Macros (Static Address)
;;  ------------------------------------

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

(syntax bfxp-setup
  ;; call: (bfxp-setup)
  ;; prerequisites: pointer at start position (left-most cell)
  ;; result: 1 at the "One" cell
  ;;         pointer at L
  (lambda (node compiler)
    `(let ()
      (bfxp-next (+ TemporaryFields 1))
      (bf-inc) ; initialize the one-field
      (bf-prev))))

(syntax bfxp-addforward
  ;; call: (bfxp-addforward n)
  ;; prerequisites: CC = value to add
  ;; result: CC := 0
  ;;         [CC + n] := [CC + n] + value to add
  (lambda (node compiler)
    `(let ()
      (bf-while ; while (CC > 0)
        (bf-dec) ;   CC := CC - 1;
        (bfxp-next ,[node second])
        (bf-inc) ;   [CC + n] := [CC + n] + 1;
        (bfxp-prev ,[node second])))))

(syntax bfxp-subforward
  ;; call: (bfxp-subforward n)
  ;; prerequisites: CC = value to subtract
  ;; result: CC := 0
  ;;         [CC + n] := [CC + n] - value to subtract
  (lambda (node compiler)
    `(let ()
      (bf-while ; while (CC > 0)
        (bf-dec) ;   CC := CC - 1;
        (bfxp-next ,[node second])
        (bf-dec) ;   [CC + n] := [CC + n] + 1;
        (bfxp-prev ,[node second])))))

(syntax bfxp-addbackward
  ;; call: (bfxp-addbackward n)
  ;; prerequisites: CC = value to add
  ;; result: CC := 0
  ;;         [CC - n] := [CC - n] + value to add
  (lambda (node compiler)
    `(let ()
      (bf-while ; while (CC > 0)
        (bf-dec) ;   CC := CC - 1;
        (bfxp-prev ,[node second])
        (bf-inc) ;   [CC - n] := [CC - n] + 1;
        (bfxp-next ,[node second])))))

(syntax bfxp-addforward2
  ;; call: (bfxp-addforward n m)
  ;; prerequisites: CC contains the value to add
  ;; result: CC := 0
  ;;         [CC + n] := [CC + n] + value to add
  ;;         [CC + m] := [CC + m] + value to add
  (lambda (node compiler)
    `(let ()
      (bf-while ; while (CC > 0)
        (bf-dec) ;   CC := CC - 1;
        (bfxp-next ,[node second])
        (bf-inc) ;   [CC + n] := [CC + n] + 1;
        (bfxp-prev ,[node second])
        (bfxp-next ,[node third])
        (bf-inc) ;   [CC + m] := [CC + m] + 1;
        (bfxp-prev ,[node third])))))

;;  -------------------------------------
;;  Brainfuck XP Macros (Dynamic Address)
;;  -------------------------------------

(syntax bfxp-goback
  ;; call: (bfxp-goback)
  ;; prerequisites: pointer at Xn or 1
  ;;                all Xn contain 0
  ;;                "one-field" contains 1
  ;; result: pointer at L
  (lambda (node compiler)
    `(let ()
      (bf-dec) ; decrement CC
      (bf-while  ; if CC = 0 then it was 1 which means we are on the "one"-field
        (bf-inc) ; recover old value of CC
        (bfxp-prev 2) ; to from Xn to X(n-1) or to the one-field
        (bf-dec)) ; decrement CC
      (bf-inc) ; restore the one-field
      (bf-prev)))) ; go from 1 to L

(syntax bfxp-goto
  ;; call: (bfxp-goto)
  ;; prerequisites: pointer at A
  ;;                A contains address (0..255)
  ;; result: pointer at D[A]
  (lambda (node compiler)
    `(let ()
       (bf-prev)
       (bf-dec) ; dec one-cell to 0
       (bf-next)
       (bfxp-addbackward 1) ; move value of A to one-cell
       (bf-prev)
       (bfxp-addforward2 1 2) ; move value of one-cell to A and X0
       (bf-inc) ; increase one-cell to 1
       (bfxp-next 2) ; move to X0
       (bf-while  ; we are done if there is a zero in the current tag cell
         (bf-dec) ; decrement the current tag cell
         (bf-while        ; move the value in the current tag cell
           (bfxp-next 2)  ; to the next if it is not zero
           (bf-inc)
           (bfxp-prev 2)  ; to the next if it is not zero
           (bf-dec))
         (bfxp-next 2))  ; move to next tag cell
       (bf-next)))) ; we found it

(syntax bfxp-add
  ;; call: (bfxp-add)
  ;; prerequisites: pointer at L
  ;;                L = value to add
  ;;                A contains address (0..255)
  ;; result: D[A] := D[A] + value to add
  ;;         L := 0
  ;;         pointer at L
  (lambda (node compiler)
    `(let ()
      (bf-while ; while (L > 0)
        (bf-dec) ;   L := L - 1;
        (bfxp-next 2) ; move pointer to A
        (bfxp-goto) ; goto D[A]
        (bf-inc) ; D[A] := D[A] + 1
        (bf-prev) ; move pointer to X[A]
        (bfxp-goback))))) ; move pointer to L

(syntax bfxp-sub
  ;; call: (bfxp-sub)
  ;; prerequisites: pointer at L
  ;;                L = value to substract
  ;;                A contains address (0..255)
  ;; result: D[A] := D[A] - value to substract
  ;;         L := 0
  ;;         pointer at L
  (lambda (node compiler)
    `(let ()
      (bf-while ; while (L > 0)
        (bf-dec) ;   L := L - 1;
        (bfxp-next 2) ; move pointer to A
        (bfxp-goto) ; goto D[A]
        (bf-dec) ; D[A] := D[A] - 1
        (bf-prev) ; move pointer to X[A]
        (bfxp-goback))))) ; move pointer to L

(syntax bfxp-fetchcell
  ;; call: (bfxp-fetchcell)
  ;; prerequisites: pointer at L
  ;;                D[n] = value to fetch
  ;;                A contains address (0..255)
  ;; result: T2 := value to fetch
  ;;         D[A] := 0
  ;;         pointer at L
  (lambda (node compiler)
    `(let ()
      (bfxp-prev 2) ; move pointer to T2
      (bf2k-seti 0) ; T2 := 0;
      (bfxp-next 4) ; move pointer to A
      (bfxp-goto) ; goto D[A]
      (bf-while  ; while (D[A] > 0)
        (bf-dec) ;   D[A] := D[A] - 1;
        (bf-prev) ;  move pointer to X[A]
        (bfxp-goback) ; move pointer to L
        (bfxp-prev 2) ; move pointer to T2
        (bf-inc) ; T2 := T2 + 1;
        (bfxp-next 4) ; move to A
        (bfxp-goto)) ; goto D[A]
      (bf-prev) ;  move pointer to X[A]
      (bfxp-goback)))) ; move pointer to L

(syntax bfxp-cell
  ;; call: (bfxp-cell)
  ;; prerequisites: pointer at L
  ;;                A contains address (0..255)
  ;; result: pointer at L
  ;;         L := D[A]
  (lambda (node compiler)
    `(let ()
      (bf2k-seti 0) ;; L := 0
      (bfxp-fetchcell) ;; set T2 to varname value
      (bfxp-prev 2) ; move pointer to T2
      (bfxp-addforward2 1 2) ;; move value of T2 to T1 and L
      (bfxp-next 2) ; move pointer to L
      (bfxp-add) ;; recover value of varname from L
      (bf-prev) ; move pointer to T1
      (bfxp-addforward 1) ; move value of T1 to L
      (bf-next)))) ; move to L and finish

(syntax bfxp-store
  ;; call: (bfxp-store)
  ;; prerequisites: pointer at L
  ;;                L = value to store
  ;;                A contains address (0..255)
  ;; result: pointer at L
  ;;         D[A] := value to store
  ;;         L := 0
  (lambda (node compiler)
    `(let ()
      (bfxp-next 2) ; move pointer to A
      (bfxp-goto) ; goto D[A]
      (bf2k-seti 0) ; D[A] := 0
      (bf-prev) ; goto X[A]
      (bfxp-goback) ; goto L
      (bfxp-add)))) ; D[A] := D[A] + L

(syntax bfxp-special-seti
  ;; call: (bf2k-special-seti n)
  ;; prerequisites: pointer at A
  ;; result: sets the value of A to n by multiplying T5 with 100
  ;;         this reduces the amounts of '+'
  (lambda (node compiler)
    (let ((value [node second]))
      (if (< value 256)
        `(bf2k-seti ,value)
        `(let ()
          (bf2k-seti 0) ; A := 0;
          (bfxp-prev 7) ; goto T5
          (bf2k-inc (/ ,value 122)) ;   T5 := value / 122;
          (bf-while ; while (T5 > 0)
            (bf-dec) ;   T5 := T5 - 1;
            (bfxp-next 7) ; goto A
            (bf2k-inc 122) ; A := A + 122
            (bfxp-prev 7)) ; goto T5
          (bfxp-next 7) ; goto A
          (bf2k-inc (% ,value 122))))))) ; A := A + (value mod 122)

(syntax bfxp-varaddress
  ;; call: (bfxp-varaddress varname)
  ;; prerequisites: pointer at L
  ;;                varname is in SymbolTable
  ;; result: pointer at L
  ;;         A := address of varname
  (lambda (node compiler)
    `(let ()
      (bfxp-next 2) ; move pointer to A
      (bfxp-special-seti ,(get-var [node second])) ; put varname address in A
      (bfxp-prev 2)))) ; move pointer to L

(syntax bfxp-arrayaddress
  ;; call: (bfxp-arrayaddress varname expression)
  ;; prerequisites: pointer at L
  ;;                A = index in array
  ;;                varname is in SymbolTable
  ;;                L might contain value to assign
  ;; result: pointer at L
  ;;         A := address of varname + index
  (lambda (node compiler)
    `(let ()
      (bfxp-prev 4) ; move pointer to T4
      (bf2k-seti 0) ; T4 := 0
      (bfxp-next 4) ; move pointer to L
      (bfxp-addbackward 4) ; T4 := L'
      ,[node third] ; insert computation of index into L
      (bfxp-varaddress ,[node second]) ; A := varname address
      (bfxp-addforward 2) ; A := A + computed index
      (bfxp-prev 4) ; move pointer to T4
      (bfxp-addforward 4) ; L := L'
      (bfxp-next 4)))) ; move pointer to L

(syntax bfxp-sum
  ;; call: (bfxp-sum expression value)
  ;; prerequisites: pointer at L
  ;; result: expression will be evaluated
  ;;         value will be evaluated
  ;;         L := expression result + value result
  (lambda (node compiler)
    `(let ()
       ,[node second] ; evaluate expression
       (bfxp-addbackward 3) ; store result in T3
       ,[node third] ; evaluate value
       (bfxp-prev 3) ; goto T3
       (bfxp-addforward 3) ; L := L + T3
       (bfxp-next 3)))) ; goto L

(syntax bfxp-difference
  ;; call: (bfxp-difference expression value)
  ;; prerequisites: pointer at L
  ;; result: expression will be evaluated
  ;;         value will be evaluated
  ;;         L := expression result - value result
  (lambda (node compiler)
    `(let ()
       ,[node third] ; evaluate value
       (bfxp-prev 3) ; goto T3
       (bf2k-seti 0) ; T3 := 0
       (bfxp-next 3) ; goto L
       (bfxp-addbackward 3) ; store result in T3
       ,[node second] ; evaluate expression
       (bfxp-prev 3) ; goto T3
       (bfxp-subforward 3) ; L := L - T3
       (bfxp-next 3)))) ; goto L

(syntax bfxp-equal
  ;; call: (bfxp-equal expression value)
  ;; prerequisites: pointer at L
  ;; result: expression will be evaluated
  ;;         value will be evaluated
  ;;         if (expression == value) {
  ;;           L := 1;
  ;;         } else {
  ;;           L := 0;
  ;;         }
  (lambda (node compiler)
    `(let ()
       (bfxp-prev 3) ; goto T3
       (bf2k-seti 0) ; T3 := 0
       (bfxp-next 3) ; goto L
       ,[node second] ; evaluate expression
       (bfxp-addbackward 3) ; store result in T3
       ,[node third] ; evaluate value
       (bfxp-prev 3) ; goto T3
       (bfxp-subforward 3) ; L := L - T3
       (bfxp-next 2) ; goto T1
       (bf2k-seti 1) ; T1 := 1
       (bf-next) ; goto L
       (bf-while     ; if (L > 0)
         (bf-prev)   ;   goto T1
         (bf-dec)    ;   T1 := 0
         (bf-next)   ;   goto L
         (bf2k-seti 0)) ;   L := 0
       (bf-prev) ; goto T1
       (bfxp-addforward 1) ; L := T1
       (bf-next)))) ; goto L

(syntax bfxp-ifthenelse
  ;; call: (bfxp-ifthenelse expression ifcase [elsecase?])
  ;; prerequisites: pointer at L
  ;; result: expression will be evaluated
  ;;         if (expression > 0) {
  ;;           ifcase will be evaluated;
  ;;         } else {
  ;;           optional elsecase will be evaluated
  ;;         }
  (lambda (node compiler)
    `(let ()
       ,[node second] ; evaluate expression       
       (bf-prev) ; goto T1
       (bf2k-seti 1) ; T1 := 1
       (bf-next) ; goto L
       (bf-while     ; if (L > 0)
         (bf-prev)       ;   goto T1
         (bf2k-seti 0)  ;   T1 := 0
         (bf-next) ; goto L
         ,@[node third] ; evaluate ifcase       
         (bf2k-seti 0)  ;   L := 0
         (bf-prev)       ;   goto T1
         (bf2k-seti 0)  ;   T1 := 0
         (bf-next)) ; goto L
       (bf-prev) ; goto T1
       (bf-while     ; if (T1 > 0)
         (bf2k-seti 0)  ;   T1 := 0
         (bf-next)   ;   goto L
         ,@[node fourth] ; evaluate elsecase
         (bf2k-seti 0) ;   L := 0
         (bf-prev) ; goto T1
         (bf2k-seti 0)) ;   T1 := 0
       (bf-next)))) ; goto L
