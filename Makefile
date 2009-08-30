JOLT2 = /home/cs/devel/cola/idst/function/jolt2
LIBS = $(JOLT2)/boot.k
FLAGS = 
MAIN = src/bfxp.k src/bfxp-grammar.k
RUN = $(JOLT2)/main $(FLAGS) $(LIBS) src/brainfuck-exec16.k $(MAIN)

.PHONY: doc

all :   test

doc :
	@cd doc; make	

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

bf : $(MAIN) brainfuck/brainfuck.bfxp
	$(RUN) brainfuck/brainfuck.bfxp < brainfuck/hello.bf

clean : 
	rm -f *~ *.so
	@cd doc ; make clean
