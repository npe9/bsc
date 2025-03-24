module SATPred(
  SATPredState,
  initSATPredState,
  solvePred
  ) where

import Flags
import Pred

import qualified Pred2SBV as SBV
         (SBVState, initSBVState, solvePred)

-- -------------------------

-- A single data type for the solver state
newtype SATPredState = SATPredSSBV SBV.SBVState

-- -------------------------

initSATPredState :: Flags -> IO SATPredState
initSATPredState _ = do
    sbv_state <- SBV.initSBVState "" undefined False [] [] []
    return (SATPredSSBV sbv_state)

-- -------------------------

{-
checkPreds :: SATPredState -> [Pred] -> IO ([EMsg], SATPredState)
checkPreds (SATPredS_STP stp_state) ps = do
    (res, stp_state') <- STP.checkPreds stp_state ps
    return (res, SATPredS_STP stp_state')
checkPreds (SATPredS_Yices yices_state) ps = do
    (res, yices_state') <- Yices.checkPreds yices_state ps
    return (res, SATPredS_Yices yices_state')
-}

-- -------------------------

solvePred :: SATPredState -> [Pred] -> Pred -> IO (Maybe Pred, SATPredState)
solvePred (SATPredSSBV sbv_state) ps p = do
    (res, sbv_state') <- SBV.solvePred sbv_state ps p
    return (res, SATPredSSBV sbv_state')

-- -------------------------

