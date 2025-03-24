{-# LANGUAGE CPP #-}
module SAT(
           SATState,
           initSATState,
           checkBiImplication,
           isConstExpr,
           checkEq,
           checkNotEq,
           checkSATFlags
          ) where

import qualified Control.Exception as CE

import Error(ErrorHandle, bsError, ErrMsg(..))
import Flags
import ASyntax
import Position(cmdPosition)

import qualified AExpr2SBV as SBV
         (SBVState, initSBVState, checkBiImplication, isConstExpr,
          checkEq, checkNotEq)

-- -------------------------

-- A single data type for the solver state
newtype SATState = SATS_SBV SBV.SBVState

-- -------------------------

initSATState :: String -> ErrorHandle -> Flags -> Bool -> [ADef] -> [AVInst] ->
                IO SATState
initSATState str _ _ doHardFail ds avis = do
    sbv_state <- SBV.initSBVState str undefined doHardFail ds avis []
    return (SATS_SBV sbv_state)

checkSATFlags :: ErrorHandle -> Flags -> IO Flags
checkSATFlags _ f = return f

-- -------------------------

checkBiImplication :: SATState -> AExpr -> AExpr -> IO ((Bool, Bool), SATState)
checkBiImplication (SATS_SBV sbv_state) e1 e2 = do
    (res, sbv_state') <- SBV.checkBiImplication sbv_state e1 e2
    return (res, SATS_SBV sbv_state')

isConstExpr :: SATState -> AExpr -> IO (Maybe Bool, SATState)
isConstExpr (SATS_SBV sbv_state) e = do
    (res, sbv_state') <- SBV.isConstExpr sbv_state e
    return (res, SATS_SBV sbv_state')

checkEq :: SATState -> AExpr -> AExpr -> IO (Maybe Bool, SATState)
checkEq (SATS_SBV sbv_state) e1 e2 = do
    (res, sbv_state') <- SBV.checkEq sbv_state e1 e2
    return (res, SATS_SBV sbv_state')

checkNotEq :: SATState -> AExpr -> AExpr -> IO (Maybe Bool, SATState)
checkNotEq (SATS_SBV sbv_state) e1 e2 = do
    (res, sbv_state') <- SBV.checkNotEq sbv_state e1 e2
    return (res, SATS_SBV sbv_state')

-- -------------------------
