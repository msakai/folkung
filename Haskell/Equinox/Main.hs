module Equinox.Main where

import Sat
import qualified Main
import Form
import Flags
import Equinox.FolSat

---------------------------------------------------------------------------
-- main

main :: IO ()
main =
  do putStrLn "Equinox, version 1.1, 2007-05-21."
     Main.main solveProblem
  
---------------------------------------------------------------------------
-- solve

solveProblem :: (?flags :: Flags) => [Clause] -> IO Answer
solveProblem cs =
  do --sequence_ [ putStrLn (showClause c) | c <- cs ]
     b <- prove ?flags cs
     return (if b then Unsatisfiable else Unknown)

---------------------------------------------------------------------------
-- the end.
