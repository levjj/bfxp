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
    // symbols
    //
    ASSIGN      = '=' _
    ASSIGNADD   = '+=' _
    ASSIGNSUB   = '-=' _
    STARTP      = '(' _
    ENDP        = ')' _
    STARTB      = '{' _
    ENDB        = '}' _
    
    //
    // keywords
    //
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
    
    type = BYTE
        
    //
    // syntax tree
    //
    
    left =
          identifier->0 <- `(bfxp-varaddress ,[self @ '0])

    value = (
          application->1
        | left->0 <- `(let () ,[self @ '0] (bfxp-cell ,[self @ '0]))->1
        | number->0 <- `(bf2k-seti ,[self @ '0])->1
          ) <- [self @ '1]

    declaration =
          type identifier->0 <- (add-var [self @ '0])

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
          GETC STARTP ENDP
            <- `(bf-getc)
        | PUTI STARTP value->0 ENDP
            <- `(let ()
                  ,[self @ '0]
                  (bf2k-puti))
        | PUTC STARTP value->0 ENDP
            <- `(let ()
                  ,[self @ '0]
                  (bf-putc))
   
    while = WHILE STARTP value->0 ENDP STARTB
              statement*->1
            ENDB <- `(let ()
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
