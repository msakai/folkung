module Folkung where

{-
Paradox/Equinox -- Copyright (c) 2003-2007, Koen Claessen, Niklas Sorensson

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-}

import Form
import Flags
import ParseProblem
import Clausify
import Timeout ( timeout )

import Data.Maybe ( fromMaybe )
import System.Exit (exitWith, ExitCode(..))
import System.IO( hSetBuffering, stdout, BufferMode(..) )

import Output

---------------------------------------------------------------------------
-- main

main :: ((?flags :: Flags) => [Clause] -> IO Answer) -> IO ()
main solveProblem =
  do hSetBuffering stdout LineBuffering
     theFlags <- getFlags
     let ?flags = theFlags
     m <- timeout' (main' solveProblem)
     case m of 
       Nothing  -> do let ?flags = ?flags{ thisFile = unwords (files ?flags) }
                      putInfo ""
                      putWarning ("TIMEOUT (" ++ show (time ?flags) ++ " seconds)")
                      putResult Timeout
       _        -> return ()

main' :: (?flags :: Flags) => ((?flags :: Flags) => [Clause] -> IO Answer) -> IO ()
main' solveProblem =
  do require (not (null (files ?flags))) $
       putWarning "No input files specified! Try --help."

     sequence_
       [ do putOfficial ("PROBLEM: " ++ file)
            ins <- readProblemWithRoots ("" : map (++"/") (roots ?flags)) file
            let ?flags          = ?flags{ thisFile = file }
            putOfficial ("SOLVING: " ++ file)
            ans <- main'' solveProblem ins
            putResult ans
       | file <- files ?flags
       ]
        
main'' :: (?flags :: Flags) => ((?flags :: Flags) => [Clause] -> IO Answer) -> Problem -> IO Answer
main'' solveProblem ins =
         do --sequence_ [ print inp | inp <- ins ]
            let (theory,obligs) = clausify ins
                n               = length obligs

            case obligs of
              -- Satisfiable/Unsatisfiable
              [] ->
                do solveProblem theory
              
              -- CounterSatisfiable/Theorem
              [oblig] ->
                do ans <- solveProblem (theory ++ oblig)
                   return (nega ans)
              
              -- Unknown/Theorem
              obligs ->
                do let solveAll i [] =
                         do return Theorem
                       
                       solveAll i (oblig:obligs) =
                         do putSubHeader ("Part " ++ show i ++ "/" ++ show n)
                            ans <- solveProblem (theory ++ oblig)
                            putOfficial ("PARTIAL (" ++ show i ++ "/" ++ show n ++ "): " ++ show ans)
                            case ans of
                              Unsatisfiable -> solveAll (i+1) obligs
                              _             -> return GaveUp
                   
                   solveAll 1 obligs

require :: Bool -> IO () -> IO ()
require False m = do m; exitWith (ExitFailure 1)
require True  m = do return ()

-- Used by Paradox.Solve.solve and Equinox.Solve.solve
solve :: ((?flags :: Flags) => [Clause] -> IO Answer) -> Flags -> Problem -> IO Answer
solve solveProblem theFlags problem = 
  do let ?flags = theFlags
     ans <- timeout' (main'' solveProblem problem)
     return $ fromMaybe Timeout ans

timeout' :: (?flags :: Flags) => IO a -> IO (Maybe a)
timeout' f = case time ?flags of
               Nothing -> fmap Just f
               Just n  -> timeout (1000000 * n) f

---------------------------------------------------------------------------
-- the end.




