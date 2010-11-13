Overview
========

**Brainfuck XP** is

1. a simple imperative programming language with C-like syntax and
2. a compiler that compiles **Brainfuck XP** source code to *brainfuck*.

By using **Brainfuck XP** it is possible to implement complex *brainfuck*
programs without having to deal with low level operations like pointer move
instructions. 

**Brainfuck XP** is implemented in *Jolt2* which is the function language of
[*COLA*](http://piumarta.com/software/cola/). The *Parsing Expression Grammars*
(PEGs) and syntax macros in *Jolt2* made the implementation of **Brainfuck XP**
relatively easy.


Installation
============

Setting up COLA
---------------

Download the latest version of [COLA](http://piumarta.com/software/cola/) from
subversion repository

    $ svn co http://piumarta.com/svn2/idst/trunk idst
  
Compile COLA by executing ``make`` in the root dictionary. You need
some programs like ``make``, ``gcc`` and header files installed.

    $ ls
    doc  function  Makefile  object  README  system
    $ make

Setting up Brainfuck XP
-----------------------

You can obtain the last version from git repository

    $ git clone https://github.com/levjj/bfxp.git

Modify the Makefile to point to the Jolt2 executable.

    JOLT2 = /path/to/your/cola/installation*/function/jolt2*
    ...

Running the examples
--------------------

There are some examples provided. You can run them by executing

    $ make test
    $ make fib
    ...

Running your own Brainfuck XP programs
--------------------------------------

The best way to run your programs is to write a Makefile in the same
manner as the provided Makefile.

Beware that every Brainfuck XP source file must start with the
following line:

    { bfxp-program }
    # source comes here ...

Language Reference
==================

Comments
--------

Everthing written behind a hash symbol (`#`) is a comment and will be ignored.

Literals
--------

There are two literals:

**Numbers**
:   are expected in decimal format without leading minus, fractions or scientific notation.
:   *Examples: 0, 2, 4, 23*

**Characters**
:   consists of single characters enclosed in single quotation marks.
:   The special escape sequences are \n, \r and \t
:   *Examples: 'a', 'Z', '\n'*

Variables
-----

Variable identifiers must start with a letter followed by zero or more
alphanumerical characters.

*Examples: i, number, rt23*

Variables must be declared prior to usage. **Brainfuck XP** is weak, statically
typed and supports only two types:

**Bytes**
:   Bytes are treated as positive integer values, but the actual size of the integer depends on the underlying *brainfuck* implementation.
:   *Example: `byte b;`*

**Arrays**
:   Arrays must be statically allocated and only bytes are allowed as elements. The elements can be accessed by using square brackets
:   *Example: `byte[3] array;`*

Operators
---------

"+" (Plus)
:   Adds the two bytes
:   *Example: `i + 3`*

"-" (Minus)
:   Subtracts the second byte from the first one
:   *Example: `i - 1`*

"==" (Equals)
:   Compares two bytes and returns true if these are equal
:   *Example: `i == 0`*

"!=" (Not equals)
:   Compares two bytes and returns true if these are not equal
:   *Example: `i != 0`*

"=" (Assign)
:   Only valid if left side is a variable.
:   Stores the value on the right side in the variable on the left side.
:   *Example: `e = 3`*

"+=" (Assign add)
:   Only valid if left side is a variable.
:   Adds two bytes and stores the result in the variable on the left side.
:   *Example: `i += 1`*

"-=" (Assign sub)
:   Only valid if left side is a variable.
:   Subtracts the value on the right side from the variable on the left side.
:   *Example: `i -= 2`*

Statements
----------

A **Brainfuck XP** program consists of statements. Each statement ends with a
semicolon except for the if-then-else and the while statement.

Declaration
:   Declares type and name of a variable. Ends with a semicolon.
:   *Example: `byte i;`*

Simple Statement
:   Executes a line of code. Ends with a semicolon.
:   *Example: `i = 1;`*

If-then-Else
:   There are two different forms:
:   1.  `if (EXPRESSION) { STATEMENTS* }`
:   2.  `if (EXPRESSION) { STATEMENTS* } else { STATEMENTS* }`
:   *Example: `if (i == 2) { puti(3); }`*

While loop
:   `while (EXPRESSION) { STATEMENTS* }`
:   *Example: `while (i != 4) { i += 2; }`*

Built-in functions
------------------

There are three built-in functions in **Brainfuck XP**.

**`byte getc()`**
:   Reads and returns a character from the standard input.
:   *Example: `c = getc();`*

**`void putc(byte c)`**
:   Write the character *c* to the standard output.
:   *Example: `putc('.');`*

**`void puti(byte i)`**
:   Write the decimal representation of *i* to the standard output.
:   Works only for values between 0 and 9.
:   *Example: `puti(6);`*

Examples
========

This simple program saves the integer "8" in a variable and prints it.

    { bfxp-program }
    byte a;
    a=8;
    puti(a); # prints 8

The generated *brainfuck* source looks like this:

    >>>>>>+<[-]++++++++>>[-]<<>><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>[-]
    <-[+<<-]+<[->><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>+<-[+<<-]+<]>>[-]
    <<[-]<<[-]>>>><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>[-<-[+<<-]+<<<+>>
    >><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>]<-[+<<-]+<<<[->+<>>+<<]>>[->
    ><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>+<-[+<<-]+<]<[->+<]>++++++++++
    ++++++++++++++++++++++++++++++++++++++.------------------------------
    ------------------

The next program demonstrates array handling.

    { bfxp-program }
    byte[2] a;
    byte t;
    a[0]=1;
    a[1]=8;
    t = a[0];
    puti(a[t]); # prints 8

And here comes the *brainfuck* source:

    >>>>>>+<[-]+<<<<[-]>>>>[-<<<<+>>>>][-]>>[-]<<[->>+<<]<<<<[->>>>+<<<<]
    >>>>>><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>[-]<-[+<<-]+<[->><->[-<+>
    ]<[->+<>>+<<]+>>[-[>>+<<-]>>]>+<-[+<<-]+<][-]++++++++<<<<[-]>>>>[-<<<
    <+>>>>][-]+>>[-]<<[->>+<<]<<<<[->>>>+<<<<]>>>>>><->[-<+>]<[->+<>>+<<]
    +>>[-[>>+<<-]>>]>[-]<-[+<<-]+<[->><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>
    >]>+<-[+<<-]+<]<<<<[-]>>>>[-<<<<+>>>>][-]>>[-]<<[->>+<<]<<<<[->>>>+<<
    <<]>>>>[-]<<[-]>>>><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>[-<-[+<<-]+<
    <<+>>>><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>]<-[+<<-]+<<<[->+<>>+<<]
    >>[->><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>+<-[+<<-]+<]<[->+<]>>>[-]
    ++<<>><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>[-]<-[+<<-]+<[->><->[-<+>
    ]<[->+<>>+<<]+>>[-[>>+<<-]>>]>+<-[+<<-]+<]<<<<[-]>>>>[-<<<<+>>>>]>>[-
    ]++<<[-]<<[-]>>>><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>[-<-[+<<-]+<<<
    +>>>><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>]<-[+<<-]+<<<[->+<>>+<<]>>
    [->><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>+<-[+<<-]+<]<[->+<]>>>[-]<<
    [->>+<<]<<<<[->>>>+<<<<]>>>>[-]<<[-]>>>><->[-<+>]<[->+<>>+<<]+>>[-[>>
    +<<-]>>]>[-<-[+<<-]+<<<+>>>><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>]<-
    [+<<-]+<<<[->+<>>+<<]>>[->><->[-<+>]<[->+<>>+<<]+>>[-[>>+<<-]>>]>+<-[
    +<<-]+<]<[->+<]>++++++++++++++++++++++++++++++++++++++++++++++++.----
    --------------------------------------------

This example is a little longer and includes expressions, math operations and
conditional execution.

    { bfxp-program }
    byte a;
    byte b;
    a = 4 + 5;
    b = a - 6 + 2;
    puti(b); # prints 5
    if (b == 5) {
      puti(1); # prints 1
    } else {
      puti(2);
    }
    if (b != 3) {
      puti(9); # prints 9
    }

The generated *brainfuck* source code is quite long and will not be shown here.

Brainfuck Interpreter
=====================

The `examples` directory includes some example **Brainfuck XP** programs. One of
these programs is a *brainfuck* interpreter. By applying **Brainfuck XP** to the
program, a *brainfuck* interpreter written in *brainfuck* is generated.

    $ make brainfuck/brainfuck-mini.bf
    ...

This *brainfuck* interpreter can be used to execute the "Hello World"
*brainfuck* script in `etc/hello.bf`.

    $ make bf
    .../idst/function/jolt2/main .../idst/function/jolt2/boot.k \\
        src/brainfuck-exec16.k src/bfxp.k src/bfxp-grammar.k \\
        brainfuck/brainfuck-mini.bfxp < etc/hello.bf
    ; loading: boot.k
    Hello World!

To interpret a tiny *brainfuck* script with the *brainfuck* interpreter being
executed again by a *brainfuck* interpreter, run this command (warning: this
will take very long):

    $ make bfbf 
    ...

Acknowledgments
===============

I have to thank **Michael Haupt** for inspiring me to examine *COLA* and to
write this language implementation. Additional thanks go to **Ian Piumarta**
for implementing the *Jolt2* implementation of *COLA*.

