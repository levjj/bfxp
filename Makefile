JOLT2 = /home/cschuster/devel/cola/idst/function/jolt2
LIBS = $(JOLT2)/boot.k
FLAGS = 
MAIN = src/bfxp.k src/bfxp-grammar.k
RUN = $(JOLT2)/main $(FLAGS) $(LIBS) src/brainfuck-print.k $(MAIN)

.PHONY: doc

all :   test

doc :
	@cd doc; make	

check : $(MAIN)
	$(JOLT2)/main $(FLAGS) $(LIBS) $(MAIN)

test :  $(MAIN) examples/a8.bfxp
	$(RUN) examples/a8.bfxp

fib  :  $(MAIN) examples/minifib.bfxp
	$(RUN) examples/minifib.bfxp

counter :  $(MAIN) examples/counter.bfxp
	$(RUN) examples/counter.bfxp

clean : 
	rm -f *~ *.so
	@cd doc ; make clean
