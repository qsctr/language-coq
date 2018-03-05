-- This module is a wrapper for the extracted version of Data.Set.Internal

{-# LANGUAGE PatternSynonyms, ViewPatterns #-}

module ExtractedSet where

import qualified Base
import qualified Datatypes
import qualified BinNums

import qualified Semigroup
import qualified Monoid
import qualified Internal as S2

import qualified Data.Semigroup
import qualified Data.Monoid
import qualified Data.Foldable

----------------------------------------------------

instance Show BinNums.Coq_positive where
  show bn = reverse (go bn) where
    go BinNums.Coq_xH = "1"
    go (BinNums.Coq_xI bn) = '1' : go bn
    go (BinNums.Coq_xO bn) = 'O' : go bn
  

toPositive :: Int -> BinNums.Coq_positive
toPositive x | x <= 0 = error "must call with positive int"
toPositive 1 = BinNums.Coq_xH
toPositive x = let b1 = x `mod` 2
                   b2 = x `div` 2 in
               if b1 == 1 then BinNums.Coq_xI (toPositive b2) else
                               BinNums.Coq_xO (toPositive b2)

fromPositive :: BinNums.Coq_positive -> Int
fromPositive BinNums.Coq_xH = 1
fromPositive (BinNums.Coq_xI bn) = fromPositive bn * 2 + 1
fromPositive (BinNums.Coq_xO bn) = fromPositive bn * 2
 
toBinZ :: Int -> BinNums.Z
toBinZ 0 = BinNums.Z0
toBinZ x | x < 0 = BinNums.Zneg (toPositive (abs x))
toBinZ x | x > 0 = BinNums.Zpos (toPositive x)

fromBinZ :: BinNums.Z -> Int
fromBinZ BinNums.Z0 = 0
fromBinZ (BinNums.Zneg bn) = - (fromPositive bn)
fromBinZ (BinNums.Zpos bn) = fromPositive bn

----------------------------------------------------


eq_a :: Eq a => Base.Eq_ a
eq_a _ f = f (Base.Eq___Dict_Build (==) (/=))

ord_a :: Prelude.Ord a => Base.Ord a
ord_a _ = Base.ord_default Prelude.compare eq_a
  
semigroup_a :: Data.Semigroup.Semigroup a => Semigroup.Semigroup a
semigroup_a _ f = f ((Data.Semigroup.<>))

monoid_a :: Data.Monoid.Monoid a => Base.Monoid a
monoid_a _ f = f (Base.Monoid__Dict_Build Data.Monoid.mappend
                   Data.Monoid.mconcat Data.Monoid.mempty)

----------------------------------------------------

type Set = S2.Set_

instance (Eq a) => Eq (S2.Set_ a) where
  (==) = S2.coq_Eq___Set__op_zeze__ eq_a
  (/=) = S2.coq_Eq___Set__op_zsze__ eq_a

instance (Prelude.Ord a) => Prelude.Ord (S2.Set_ a) where
  compare = S2.coq_Ord__Set__compare eq_a ord_a
  (>)     = S2.coq_Ord__Set__op_zg__ eq_a ord_a
  (>=)    = S2.coq_Ord__Set__op_zgze__ eq_a ord_a
  (<)     = S2.coq_Ord__Set__op_zl__ eq_a ord_a
  (<=)    = S2.coq_Ord__Set__op_zlze__ eq_a ord_a
  max     = S2.coq_Ord__Set__max eq_a ord_a
  min     = S2.coq_Ord__Set__min eq_a ord_a

instance (Prelude.Ord a) => Data.Semigroup.Semigroup (S2.Set_ a) where
  (<>)    = S2.coq_Semigroup__Set__op_zlzg__ eq_a ord_a
  sconcat = error "no defn"
  stimes  = error "no defn"

instance (Prelude.Ord a) => Data.Monoid.Monoid (S2.Set_ a) where
  mempty  = S2.coq_Monoid__Set__mempty  eq_a ord_a
  mappend = S2.coq_Monoid__Set__mappend eq_a ord_a
  mconcat = S2.coq_Monoid__Set__mconcat eq_a ord_a

instance (Show a) => Show (S2.Set_ a) where
  showsPrec p xs = showParen (p > 10) $
    showString "fromList " . shows (Data.Foldable.toList xs)


instance Data.Foldable.Foldable S2.Set_ where
  fold    = S2.coq_Foldable__Set__fold    monoid_a
  foldMap = S2.coq_Foldable__Set__foldMap monoid_a
  foldr   = S2.foldr
  foldr'  = S2.foldr'
  foldl   = S2.foldl
  foldl'  = S2.foldl'
  foldr1  = error "partial"
  foldl1  = error "partial"
  toList  = S2.toList
  null    = S2.null
  length  = error "fix int problem" -- S2.length
  elem    = S2.coq_Foldable__Set__elem eq_a
  maximum = error "partial"
  minimum = error "partial"
  sum     = error "TODO"
  product = error "TODO"
  
toAscList :: Set a -> [a]
toAscList = S2.toAscList

fromAscList :: Eq a => [a] -> Set a
fromAscList = S2.fromAscList eq_a

fromList :: Prelude.Ord a => [a] -> Set a
fromList = S2.fromList eq_a ord_a

----------------------------------------------------------------
-- for unit tests
----------------------------------------------------------------

lookupLT :: Prelude.Ord a => a -> Set a -> Maybe a
lookupLT = S2.lookupLT eq_a ord_a

lookupGT :: Prelude.Ord a => a -> Set a -> Maybe a
lookupGT = S2.lookupGT eq_a ord_a

lookupLE :: Prelude.Ord a => a -> Set a -> Maybe a
lookupLE = S2.lookupLE eq_a ord_a

lookupGE :: Prelude.Ord a => a -> Set a -> Maybe a
lookupGE = S2.lookupGE eq_a ord_a


--------------------------------------------------
-- Indexed
--------------------------------------------------

lookupIndex :: Prelude.Ord a => a -> Set a -> Maybe Int
lookupIndex x s = fromBinZ <$> S2.lookupIndex eq_a ord_a x s

findIndex   = error "findIndex: partial function"
elemAt      = error "elemAt: partial function"
deleteAt    = error "deleteAt: partial function"

--------------------------------------------------
-- Valid Trees
--------------------------------------------------
valid :: Prelude.Ord a => Set a -> Bool
valid = S2.valid eq_a ord_a

pattern Tip = S2.Tip

-- I dunno how to get pattern synonyms to do this
bin s = S2.Bin (toBinZ s)

-- need to translate BinNums.Z -> Int
size :: Set a -> Int
size x = fromBinZ (S2.size x)

--------------------------------------------------
-- Single, Member, Insert, Delete
--------------------------------------------------
empty :: Set a
empty = S2.empty

singleton :: a -> Set a
singleton = S2.singleton

member :: Prelude.Ord a => a -> Set a -> Bool
member = S2.member eq_a ord_a

notMember :: Prelude.Ord a => a -> Set a -> Bool
notMember = S2.notMember eq_a ord_a

insert :: Prelude.Ord a => a -> Set a -> Set a
insert = S2.insert eq_a ord_a

delete :: Prelude.Ord a => a -> Set a -> Set a
delete = S2.delete eq_a ord_a

mapMonotonic :: (a1 -> a2) -> Set a1 -> Set a2
mapMonotonic = S2.mapMonotonic

{--------------------------------------------------------------------
  Balance
--------------------------------------------------------------------}

split :: Prelude.Ord a => a -> Set a -> (Set a, Set a)
split = S2.split eq_a ord_a

link = S2.link

merge = S2.merge

{--------------------------------------------------------------------
  Union
--------------------------------------------------------------------}

union :: Prelude.Ord a1 => (Set a1) -> (Set a1) -> Set a1
union = S2.union eq_a ord_a

difference :: Prelude.Ord a1 => (Set a1) -> (Set a1) -> Set a1
difference = S2.difference eq_a ord_a

intersection :: Prelude.Ord a1 => (Set a1) -> (Set a1) -> Set a1
intersection = S2.intersection eq_a ord_a

disjoint :: Prelude.Ord a1 => (Set a1) -> (Set a1) -> Bool
disjoint = S2.disjoint eq_a ord_a

null :: Set a -> Bool
null = S2.null