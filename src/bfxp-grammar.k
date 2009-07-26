; bfxp implementation
; first version of a simple imperative language
; (c) 2009 Michael Haupt, Christopher Schuster
; michael.haupt@hpi.uni-potsdam.de
; christopher.schuster@hpi.uni-potsdam.de

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
        
    value = (
          application->1
        | identifier->0 <- `(bfxp-cell ,[self @ '0])->1
        | number->0 <- `(let () (bf2k-seti ,[self @ '0])) ->1
          ) <- [self @ '1]

    declaration =
          type identifier->0 <- (add-var [self @ '0])

    assignment = (
          identifier->0 ASSIGN value->1
          ) <- `(let ()
                  ,[self @ '1]
                  (bfxp-move2 ,[self @ '0]))

    assignmentadd = (
          identifier->0 ASSIGNADD value->1
          ) <- `(let ()
                  ,[self @ '1]
                  (bfxp-add ,[self @ '0]))

    assignmentsub = (
          identifier->0 ASSIGNSUB value->1
          ) <- `(let ()
                  ,[self @ '1]
                  (bfxp-sub ,[self @ '0]))
    
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
                         (bf-next)
                         (bf-next)
                         (bf-next)
                         ,@[self @ '0])
    
    program = _ statements
                  <- (let ()
                       ;;[result println]
                          (let ((value [result eval]))
                            ;;['"=>" putln]
                            ;;[value println]
                            value
                            (printf "\n")))

} name: 'bfxp ]
