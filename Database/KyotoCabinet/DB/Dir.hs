{-|
Directory hash database.

Respective files stored in a directory of the file system.

* Persistence: /persistent/

* Algorithm: /undefined/

* Complexity: /undefined/

* Sequence: /undefined/

* Lock unit: /record (rwlock)/
-}
module Database.KyotoCabinet.DB.Dir
       ( Dir
       , DirOptions (..)
       , defaultDirOptions
       , Compressor (..)
       , Options (..)
       , Comparator (..)
       , makeDir
       , openDir
       )
       where

import Data.Int (Int64, Int8)
import Data.Maybe (maybeToList)

import Prelude hiding (log)

import Database.KyotoCabinet.Internal
import Database.KyotoCabinet.Operations

newtype Dir = Dir DB

instance WithDB Dir where
  getDB (Dir db) = db

data DirOptions = DirOptions { alignmentPow :: Maybe Int8
                             , freePoolPow :: Maybe Int8
                             , options :: [Options]
                             , buckets :: Maybe Int64
                             , maxSize :: Maybe Int64
                             , defragInterval :: Maybe Int64
                             , compressor :: Maybe Compressor
                             , cipherKey :: Maybe String
                             }
                 deriving (Show, Read, Eq, Ord)

defaultDirOptions :: DirOptions
defaultDirOptions = DirOptions { alignmentPow = Nothing
                               , freePoolPow = Nothing
                               , options = []
                               , buckets = Nothing
                               , maxSize = Nothing
                               , defragInterval = Nothing
                               , compressor = Nothing
                               , cipherKey = Nothing
                               }

toTuningOptions :: DirOptions -> [TuningOption]
toTuningOptions DirOptions { alignmentPow = ap
                           , freePoolPow = fp
                           , options = os
                           , buckets = bs
                           , maxSize = ms
                           , defragInterval = di
                           , compressor = cmp
                           , cipherKey = key
                           } =
  mtl AlignmentPow ap ++ mtl FreePoolPow fp ++ map Options os ++ mtl Buckets bs ++
  mtl MaxSize ms ++ mtl DefragInterval di ++ mtl Compressor cmp ++ mtl CipherKey key
  where
    mtl f = maybeToList .  fmap f

className :: String
className = "kcd"

makeDir :: FilePath -> LoggingOptions -> DirOptions -> Mode -> IO Dir
makeDir fp log opts mode = makePersistent Dir toTuningOptions className fp log opts mode

openDir :: FilePath -> LoggingOptions -> Mode -> IO Dir
openDir fp log mode = openPersistent Dir className fp log mode
