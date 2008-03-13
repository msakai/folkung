#-- Add this when compiling on Cygwin

#export EXTRACFLAGS=-mno-cygwin

export HFLAGS += -static -optl-static

#-- Variables

MINISAT = minisat/current-base
INST    = instantiate
HASKELL = Haskell


#-- Variables

OBJS    = $(MINISAT)/Solver.or $(MINISAT)/Prop.or $(INST)/MiniSatWrapper.or $(INST)/MiniSatInstantiateClause.or
HFLAGS  += -cpp -lstdc++ -fglasgow-exts -O3 -I$(INST) -I$(MINISAT)
GHC     = ghc

.PHONY: all mk-minisat mk-instantiate mk-haskell install clean

#-- Main

all: mk-minisat mk-instantiate mk-haskell

mk-minisat:
	$(MAKE) Solver.or -C $(MINISAT)
	$(MAKE) Prop.or   -C $(MINISAT)

mk-instantiate:
	$(MAKE) MiniSatWrapper.or           -C $(INST)
	$(MAKE) MiniSatInstantiateClause.or -C $(INST)

mk-haskell: paradox equinox

#-- Paradox

paradox: Haskell/*.hs Haskell/Paradox/*.hs paradox/paradox.hs $(OBJS)
	$(GHC) $(HFLAGS)  --make paradox/paradox.hs -o paradox/paradox

#-- Equinox

equinox: Haskell/*.hs Haskell/Equinox/*.hs equinox/equinox.hs $(OBJS)
	$(GHC) $(HFLAGS) --make equinox/equinox.hs -o equinox/equinox

#-- Install

install: 

#-- Cleaning up

clean:
	$(MAKE) clean -C $(MINISAT)
	$(MAKE) clean -C $(INST)
	-rm -f Haskell/*.o Haskell/*.hi Haskell/Equinox/*.o Haskell/Equinox/*.hi Haskell/Paradox/*.o Haskell/Paradox/*.hi
	-rm -f paradox/paradox paradox/*.o paradox/*.hi
	-rm -f equinox/equinox equinox/*.o equinox/*.hi
