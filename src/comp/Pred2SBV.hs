{-# LANGUAGE FlexibleContexts #-}
module Pred2SBV(
       SBVState,
       initSBVState,
       solvePred
) where

import Control.Monad(when)
import Control.Monad.State(StateT, runStateT, get, put, gets, modify, lift)
import Data.SBV(MonadSymbolic, SBool, SWord32, sTrue, sFalse, literal, free, smax, smin, runSMTWith, defaultSMTCfg, constrain, (.==), Symbolic)
import Data.SBV.Control
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

-- | Our pure state holds a cache mapping a custom Type to its SBV expression.
newtype SBVState = SBVState { typeMap :: M.Map Type SWord32 }

-- | Our combined monad: a state transformer over the Symbolic monad.
type PureSM a = StateT SBVState Symbolic a

-- -------------------------

initSBVState :: String -> a -> Bool -> [ADef] -> [AVInst] -> [b] -> IO SBVState
initSBVState _ _ _ _ _ _ = return $ SBVState M.empty

-- -------------------------

-- | Convert a type to an SBV symbolic value, using a cache to avoid recomputation.
fromType :: Type -> PureSM SWord32
fromType t = do
    cache <- gets typeMap
    case M.lookup t cache of
      Just v  -> return v
      Nothing -> do
         when traceConv $ lift $ constrain sTrue  -- Hack to allow tracing in PureSM
         v <- case t of
                TCon (TyNum n _) -> return $ literal (fromIntegral n)
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
                        return (smax v1 v2)
                  | tc == tMin -> do
                        v1 <- fromType t1
                        v2 <- fromType t2
                        return (smin v1 v2)
                -- For unknown types, create a fresh symbolic variable
                _ -> lift $ free "x"
         modify (\s -> s { typeMap = M.insert t v cache })
         return v

-- | Convert a predicate to an SBV Boolean formula.
fromPred :: Pred -> PureSM SBool
fromPred (IsIn c [t1, t2, t3])
  | name c == CTypeclass idMax || name c == CTypeclass idMin = do
       v1 <- fromType t1
       v2 <- fromType t2
       v3 <- fromType t3
       let op = if name c == CTypeclass idMax then smax else smin
       return $ v3 .== op v1 v2
fromPred _ = return sTrue

-- | Solve the predicate by converting the assumptions and the goal symbolically,
-- then running the SMT solver.
solvePred :: SBVState -> [Pred] -> Pred -> IO (Maybe Pred, SBVState)
solvePred initState assumps p = do
    when traceTest $ traceM ("solvePred: " ++ ppReadable p)
    
    runSMTWith defaultSMTCfg $ do
        -- Run the pure conversion (with caching) in the Symbolic monad
        (finalFormula, finalState) <- runStateT (do
            -- Convert and assert all assumptions
            mapM_ (\pr -> do
                sbvPr <- fromPred pr
                lift $ constrain sbvPr) assumps
            -- Convert the target predicate
            fromPred p) initState

        -- Now, in query mode, check satisfiability
        query $ do
            constrain finalFormula
            cs <- checkSat
            case cs of
                Sat -> return (Nothing, finalState)  -- Predicate is satisfiable
                _   -> return (Just p, finalState)   -- Predicate is unsatisfiable

-- Assert a predicate in the SMT context
assertPred :: Pred -> PureSM ()
assertPred p = do
    p' <- fromPred p
    lift $ constrain p'

-- -------------------------

-- Use these functions to make sure that info is added to the most recent maps.
-- If you have a local copy of the map around, but then call monadic functions,
-- the local copy may become stale, and you'll lose info if you write back the
-- stale copy.

addToTypeMap :: Type -> SWord32 -> PureSM ()
addToTypeMap t res = do
    cache <- gets typeMap
    modify (\s -> s { typeMap = M.insert t res cache })

-- -------------------------

-- Convert a type to a symbolic expression
convType2SExpr :: Type -> PureSM SWord32
convType2SExpr t = do
    cache <- gets typeMap
    case M.lookup t cache of
        Just res -> return res
        Nothing -> do
            when traceConv $ lift $ constrain sTrue  -- Hack to allow tracing in PureSM
            var <- lift $ free "x"
            let res = var
            addToTypeMap t res
            return res 