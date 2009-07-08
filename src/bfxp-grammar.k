; bfxp implementation
; first version of a simple imperative language
; (c) 2009 Michael Haupt, Christopher Schuster
; michael.haupt@hpi.uni-potsdam.de
; christopher.schuster@hpi.uni-potsdam.de

['{
    eof     = !.
    space   = [ \t] | eol
    eol     = '\r' '\n'* | '\n' '\r'*
    comment = '#' (!eol .)* eol
    _       = ( space | comment )*
    semicolon = ';' _
    
    digit       = [0-9]
    number      = (digit+) $->0 _  <- [Integer fromString: [self @ '0]]
    identifier  =
          ([a-zA-Z_][a-zA-Z_0-9]*) $->0 _ <- [[self @ '0] asSymbol]
    
    //
    // symbols
    //
    ASSIGNADD  = '+='  _
    ASSIGN  = '='  _
    
    //
    // built-in data types
    //
    BYTE = 'byte' _
    
    //
    // built-in functions
    //
    PUTI       = 'puti' _
    
    //
    // types
    //
    
    type = BYTE
        
    //
    // syntax tree
    //
        
    value = (
          identifier->0 <- `(bfxp-cell ,[self @ '0])->1
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
    
    application =
          PUTI value->0 <- `(let ()
                              ,[self @ '0]
                              (bf2k-puti))
   
    statement =
          (declaration
        |  assignment
        |  assignmentadd
        |  application)
           semicolon
    
    program = _ ( statement
                        <- (let ()
                             ;;[result println]
                             (let ((value [result eval]))
                               ;;['"=>" putln]
                               ;;[value println]
                               value))
                )* <- '0


} name: 'bfxp ]
