
#-- Variables

MINISAT = minisat/current-base
INST    = instantiate
HASKELL = Haskell

#-- Add this when compiling on Cygwin

#export EXTRACFLAGS=-mno-cygwin

#-- Main

main: mk-minisat mk-instantiate mk-haskell

mk-minisat:
	$(MAKE) Solver.or -C $(MINISAT)
	$(MAKE) Prop.or   -C $(MINISAT)

mk-instantiate:
	$(MAKE) MiniSatWrapper.or           -C $(INST)
	$(MAKE) MiniSatInstantiateClause.or -C $(INST)

mk-haskell:
	$(MAKE) -C $(HASKELL)

