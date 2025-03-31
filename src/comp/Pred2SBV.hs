{-# LANGUAGE FlexibleContexts #-}
module Pred2SBV(
       SBVState,
       initSBVState,
       solvePred
) where

import Control.Monad(when)
import Control.Monad.State(StateT, runStateT, get, put, gets, modify, lift)
import qualified Data.Map as M
import Debug.Trace
import CType(typeclassId, Type(..), TyCon(..), CTypeclass(..))
import Type
import Pred
import Id
import PreIds
import PPrint
import Flags
import ErrorUtil
import ASyntax(ADef, AVInst)

import IOUtil(progArgs)

traceTest :: Bool
traceTest = "-trace-smt-test" `elem` progArgs

traceConv :: Bool
traceConv = "-trace-smt-conv" `elem` progArgs

-- -------------------------

-- | Our pure state holds a cache mapping a custom Type to its value.
newtype SBVState = SBVState { typeMap :: M.Map Type Integer }

-- | Our combined monad: a state transformer over IO.
type PureSM a = StateT SBVState IO a

-- -------------------------

initSBVState :: String -> a -> Bool -> [ADef] -> [AVInst] -> [b] -> IO SBVState
initSBVState _ _ _ _ _ _ = return $ SBVState M.empty

-- -------------------------

-- | Convert a type to an integer value, using a cache to avoid recomputation.
fromType :: Type -> PureSM Integer
fromType t = do
    cache <- gets typeMap
    case M.lookup t cache of
      Just v  -> return v
      Nothing -> do
         when traceConv $ return ()  -- Hack to allow tracing in PureSM
         v <- case t of
                TCon (TyNum n _) -> return $ fromIntegral n
                TAp (TAp tc t1) t2
                  | tc == tAdd -> do
                        v1 <- fromType t1
                        v2 <- fromType t2
                        return (v1 + v2)
                  | tc == tMul -> do
                        v1 <- fromType t1
                        v2 <- fromType t2
                        return (v1 * v2)
                  | tc == tMax -> do
                        v1 <- fromType t1
                        v2 <- fromType t2
                        return (max v1 v2)
                  | tc == tMin -> do
                        v1 <- fromType t1
                        v2 <- fromType t2
                        return (min v1 v2)
                -- For unknown types, return 0
                _ -> return 0
         modify (\s -> s { typeMap = M.insert t v cache })
         return v

-- | Convert a predicate to a boolean value.
fromPred :: Pred -> PureSM Bool
fromPred _ = return True

-- | Solve the predicate by always returning True.
solvePred :: SBVState -> [Pred] -> Pred -> IO (Maybe Pred, SBVState)
solvePred initState _ _ = do
    when traceTest $ traceM "solvePred: always returning True"
    return (Nothing, initState)

-- Assert a predicate in the context
assertPred :: Pred -> PureSM ()
assertPred _ = return ()

-- -------------------------

-- Use these functions to make sure that info is added to the most recent maps.
-- If you have a local copy of the map around, but then call monadic functions,
-- the local copy may become stale, and you'll lose info if you write back the
-- stale copy.

addToTypeMap :: Type -> Integer -> PureSM ()
addToTypeMap t res = do
    cache <- gets typeMap
    modify (\s -> s { typeMap = M.insert t res cache })

-- -------------------------

-- Convert a type to an integer expression
convType2SExpr :: Type -> PureSM Integer
convType2SExpr t = do
    cache <- gets typeMap
    case M.lookup t cache of
        Just res -> return res
        Nothing -> do
            when traceConv $ return ()  -- Hack to allow tracing in PureSM
            let res = 0
            addToTypeMap t res
            return res 