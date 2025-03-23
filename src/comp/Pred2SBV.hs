module Pred2SBV(
       SState,
       initSState,
       solvePred
) where

import Control.Monad(when)
import Control.Monad.State(StateT, liftIO, gets, get, put, runStateT)
import qualified Data.Map as M
import Data.SBV
import Data.SBV.Control

import PFPrint
import Id
import PreIds
import CType
import Type
import Pred

import Debug.Trace(traceM)
import IOUtil(progArgs)

traceTest :: Bool
traceTest = "-trace-smt-test" `elem` progArgs

traceConv :: Bool
traceConv = "-trace-smt-conv" `elem` progArgs

-- -------------------------

data SState =
    SState {
               -- source of unique identifiers
               unknownId     :: Integer,

               -- a map from types to their converted form
               -- (this is used both to avoid duplicate conversion
               -- and as a list of possible terms for solving)
               typeSExprMap   :: M.Map Type (SVal, [SVal])
              }

type SM = StateT SState IO

-- represent numeric types as 32-bit vectors
-- (since that provides a division operator and log/exp via shifting)
intWidth :: (Integral t) => t
intWidth = 32

-- -------------------------

initSState :: IO SState
initSState = do
  return (SState { unknownId = 0,
                   typeSExprMap = M.empty
                 })

-- -------------------------

solvePred :: SState -> [Pred] -> Pred -> IO (Maybe Pred, SState)
solvePred s ps p = runStateT (solvePredM ps p) s

solvePredM :: [Pred] -> Pred -> SM (Maybe Pred)
solvePredM ps p = do
  when traceTest $ traceM ("solvePred: " ++ ppReadable p)

  -- check that the pred is one that we handle, and if so then
  -- construct p as an inequality (along with its additional assertions)
  m_yneq <- genPredInequality p
  case m_yneq of
    Nothing -> do
      -- the pred is not of the form that we can handle
      when traceTest $ traceM("solvePred: not handled")
      return Nothing
    Just (yneq, as) -> do
      -- first make sure that the preds have at least one solution
      is_sat <- do
          -- assert the given provisos
          mapM_ assertPred (p:ps)
          -- check if there exists a solution
          sat <- checkSAT
          return (sat == Just True)

      -- if there is no solution, return the pred unsatisfied
      -- (if an error needs to be reported, it will be reported later)
      if not is_sat then
        do when traceTest $ traceM("solvePred: not satisfiable")
           return Nothing
      else
        do mapM_ assertPred ps
           mapM_ (liftIO . assert) (yneq:as)
           sat <- checkSAT
           let res = case sat of
                      Just False -> Just p
                      _ -> Nothing
           when traceTest $
             case res of
               Nothing -> traceM("solvePred: unresolved: " ++ ppReadable p)
               Just _  -> traceM("solvePred: resolved: " ++ ppReadable p)
           return res

genPredInequality :: Pred -> SM (Maybe (SVal, [SVal]))
genPredInequality p@(IsIn c [t1, t2]) | classId c == idNumEq = do
  when traceTest $ traceM("pred: " ++ ppReadable p)
  (yt1, as1) <- convType2SExpr t1
  (yt2, as2) <- convType2SExpr t2
  ynp <- liftIO $ (yt1 :: SWord32) ./= (yt2 :: SWord32)
  return $ Just (ynp, as1 ++ as2)
genPredInequality p@(IsIn c [t1, t2, t3]) | classId c == idAdd = do
  when traceTest $ traceM("pred: " ++ ppReadable p)
  (yt3, as3) <- convType2SExpr t3
  (yadd, as12) <- convType2SExpr (TAp (TAp tAdd t1) t2)
  ynp <- liftIO $ (yadd :: SWord32) ./= (yt3 :: SWord32)
  return $ Just (ynp, as3 ++ as12)
genPredInequality p@(IsIn c [t1, t2, t3]) | classId c == idMul = do
  when traceTest $ traceM("pred: " ++ ppReadable p)
  (yt3, as3) <- convType2SExpr t3
  (ymul, as12) <- convType2SExpr (TAp (TAp tMul t1) t2)
  ynp <- liftIO $ (ymul :: SWord32) ./= (yt3 :: SWord32)
  return $ Just (ynp, as3 ++ as12)
genPredInequality p@(IsIn c [t1, t2, t3]) | classId c == idMax = do
  when traceTest $ traceM("pred: " ++ ppReadable p)
  (yt3, as3) <- convType2SExpr t3
  (ymax, as12) <- convType2SExpr (TAp (TAp tMax t1) t2)
  ynp <- liftIO $ (ymax :: SWord32) ./= (yt3 :: SWord32)
  return $ Just (ynp, as3 ++ as12)
genPredInequality p@(IsIn c [t1, t2, t3]) | classId c == idMin = do
  when traceTest $ traceM("pred: " ++ ppReadable p)
  (yt3, as3) <- convType2SExpr t3
  (ymin, as12) <- convType2SExpr (TAp (TAp tMin t1) t2)
  ynp <- liftIO $ (ymin :: SWord32) ./= (yt3 :: SWord32)
  return $ Just (ynp, as3 ++ as12)
genPredInequality p@(IsIn c [t1, t2, t3]) | classId c == idDiv = do
  when traceTest $ traceM("pred: " ++ ppReadable p)
  (yt3, as3) <- convType2SExpr t3
  (ydiv, as12) <- convType2SExpr (TAp (TAp tDiv t1) t2)
  ynp <- liftIO $ (ydiv :: SWord32) ./= (yt3 :: SWord32)
  return $ Just (ynp, as3 ++ as12)
genPredInequality p@(IsIn c [t1, t2, t3]) | classId c == idLog = do
  when traceTest $ traceM("pred: " ++ ppReadable p)
  (yt3, as3) <- convType2SExpr t3
  (ylog, as12) <- convType2SExpr (TAp (TAp tLog t1) t2)
  ynp <- liftIO $ (ylog :: SWord32) ./= (yt3 :: SWord32)
  return $ Just (ynp, as3 ++ as12)
genPredInequality p = do
  when traceTest $ traceM("pred unknown: " ++ ppReadable p)
  return Nothing

-- -------------------------

checkSAT :: SM (Maybe Bool)
checkSAT = do
  res <- liftIO $ runSMT $ do
    r <- checkSat
    case r of
      Sat -> return True
      Unsat -> return False
      Unk -> return False
  return $ Just res

-- -------------------------

-- Use these functions to make sure that info is added to the most recent maps.
-- If you have a local copy of the map around, but then call monadic functions,
-- the local copy may become stale, and you'll lose info if you write back the
-- stale copy.

addToTypeMap :: Type -> (SVal, [SVal]) -> SM ()
addToTypeMap t res = do
    s <- get
    let tmap = typeSExprMap s
        tmap' = M.insert t res tmap
    put (s {typeSExprMap = tmap' })

-- -------------------------

addUnknownType :: Type -> SM (SVal, [SVal])
addUnknownType t = do
    when traceConv $ traceM("addUnknownType: " ++ ppString t)
    tmap <- gets typeSExprMap
    case M.lookup t tmap of
      Just res -> do when traceConv $ traceM("   reusing.")
                     return res
      Nothing -> do
        when traceConv $ traceM("   making new var.")
        var <- liftIO $ free "x" :: IO SWord32
        let res = (var, [])
        addToTypeMap t res
        return res

-- -------------------------

convType2SExpr :: Type -> SM (SVal, [SVal])
convType2SExpr t = do
  when traceConv $ traceM("converting: " ++ ppReadable t)
  tmap <- gets typeSExprMap
  case M.lookup t tmap of
    Just res -> do when traceConv $ traceM("   reusing.")
                   return res
    Nothing -> do
      when traceConv $ traceM("   converting new.")
      yt <- convType2SExpr' t
      addToTypeMap t yt
      return yt

convType2SExpr' :: Type -> SM (SVal, [SVal])
convType2SExpr' t@(TVar {}) = do
  when traceConv $ traceM("conv TyVar: " ++ ppReadable t)
  addUnknownType t
convType2SExpr' t@(TCon (TyNum n _)) = do
  when traceConv $ traceM("conv TyNum: " ++ ppReadable n)
  res <- liftIO $ literal (fromIntegral n) :: IO SWord32
  return (res, [])
convType2SExpr' t@(TAp (TAp tc t1) t2) | tc == tAdd = do
  when traceConv $ traceM("conv TAdd: " ++ ppReadable t)
  (yt1, as1) <- convType2SExpr t1
  (yt2, as2) <- convType2SExpr t2
  res <- liftIO $ (yt1 :: SWord32) + (yt2 :: SWord32)
  return (res, as1 ++ as2)
convType2SExpr' t@(TAp (TAp tc t1) t2) | tc == tMul = do
  when traceConv $ traceM("conv TMul: " ++ ppReadable t)
  (yt1, as1) <- convType2SExpr t1
  (yt2, as2) <- convType2SExpr t2
  res <- liftIO $ (yt1 :: SWord32) * (yt2 :: SWord32)
  return (res, as1 ++ as2)
convType2SExpr' t@(TAp (TAp tc t1) t2) | tc == tDiv || tc == tLog = do
  when traceConv $ traceM("conv " ++ (if tc == tDiv then "TDiv" else "TLog") ++ ": " ++ ppReadable t)
  (yt1, as1) <- convType2SExpr t1
  (yt2, as2) <- convType2SExpr t2
  res <- liftIO $ (yt1 :: SWord32) `sDiv` (yt2 :: SWord32)
  return (res, as1 ++ as2)
convType2SExpr' t@(TAp (TAp tc t1) t2) | tc == tMax = do
  when traceConv $ traceM("conv TMax: " ++ ppReadable t)
  (yt1, as1) <- convType2SExpr t1
  (yt2, as2) <- convType2SExpr t2
  res <- liftIO $ max (yt1 :: SWord32) (yt2 :: SWord32)
  return (res, as1 ++ as2)
convType2SExpr' t@(TAp (TAp tc t1) t2) | tc == tMin = do
  when traceConv $ traceM("conv TMin: " ++ ppReadable t)
  (yt1, as1) <- convType2SExpr t1
  (yt2, as2) <- convType2SExpr t2
  res <- liftIO $ min (yt1 :: SWord32) (yt2 :: SWord32)
  return (res, as1 ++ as2)
convType2SExpr' t = do
  when traceConv $ traceM("conv unknown: " ++ ppReadable t)
  addUnknownType t

-- -------------------------

assertPred :: Pred -> SM ()
assertPred p = do
  when traceTest $ traceM("assertPred: " ++ ppReadable p)
  m_yneq <- genPredInequality p
  case m_yneq of
    Nothing -> return ()
    Just (yneq, as) -> do
      mapM_ (liftIO . assert) (yneq:as) 