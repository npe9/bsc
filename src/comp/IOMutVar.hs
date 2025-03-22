module IOMutVar(MutableVar, newVar, readVar, writeVar) where

import Data.IORef

<<<<<<< HEAD
-- Simple implementation using IORef
=======
>>>>>>> npe9/main
type MutableVar a = IORef a

newVar :: a -> IO (MutableVar a)
newVar = newIORef

readVar :: MutableVar a -> IO a
readVar = readIORef

writeVar :: MutableVar a -> a -> IO ()
writeVar = writeIORef 