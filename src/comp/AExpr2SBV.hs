module AExpr2SBV(
  SBVState,
  initSBVState,
  addADefToSBVState,
  checkBiImplication,
  isConstExpr,
  checkEq,
  checkNotEq,
  checkDisjointRulePairM,
  checkDisjointRulePair,
  checkDisjointRulePair2,
  checkDisjointRulePair3,
  checkDisjointExpr
  ) where

import qualified Data.Map as M
import Data.SBV
import Data.SBV.Control
import ASyntax (AExpr(..), ARuleId, aTBool, ADef, AVInst)
import Flags
import Prim
import IntLit
import Position
import Control.Monad
import Control.Monad.IO.Class
import System.IO.Unsafe (unsafePerformIO)

-- State to cache symbolic variables and expressions
newtype SBVState = SBVState {
    exprMap :: M.Map AExpr SBool  -- Cache for expressions
}

initSBVState :: String -> Flags -> Bool -> [ADef] -> [AVInst] -> [(ARuleId, [AExpr], Maybe ARuleId)] -> IO SBVState
initSBVState _ _ _ _ _ _ = return $ SBVState M.empty

addADefToSBVState :: SBVState -> [ADef] -> IO SBVState
addADefToSBVState state _ = return state

-- Convert AExpr to SBV symbolic value
fromAExpr :: AExpr -> Symbolic SBool
fromAExpr (ASInt _ _ lit) = return $ literal (ilValue lit == 1)
fromAExpr (APrim _ _ op args) = do
    vals <- mapM fromAExpr args
    case op of
        PrimBAnd -> return $ sAnd vals
        PrimBOr -> return $ sOr vals
        PrimBNot -> case vals of
            [v] -> return $ sNot v
            _ -> free_
        PrimEQ -> case vals of
            [v1, v2] -> return $ v1 .<+> v2
            _ -> free_
        _ -> free_
fromAExpr _ = free_

checkBiImplication :: SBVState -> AExpr -> AExpr -> IO ((Bool, Bool), SBVState)
checkBiImplication state e1 e2 = do
    result <- runSMTWith defaultSMTCfg $ do
        v1 <- fromAExpr e1
        v2 <- fromAExpr e2
        -- Check if e1 implies e2
        constrain (v1 .&& sNot v2)
        cs1 <- query checkSat
        let implies = cs1 == Unsat
        -- Check if e2 implies e1
        constrain (v2 .&& sNot v1)
        cs2 <- query checkSat
        let impliedBy = cs2 == Unsat
        return (implies, impliedBy)
    return (result, state)

isConstExpr :: SBVState -> AExpr -> IO (Maybe Bool, SBVState)
isConstExpr state e = do
    result <- runSMTWith defaultSMTCfg $ do
        v <- fromAExpr e
        -- Check if expression is constant true
        constrain (sNot v)
        cs1 <- query checkSat
        case cs1 of
            Unsat -> return $ Just True
            _ -> do
                -- Check if expression is constant false
                constrain v
                cs2 <- query checkSat
                case cs2 of
                    Unsat -> return $ Just False
                    _ -> return Nothing
    return (result, state)

checkEq :: SBVState -> AExpr -> AExpr -> IO (Maybe Bool, SBVState)
checkEq state e1 e2 = do
    result <- runSMTWith defaultSMTCfg $ do
        v1 <- fromAExpr e1
        v2 <- fromAExpr e2
        constrain (v1 ./= v2)
        cs <- query checkSat
        case cs of
            Unsat -> return $ Just True
            _ -> return Nothing
    return (result, state)

checkNotEq :: SBVState -> AExpr -> AExpr -> IO (Maybe Bool, SBVState)
checkNotEq state e1 e2 = do
    result <- runSMTWith defaultSMTCfg $ do
        v1 <- fromAExpr e1
        v2 <- fromAExpr e2
        constrain (v1 .== v2)
        cs <- query checkSat
        case cs of
            Unsat -> return $ Just True
            _ -> return Nothing
    return (result, state)

checkDisjointRulePairM :: MonadIO m => SBVState -> (ARuleId, ARuleId) -> m (Maybe Bool, SBVState)
checkDisjointRulePairM state (r1, r2) = liftIO $ do
    let e1 = ASInt r1 aTBool (ilSizedDec 1 1)
        e2 = ASInt r2 aTBool (ilSizedDec 1 1)
    -- First check if the rules can be true simultaneously
    result1 <- runSMTWith defaultSMTCfg $ do
        v1 <- fromAExpr e1
        v2 <- fromAExpr e2
        constrain (v1 .&& v2)
        query checkSat
    case result1 of
        Unsat -> return (Just True, state)  -- Rules are disjoint
        Sat -> do
            -- If they can be true simultaneously, check if one implies the other
            result2 <- runSMTWith defaultSMTCfg $ do
                v1 <- fromAExpr e1
                v2 <- fromAExpr e2
                constrain (v1 .=> v2)  -- Check if rule1 implies rule2
                query checkSat
            case result2 of
                Unsat -> return (Just True, state)  -- Rule1 never implies Rule2
                _ -> do
                    -- Check if rule2 implies rule1
                    result3 <- runSMTWith defaultSMTCfg $ do
                        v1 <- fromAExpr e1
                        v2 <- fromAExpr e2
                        constrain (v2 .=> v1)  -- Check if rule2 implies rule1
                        query checkSat
                    case result3 of
                        Unsat -> return (Just True, state)  -- Rule2 never implies Rule1
                        _ -> return (Nothing, state)  -- Can't prove disjointness
        _ -> return (Nothing, state)  -- Unknown result

-- For backwards compatibility, keep the non-monadic version but implement it in terms of M
checkDisjointRulePair :: SBVState -> (ARuleId, ARuleId) -> IO (Maybe Bool, SBVState)
checkDisjointRulePair = checkDisjointRulePairM

-- Specialized version for IO monad
checkDisjointRulePair2 :: SBVState -> (ARuleId, ARuleId) -> IO (Maybe Bool, SBVState)
checkDisjointRulePair2 = checkDisjointRulePairM

-- Specialized version for StateT monad
checkDisjointRulePair3 :: MonadIO m => SBVState -> (ARuleId, ARuleId) -> m (Maybe Bool, SBVState)
checkDisjointRulePair3 = checkDisjointRulePairM

checkDisjointExpr :: SBVState -> AExpr -> AExpr -> IO (Maybe Bool, SBVState)
checkDisjointExpr state e1 e2 = do
    result <- runSMTWith defaultSMTCfg $ do
        v1 <- fromAExpr e1
        v2 <- fromAExpr e2
        constrain (v1 .&& v2)  -- Check if expressions can be true simultaneously
        cs <- query checkSat
        case cs of
            Unsat -> return $ Just True
            _ -> return Nothing
    return (result, state) 