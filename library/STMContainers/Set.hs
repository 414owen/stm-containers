module STMContainers.Set
(
  Set,
  Element,
  new,
  insert,
  delete,
  lookup,
  foldM,
  null,
)
where

import STMContainers.Prelude hiding (insert, delete, lookup, alter, foldM, toList, empty, null)
import qualified STMContainers.HAMT as HAMT
import qualified STMContainers.HAMT.Nodes as HAMTNodes
import qualified Focus


-- |
-- A hash set, based on an STM-specialized hash array mapped trie.
type Set e = HAMT.HAMT (HAMTElement e)

-- |
-- A standard constraint for elements.
type Element a = (Eq a, Hashable a)

newtype HAMTElement e = HAMTElement e

instance (Eq e) => HAMTNodes.Element (HAMTElement e) where
  type ElementKey (HAMTElement e) = e
  elementKey (HAMTElement e) = e

{-# INLINABLE elementValue #-}
elementValue :: HAMTElement e -> e
elementValue (HAMTElement e) = e

-- |
-- Insert a new element.
{-# INLINABLE insert #-}
insert :: (Element e) => e -> Set e -> STM ()
insert e = HAMT.insert (HAMTElement e)

-- |
-- Delete an element.
{-# INLINABLE delete #-}
delete :: (Element e) => e -> Set e -> STM ()
delete = HAMT.focus Focus.deleteM

-- |
-- Lookup an element.
{-# INLINABLE lookup #-}
lookup :: (Element e) => e -> Set e -> STM Bool
lookup e = fmap (maybe False (const True)) . HAMT.focus Focus.lookupM e

-- |
-- Fold all the elements.
{-# INLINABLE foldM #-}
foldM :: (a -> e -> STM a) -> a -> Set e -> STM a
foldM f = HAMT.foldM (\a -> f a . elementValue)

-- |
-- Construct a new set.
{-# INLINABLE new #-}
new :: STM (Set e)
new = HAMT.new

-- |
-- Check, whether the set is empty.
{-# INLINABLE null #-}
null :: Set e -> STM Bool
null = HAMT.null
