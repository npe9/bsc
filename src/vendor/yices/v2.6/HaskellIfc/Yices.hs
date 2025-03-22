{-# LANGUAGE ForeignFunctionInterface   #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeSynonymInstances       #-}
{-# LANGUAGE CPP #-}

module Yices (
    -- * Types
    Context,
    Expr,
    Status(..),
    Type,
    YContext,
    YExpr,
    YType,
    
    -- * Context functions
    newContext,
    mkContext,
    ctxPush,
    ctxPop,
    ctxStatus,
    
    -- * Assertion functions
    assert,
    assertFormula,
    checkSat,
    
    -- * Type creation
    mkBoolType,
    mkBitVectorType,
    
    -- * Term creation
    mkTrue,
    mkFalse,
    mkNot,
    mkAnd,
    mkOr,
    mkXor,
    mkIff,
    mkImplies,
    mkIte,
    mkEq,
    mkNEq,
    
    -- * Constant creation
    mkConstant,
    mkBVConstant,
    mkBVConstantInt,
    mkBVConstantStr,
    mkBVConstantOne,
    mkBVConstantFromInteger,
    
    -- * Variable creation
    mkVar,
    mkUninterpretedTerm,
    
    -- * BV operations
    mkBVNot,
    mkBVAnd,
    mkBVOr,
    mkBVXor,
    mkBVXOr,
    mkBVShiftLeft,
    mkBVShiftRight,
    mkBVShiftRightLogical,
    mkBVShiftRightArith,
    mkBVConcat,
    mkBVExtract,
    mkBVBoolExtract,
    mkBVMinus,
    mkBVSignExtend,
    
    -- * BV arithmetic
    mkBVAdd,
    mkBVSub,
    mkBVMul,
    mkBVDiv,
    mkBVRem,
    
    -- * BV comparison
    mkBVEq,
    mkBVNEq,
    mkBVLt,
    mkBVLe,
    mkBVGt,
    mkBVGe,
    mkBVSlt,
    mkBVSle,
    
    -- * Miscellaneous
    mkBoolsToBitVector,
    
    -- * Version
    yicesVersionCheck,
    checkVersion
) where

import Foreign.C.String (CString, withCString)
import Foreign.C.Types (CInt(..))
import Foreign.Ptr (Ptr, nullPtr)
import Control.Monad (void)
import Data.Word (Word32)
import YicesFFI hiding (YContext, YExpr, YType)

-- Types
data YContext = YContext
data YExpr = YExpr
data YType = YType
data Status = Satisfiable | Unsatisfiable | Unknown deriving (Eq, Show)
newtype Context = Context () deriving (Eq, Ord)
newtype Expr = Expr () deriving (Eq, Ord)
newtype Type = Type () deriving (Eq, Ord)

-- Context functions
newContext :: IO Context
newContext = return $ Context ()

mkContext :: IO Context
mkContext = return $ Context ()

ctxPush :: Context -> IO ()
ctxPush _ = return ()

ctxPop :: Context -> IO ()
ctxPop _ = return ()

ctxStatus :: Context -> IO Status
ctxStatus _ = return Unknown

-- Assertion functions
assert :: Context -> Expr -> IO ()
assert _ _ = return ()

assertFormula :: Context -> Expr -> IO ()
assertFormula _ _ = return ()

checkSat :: Context -> IO Status
checkSat _ = return Unknown

-- Type creation
mkBoolType :: IO Type
mkBoolType = return $ Type ()

mkBitVectorType :: Int -> IO Type
mkBitVectorType _ = return $ Type ()

-- Term creation
mkTrue :: IO Expr
mkTrue = return $ Expr ()

mkFalse :: IO Expr
mkFalse = return $ Expr ()

mkNot :: Expr -> IO Expr
mkNot _ = return $ Expr ()

mkAnd :: [Expr] -> IO Expr
mkAnd _ = return $ Expr ()

mkOr :: [Expr] -> IO Expr
mkOr _ = return $ Expr ()

mkXor :: Expr -> Expr -> IO Expr
mkXor _ _ = return $ Expr ()

mkIff :: Expr -> Expr -> IO Expr
mkIff _ _ = return $ Expr ()

mkImplies :: Expr -> Expr -> IO Expr
mkImplies _ _ = return $ Expr ()

mkIte :: Expr -> Expr -> Expr -> IO Expr
mkIte _ _ _ = return $ Expr ()

mkEq :: Expr -> Expr -> IO Expr
mkEq _ _ = return $ Expr ()

mkNEq :: Expr -> Expr -> IO Expr
mkNEq _ _ = return $ Expr ()

-- Constant creation
mkConstant :: String -> Type -> IO Expr
mkConstant _ _ = return $ Expr ()

mkBVConstant :: Int -> String -> IO Expr
mkBVConstant _ _ = return $ Expr ()

mkBVConstantInt :: Int -> Int -> IO Expr
mkBVConstantInt _ _ = return $ Expr ()

mkBVConstantStr :: Int -> String -> IO Expr
mkBVConstantStr _ _ = return $ Expr ()

mkBVConstantOne :: Int -> IO Expr
mkBVConstantOne _ = return $ Expr ()

mkBVConstantFromInteger :: Integer -> Integer -> IO Expr
mkBVConstantFromInteger _ _ = return $ Expr ()

-- Variable creation
mkVar :: String -> Type -> IO Expr
mkVar _ _ = return $ Expr ()

mkUninterpretedTerm :: Type -> IO Expr
mkUninterpretedTerm _ = return $ Expr ()

-- BV operations
mkBVNot :: Expr -> IO Expr
mkBVNot _ = return $ Expr ()

mkBVAnd :: Expr -> Expr -> IO Expr
mkBVAnd _ _ = return $ Expr ()

mkBVOr :: Expr -> Expr -> IO Expr
mkBVOr _ _ = return $ Expr ()

mkBVXor :: Expr -> Expr -> IO Expr
mkBVXor _ _ = return $ Expr ()

mkBVShiftLeft :: Expr -> Expr -> IO Expr
mkBVShiftLeft _ _ = return $ Expr ()

mkBVShiftRight :: Expr -> Expr -> IO Expr
mkBVShiftRight _ _ = return $ Expr ()

mkBVShiftRightLogical :: Expr -> Expr -> IO Expr
mkBVShiftRightLogical _ _ = return $ Expr ()

mkBVShiftRightArith :: Expr -> Expr -> IO Expr
mkBVShiftRightArith _ _ = return $ Expr ()

mkBVConcat :: Expr -> Expr -> IO Expr
mkBVConcat _ _ = return $ Expr ()

mkBVExtract :: Expr -> Word32 -> Word32 -> IO Expr
mkBVExtract _ _ _ = return $ Expr ()

mkBVBoolExtract :: Expr -> Word32 -> IO Expr
mkBVBoolExtract _ _ = return $ Expr ()

mkBVMinus :: Expr -> IO Expr
mkBVMinus _ = return $ Expr ()

mkBVSignExtend :: Expr -> Word32 -> IO Expr
mkBVSignExtend _ _ = return $ Expr ()

-- BV arithmetic
mkBVAdd :: Expr -> Expr -> IO Expr
mkBVAdd _ _ = return $ Expr ()

mkBVSub :: Expr -> Expr -> IO Expr
mkBVSub _ _ = return $ Expr ()

mkBVMul :: Expr -> Expr -> IO Expr
mkBVMul _ _ = return $ Expr ()

mkBVDiv :: Expr -> Expr -> IO Expr
mkBVDiv _ _ = return $ Expr ()

mkBVRem :: Expr -> Expr -> IO Expr
mkBVRem _ _ = return $ Expr ()

-- BV comparison
mkBVEq :: Expr -> Expr -> IO Expr
mkBVEq _ _ = return $ Expr ()

mkBVNEq :: Expr -> Expr -> IO Expr
mkBVNEq _ _ = return $ Expr ()

mkBVLt :: Expr -> Expr -> IO Expr
mkBVLt _ _ = return $ Expr ()

mkBVLe :: Expr -> Expr -> IO Expr
mkBVLe _ _ = return $ Expr ()

mkBVGt :: Expr -> Expr -> IO Expr
mkBVGt _ _ = return $ Expr ()

mkBVGe :: Expr -> Expr -> IO Expr
mkBVGe _ _ = return $ Expr ()

mkBVSlt :: Expr -> Expr -> IO Expr
mkBVSlt _ _ = return $ Expr ()

mkBVSle :: Expr -> Expr -> IO Expr
mkBVSle _ _ = return $ Expr ()

-- Miscellaneous
mkBoolsToBitVector :: [Expr] -> IO Expr
mkBoolsToBitVector _ = return $ Expr ()

-- Version
yicesVersionCheck :: IO Bool
yicesVersionCheck = return True

checkVersion :: IO String
checkVersion = return "Stub Yices 2.6.0"

-- Alias for XOR (correct typo)
mkBVXOr :: Expr -> Expr -> IO Expr
mkBVXOr = mkBVXor
