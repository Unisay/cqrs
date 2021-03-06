module Data.CQRS.Memory.Internal.Storage
    ( Event(..)
    , Store(..)
    , Storage(..)
    , eAggregateId
    , newStorage
    ) where

import           Control.Concurrent.STM (atomically)
import           Control.Concurrent.STM.TVar (TVar, newTVar)
import           Data.CQRS.Types.PersistedEvent (PersistedEvent(..))
import           Data.Int (Int64)
import           Data.Sequence (Seq)
import qualified Data.Sequence as S

data Event i e =
    Event { ePersistedEvent :: PersistedEvent i e
          , eTimestamp :: Int64
          }
    deriving (Show)

-- | Extract aggregate ID of event.
eAggregateId :: Event i e -> i
eAggregateId (Event pe _) = peAggregateId pe

data Store i e = Store
    { msEvents :: Seq (Event i e)
      -- Current global time stamp. Starts at 1.
    , msCurrentTimestamp :: Int64
    }

-- | Storage used for memory-backed EventStore.
newtype Storage i e = Storage (TVar (Store i e))

-- | Create backing memory for a memory-based event store
-- or archive store.
newStorage :: IO (Storage i e)
newStorage = atomically $ fmap Storage $ newTVar $ Store S.empty 1
