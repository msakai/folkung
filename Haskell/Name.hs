module Name
  ( Name       -- :: *; Show, Eq, Ord, Hash
  , (%)        -- :: Name -> Int -> Name
  , name, prim -- :: String -> Name
  , strip      -- :: Name -> Name
  
  -- names
  , vr, sk, dp, sp, tr, dm, un, df, el, eq
  , isSimpleName
  , isSkolemnName
  , isEltName
  , getIndex
  )
 where

import Str

---------------------------------------------------------------------------
-- name

data Name
  = Name !Str
  | Prim !Str
  | !Name :% Int
 deriving ( Eq, Ord )

instance Show Name where
  show (Name a)  = show a
  show (Prim a)  = "$" ++ show a
  show (nm :% i) = show nm ++ "!" ++ show i

-- functions

name :: String -> Name
name s = Name (str s)

prim :: String -> Name
prim s = Prim (str s)

(%) :: Name -> Int -> Name
n % i = n :% i

strip :: Name -> Name
strip (n :% _) = strip n
strip n        = n

-- internal names

vr = prim "X"
eq = prim "eq"
sk = prim "sk"
dp = prim "dp"
sp = prim "sp"
tr = prim "truth"
dm = prim "dm"
un = prim "un"
df = prim "df"
el = name ""

isName :: (Name -> Bool) -> Name -> Bool
isName p n | p n  = True
isName p (n :% _) = isName p n
isName p _        = False

isSimpleName (Name _) = True
isSimpleName _        = False

isSkolemnName = isName (== sk)
isEltName     = isName (== el)

getIndex :: Name -> Int
getIndex (_ :% i) = i
getIndex _        = 0

---------------------------------------------------------------------------
-- the end.

