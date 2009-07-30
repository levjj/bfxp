; bfxp grammar
; first version of a simple imperative language
; (c) 2009 Michael Haupt, Christopher Schuster
; michael.haupt@hpi.uni-potsdam.de
; cs@livoris.de

['{
    eof         = !.
    space       = [ \t] | eol
    eol         = '\r' '\n'* | '\n' '\r'*
    comment     = '#' (!eol .)* eol
    _           = ( space | comment )*
    semicolon   = ';' _
    
    digit       = [0-9]
    number      = (digit+) $->0 _
                    <- [Integer fromString: [self @ '0]]
    identifier  = ([a-zA-Z_][a-zA-Z_0-9]*) $->0 _
                    <- [[self @ '0] asSymbol]
    
    //
    // operators
    //
    PLUS        = '+' _
    MINUS       = '-' _
    COMPARE     = '==' _
    ASSIGN      = '=' _
    ASSIGNADD   = '+=' _
    ASSIGNSUB   = '-=' _
    
    //
    // parantheses
    //
    STARTPARA   = '(' _
    ENDPARA     = ')' _
    STARTBLOCK  = '{' _
    ENDBLOCK    = '}' _
    STARTINDEX  = '[' _
    ENDINDEX    = ']' _
    
    //
    // keywords
    //
    IF          = 'if' _
    WHILE       = 'while' _
    
    //
    // built-in data types
    //
    BYTE        = 'byte' _
    
    //
    // built-in functions
    //
    PUTI        = 'puti' _
    PUTC        = 'putc' _
    GETC        = 'getc' _
    
    //
    // types
    //
    
    type = BYTE <- '1
         | BYTE STARTINDEX number->0 ENDINDEX <- [self @ '0]
        
    //
    // syntax tree
    //
    
    declaration =
          type->0 identifier->1 <- (add-var [self @ '1] [self @ '0])

    left =
          identifier->0 <- `(bfxp-varaddress ,[self @ '0])

    value = (
            application->1
          | left->0 <- `(let () ,[self @ '0] (bfxp-cell ,[self @ '0]))->1
          | number->0 <- `(bf2k-seti ,[self @ '0])->1
            ) <- [self @ '1]

    sum = expression->0 PLUS value->1
            <- `(let ()
                  ,[self @ '0]
                  (bfxp-addbackward 3)
                  ,[self @ '1]
                  (bfxp-prev 3)
                  (bfxp-addforward 3)
                  (bfxp-next 3))

    difference = expression->0 MINUS value->1
            <- `(let ()
                  ,[self @ '0]
                  (bfxp-addbackward 3)
                  ,[self @ '1]
                  (bfxp-prev 3)
                  (bfxp-subforward 3)
                  (bfxp-next 3))

    comparison = expression->0 COMPARE value->1
            <- `(let ()
                  ,[self @ '0]
                  (bfxp-addbackward 3)
                  ,[self @ '1]
                  (bfxp-prev 3)
                  (bfxp-subforward 3)
                  (bfxp-next 3))

    expression = value
               | sum
               | difference
               | comparison

    assignment = (
          left->0 ASSIGN value->1
          ) <- `(let ()
                  ,[self @ '1]
                  ,[self @ '0]
                  (bfxp-store))

    assignmentadd = (
          left->0 ASSIGNADD value->1
          ) <- `(let ()
                  ,[self @ '1]
                  ,[self @ '0]
                  (bfxp-add))

    assignmentsub = (
          left->0 ASSIGNSUB value->1
          ) <- `(let ()
                  ,[self @ '1]
                  ,[self @ '0]
                  (bfxp-sub))
    
    application =
          GETC STARTPARA ENDPARA
            <- `(bf-getc)
        | PUTI STARTPARA value->0 ENDPARA
            <- `(let ()
                  ,[self @ '0]
                  (bf2k-puti))
        | PUTC STARTPARA value->0 ENDPARA
            <- `(let ()
                  ,[self @ '0]
                  (bf-putc))
   
    while = WHILE STARTPARA value->0 ENDPARA STARTBLOCK
              statement*->1
            ENDBLOCK <- `(let ()
                           ,[self @ '0]
                           (bf-while)
                             ,@[self @ '1]
                             ,[self @ '0]
                           (bf-wend))
   
    statement =
         ((declaration
        |  assignment
        |  assignmentadd
        |  assignmentsub
        |  application)
           semicolon)
        |  while
    
    statements = statement*->0
                  <- `(let ()
                        (bfxp-setup)
                        ,@[self @ '0])
    
    program = _ statements
                  <- (let ()
                       ;[result println]
                          (let ((value [result eval]))
                            ;['"=>" putln]
                            ;[value println]
                            value
                            (printf "\n")))

} name: 'bfxp ]
