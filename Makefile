JOLT2 = /home/cs/cola/idst/function/jolt2
LIBS = $(JOLT2)/boot.k
FLAGS = 
MAIN = src/bfxp.k src/bfxp-grammar.k
EXEC = $(JOLT2)/main $(FLAGS) $(LIBS) src/brainfuck-exec16.k $(MAIN)
PRINT = $(JOLT2)/main $(FLAGS) $(LIBS) src/brainfuck-print.k $(MAIN)
RUN = $(EXEC)

all :   test

check : $(MAIN)
	$(JOLT2)/main $(FLAGS) $(LIBS) $(MAIN)

test : $(MAIN) examples/a8.bfxp
	$(RUN) examples/a8.bfxp

test16 : $(MAIN) examples/test16.bfxp
	$(RUN) examples/test16.bfxp

fib : $(MAIN) examples/minifib.bfxp
	$(RUN) examples/minifib.bfxp

counter : $(MAIN) examples/counter.bfxp
	$(RUN) examples/counter.bfxp

expr : $(MAIN) examples/expr.bfxp
	$(RUN) examples/expr.bfxp

array : $(MAIN) examples/array.bfxp
	$(RUN) examples/array.bfxp

char : $(MAIN) examples/char.bfxp
	$(RUN) examples/char.bfxp

assign : $(MAIN) examples/assign.bfxp
	$(RUN) examples/assign.bfxp

bf : $(MAIN) brainfuck/brainfuck-mini.bfxp etc/hello.bf
	$(EXEC) brainfuck/brainfuck-mini.bfxp < etc/hello.bf

brainfuck/brainfuck-mini.bf : $(MAIN) brainfuck/brainfuck-mini.bfxp etc/ex.bf
	$(PRINT) brainfuck/brainfuck-mini.bfxp > brainfuck/brainfuck-mini.bf
	echo "%" >> brainfuck/brainfuck-mini.bf
	cat etc/ex.bf >> brainfuck/brainfuck-mini.bf

brainfuck/brainfuck-full.bf : $(MAIN) brainfuck/brainfuck-full.bfxp etc/ex.bf
	$(PRINT) brainfuck/brainfuck-full.bfxp > brainfuck/brainfuck-full.bf
	echo "%" >> brainfuck/brainfuck-full.bf
	cat etc/ex.bf >> brainfuck/brainfuck-full.bf

bfbf : $(MAIN) brainfuck/brainfuck-full.bfxp brainfuck/brainfuck-mini.bf
	$(EXEC) brainfuck/brainfuck-full.bfxp < brainfuck/brainfuck-mini.bf

clean : 
	rm -f *~ *.so
	rm -f brainfuck/*.bf
