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
    
    escapeChar  = 'n' <- '10 | 'r' <- '13 | 't' <-  '9
    char        = "'" ('\\' escapeChar ->0 | . ->0 ) "'"
                    <- [self @ '0]
    
    //
    // operators
    //
    PLUS        = '+' _
    MINUS       = '-' _
    EQUAL       = '==' _
    NEQUAL      = '!=' _
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
    ELSE        = 'else' _
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
    
    type = BYTE <- '1 -> 1
           (
             STARTINDEX number->0 ENDINDEX <- [self @ '0] -> 1
           )?
           <- [self @ '1]
        
    //
    // syntax tree
    //
    
    declaration =
          type->0 identifier->1 <- (add-var [self @ '1] [self @ '0])

    left = identifier->0 <- `(bfxp-varaddress ,[self @ '0]) ->2
           (
             STARTINDEX expression->1 ENDINDEX
               <- `(bfxp-arrayaddress ,[self @ '0] ,[self @ '1]) ->2
           )?
           <- [self @ '2]

    value = 
          ( char->0 <- `(bf2k-seti ,[self @ '0])->1
          | number->0 <- `(bf2k-seti ,[self @ '0])->1
          | application->1
          | left->0 <- `(let () ,[self @ '0] (bfxp-cell ,[self @ '0]))->1
          ) <- [self @ '1]

    expression = value->0
               ( PLUS  value->1 <-`(bfxp-sum ,[self @ '0] ,[self @ '1])->0
               | MINUS value->1 <-`(bfxp-difference ,[self @ '0] ,[self @ '1])->0
               | EQUAL value->1 <-`(bfxp-equal ,[self @ '0] ,[self @ '1])->0
               | NEQUAL value->1 <-`(bfxp-difference ,[self @ '0] ,[self @ '1])->0
               )* <- [self @ '0]

    assignment = (
          left->0 ASSIGN expression->1
          ) <- `(let ()
                  ,[self @ '1]
                  ,[self @ '0]
                  (bfxp-store))

    assignmentadd = (
          left->0 ASSIGNADD expression->1
          ) <- `(let ()
                  ,[self @ '1]
                  ,[self @ '0]
                  (bfxp-add))

    assignmentsub = (
          left->0 ASSIGNSUB expression->1
          ) <- `(let ()
                  ,[self @ '1]
                  ,[self @ '0]
                  (bfxp-sub))
    
    application =
          GETC STARTPARA ENDPARA
            <- `(bf-getc)
        | PUTI STARTPARA expression->0 ENDPARA
            <- `(let ()
                  ,[self @ '0]
                  (bf2k-puti))
        | PUTC STARTPARA expression->0 ENDPARA
            <- `(let ()
                  ,[self @ '0]
                  (bf-putc))
   
    while = WHILE STARTPARA expression->0 ENDPARA STARTBLOCK
              statement*->1
            ENDBLOCK <- `(let ()
                           ,[self @ '0]
                           (bf-while
                             ,@[self @ '1]
                             ,[self @ '0]))

    ifthenelse = IF STARTPARA expression->0 ENDPARA STARTBLOCK
                   statement*->1
                     <- `(bfxp-ifthenelse ,[self @ '0] ,[self @ '1] ()) ->0
                 ENDBLOCK
                 (ELSE STARTBLOCK
                   statement*->2
                     <- [[self @ '0] at: '3 put: [self @ '2]]
                  ENDBLOCK)? <- [self @ '0]
   
    statement =
         ((declaration
        |  assignment
        |  assignmentadd
        |  assignmentsub
        |  application)
           semicolon)
        |  ifthenelse
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
