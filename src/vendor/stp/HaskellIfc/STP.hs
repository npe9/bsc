{-# LANGUAGE ForeignFunctionInterface #-}

module STP (
  -- * Types
  Context, Expr, Type, Result(..),
  -- * Context Management
  newContext, mkContext, createValidityChecker, push, ctxPush, pop, ctxPop,
  setPrintVarDecls, setPrintAsserts, setPrintQuery, setClearDecls,
  printExpr, query, makeQuery, makeQueryWithTimeout, assert, assertFormula,
  -- * Type Creation
  boolType, mkBoolType, bvType, mkBitVectorType,
  -- * Expression Creation
  boolToBV, mkBoolToBVExpr, varExpr, mkVar, trueExpr, mkTrue, falseExpr, mkFalse,
  bvConstExprFromLL, mkBVConstantFromInteger, bvConstExprFromStr,
  -- * Expression Operations
  equalExpr, mkEq, notExpr, mkNot, andExpr, mkAnd, andExprN, mkAndMany, orExpr, mkOr, orExprN, mkOrMany,
  xorExpr, impliesExpr, mkImplies, iffExpr, mkIff, iteExpr, mkIte,
  -- * Bitvector Operations
  bvPlusExpr, mkBVAdd, bvPlusExprN, bvMinusExpr, mkBVSub, bvMultExpr, mkBVMul, bvDivExpr, mkBVDiv, 
  bvModExpr, mkBVMod, sbvDivExpr, sbvModExpr, bvUMinusExpr, mkBVMinus,
  bvLtExpr, mkBVLt, bvLeExpr, mkBVLe, bvGtExpr, mkBVGt, bvGeExpr, mkBVGe,
  sbvLtExpr, mkBVSlt, sbvLeExpr, mkBVSle, sbvGtExpr, sbvGeExpr,
  bvAndExpr, mkBVAnd, bvOrExpr, mkBVOr, bvXorExpr, mkBVXor, bvNotExpr, mkBVNot,
  bvSignExtend, mkBVSignExtend, bvLeftShiftExpr, mkBVShiftLeft, bvRightShiftExpr, mkBVShiftRight,
  bvLeftShiftExprExpr, mkBVShiftLeftExpr, bvRightShiftExprExpr, mkBVShiftRightExpr, 
  bvSignedRightShiftExprExpr, mkBVSignedShiftRightExpr,
  bvConcatExpr, mkBVConcat, bvExtract, mkBVExtract, bvBoolExtractBit, mkBVBoolExtract,
  -- * Cleanup
  deleteExpr,
  -- * Options
  setFlag,
  -- * Version
  checkVersion
) where

import Foreign.Ptr
import Foreign.C.Types
import Foreign.C.String
import System.IO.Unsafe (unsafePerformIO)

-- | STP Context type
newtype Context = Context () deriving (Eq, Ord)

-- | STP Expression type
newtype Expr = Expr () deriving (Eq, Ord)

-- | STP Type type
newtype Type = Type () deriving (Eq, Ord)

-- | STP Result type
data Result = Valid | Invalid | Timeout | Error

-- | Create a new validity checker
newContext :: IO Context
newContext = return $ Context ()

-- | Create a validity checker (aliases)
mkContext :: IO Context
mkContext = newContext

createValidityChecker :: IO Context
createValidityChecker = newContext

-- | Push a context onto the stack
push :: Context -> IO ()
push _ = return ()

ctxPush :: Context -> IO ()
ctxPush = push

-- | Pop a context from the stack
pop :: Context -> IO ()
pop _ = return ()

ctxPop :: Context -> IO ()
ctxPop = pop

-- | Set whether to print variable declarations
setPrintVarDecls :: Context -> IO ()
setPrintVarDecls _ = return ()

-- | Set whether to print assertions
setPrintAsserts :: Context -> IO ()
setPrintAsserts _ = return ()

-- | Set whether to print the query
setPrintQuery :: Context -> IO ()
setPrintQuery _ = return ()

-- | Set whether to clear declarations
setClearDecls :: Context -> IO ()
setClearDecls _ = return ()

-- | Print an expression
printExpr :: Context -> Expr -> IO ()
printExpr _ _ = return ()

-- | Assert a formula (alias)
assert :: Context -> Expr -> IO ()
assert _ _ = return ()

-- | Make a query (alias)
query :: Context -> Expr -> IO Result
query _ _ = return Valid

-- | Make a query
makeQuery :: Context -> Expr -> IO Bool
makeQuery _ _ = return False

-- | Make a query with a timeout
makeQueryWithTimeout :: Context -> Expr -> Int -> IO Bool
makeQueryWithTimeout _ _ _ = return False

-- | Assert a formula
assertFormula :: Context -> Expr -> IO ()
assertFormula _ _ = return ()

-- | Check if an expression is a boolean
isBoolean :: Expr -> IO Bool
isBoolean _ = return True

-- | Create a boolean type
boolType :: Context -> IO Type
boolType _ = return $ Type ()

-- | Create a boolean type (alias)
mkBoolType :: Context -> IO Type
mkBoolType = boolType

-- | Create a bitvector type
bvType :: Context -> Int -> IO Type
bvType _ _ = return $ Type ()

-- | Create a bitvector type (alias)
mkBitVectorType :: Context -> Int -> IO Type
mkBitVectorType = bvType

-- | Convert a boolean to a bitvector
boolToBV :: Context -> Expr -> IO Expr
boolToBV _ _ = return $ Expr ()

-- | Convert a boolean to a bitvector (alias)
mkBoolToBVExpr :: Context -> Expr -> IO Expr
mkBoolToBVExpr = boolToBV

-- | Create a variable expression
varExpr :: Context -> String -> Type -> IO Expr
varExpr _ _ _ = return $ Expr ()

-- | Create a variable expression (alias)
mkVar :: Context -> String -> Type -> IO Expr
mkVar = varExpr

-- | Create a true expression
trueExpr :: Context -> IO Expr
trueExpr _ = return $ Expr ()

-- | Create a true expression (alias)
mkTrue :: Context -> IO Expr
mkTrue = trueExpr

-- | Create a false expression
falseExpr :: Context -> IO Expr
falseExpr _ = return $ Expr ()

-- | Create a false expression (alias)
mkFalse :: Context -> IO Expr
mkFalse = falseExpr

-- | Create a bitvector constant from a long long
bvConstExprFromLL :: Context -> Integer -> Integer -> IO Expr
bvConstExprFromLL _ _ _ = return $ Expr ()

-- | Create a bitvector constant from an integer (alias)
mkBVConstantFromInteger :: Context -> Integer -> Integer -> IO Expr
mkBVConstantFromInteger = bvConstExprFromLL

-- | Create a bitvector constant from a string
bvConstExprFromStr :: Context -> String -> IO Expr
bvConstExprFromStr _ _ = return $ Expr ()

-- | Create an equality expression
equalExpr :: Context -> Expr -> Expr -> IO Expr
equalExpr _ _ _ = return $ Expr ()

-- | Create an equality expression (alias)
mkEq :: Context -> Expr -> Expr -> IO Expr
mkEq = equalExpr

-- | Create a not expression
notExpr :: Context -> Expr -> IO Expr
notExpr _ _ = return $ Expr ()

-- | Create a not expression (alias)
mkNot :: Context -> Expr -> IO Expr
mkNot = notExpr

-- | Create an and expression
andExpr :: Context -> Expr -> Expr -> IO Expr
andExpr _ _ _ = return $ Expr ()

-- | Create an and expression (alias)
mkAnd :: Context -> Expr -> Expr -> IO Expr
mkAnd = andExpr

-- | Create an and expression with multiple operands
andExprN :: Context -> [Expr] -> IO Expr
andExprN _ _ = return $ Expr ()

-- | Create an and expression with multiple operands (alias)
mkAndMany :: Context -> [Expr] -> IO Expr
mkAndMany = andExprN

-- | Create an or expression
orExpr :: Context -> Expr -> Expr -> IO Expr
orExpr _ _ _ = return $ Expr ()

-- | Create an or expression (alias)
mkOr :: Context -> Expr -> Expr -> IO Expr
mkOr = orExpr

-- | Create an or expression with multiple operands
orExprN :: Context -> [Expr] -> IO Expr
orExprN _ _ = return $ Expr ()

-- | Create an or expression with multiple operands (alias)
mkOrMany :: Context -> [Expr] -> IO Expr
mkOrMany = orExprN

-- | Create a xor expression
xorExpr :: Context -> Expr -> Expr -> IO Expr
xorExpr _ _ _ = return $ Expr ()

-- | Create an implies expression
impliesExpr :: Context -> Expr -> Expr -> IO Expr
impliesExpr _ _ _ = return $ Expr ()

-- | Create an implies expression (alias)
mkImplies :: Context -> Expr -> Expr -> IO Expr
mkImplies = impliesExpr

-- | Create an iff expression
iffExpr :: Context -> Expr -> Expr -> IO Expr
iffExpr _ _ _ = return $ Expr ()

-- | Create an iff expression (alias)
mkIff :: Context -> Expr -> Expr -> IO Expr
mkIff = iffExpr

-- | Create an if-then-else expression
iteExpr :: Context -> Expr -> Expr -> Expr -> IO Expr
iteExpr _ _ _ _ = return $ Expr ()

-- | Create an if-then-else expression (alias)
mkIte :: Context -> Expr -> Expr -> Expr -> IO Expr
mkIte = iteExpr

-- | Create a bitvector plus expression
bvPlusExpr :: Context -> Int -> Expr -> Expr -> IO Expr
bvPlusExpr _ _ _ _ = return $ Expr ()

-- | Create a bitvector plus expression (alias)
mkBVAdd :: Context -> Int -> Expr -> Expr -> IO Expr
mkBVAdd = bvPlusExpr

-- | Create a bitvector plus expression with multiple operands
bvPlusExprN :: Context -> Int -> [Expr] -> IO Expr
bvPlusExprN _ _ _ = return $ Expr ()

-- | Create a bitvector minus expression
bvMinusExpr :: Context -> Int -> Expr -> Expr -> IO Expr
bvMinusExpr _ _ _ _ = return $ Expr ()

-- | Create a bitvector minus expression (alias)
mkBVSub :: Context -> Int -> Expr -> Expr -> IO Expr
mkBVSub = bvMinusExpr

-- | Create a bitvector multiply expression
bvMultExpr :: Context -> Int -> Expr -> Expr -> IO Expr
bvMultExpr _ _ _ _ = return $ Expr ()

-- | Create a bitvector multiply expression (alias)
mkBVMul :: Context -> Int -> Expr -> Expr -> IO Expr
mkBVMul = bvMultExpr

-- | Create a bitvector divide expression
bvDivExpr :: Context -> Int -> Expr -> Expr -> IO Expr
bvDivExpr _ _ _ _ = return $ Expr ()

-- | Create a bitvector divide expression (alias)
mkBVDiv :: Context -> Int -> Expr -> Expr -> IO Expr
mkBVDiv = bvDivExpr

-- | Create a bitvector modulo expression
bvModExpr :: Context -> Int -> Expr -> Expr -> IO Expr
bvModExpr _ _ _ _ = return $ Expr ()

-- | Create a bitvector modulo expression (alias)
mkBVMod :: Context -> Int -> Expr -> Expr -> IO Expr
mkBVMod = bvModExpr

-- | Create a signed bitvector divide expression
sbvDivExpr :: Context -> Int -> Expr -> Expr -> IO Expr
sbvDivExpr _ _ _ _ = return $ Expr ()

-- | Create a signed bitvector modulo expression
sbvModExpr :: Context -> Int -> Expr -> Expr -> IO Expr
sbvModExpr _ _ _ _ = return $ Expr ()

-- | Create a bitvector unary minus expression
bvUMinusExpr :: Context -> Expr -> IO Expr
bvUMinusExpr _ _ = return $ Expr ()

-- | Create a bitvector unary minus expression (alias)
mkBVMinus :: Context -> Expr -> IO Expr
mkBVMinus = bvUMinusExpr

-- | Create a bitvector less than expression
bvLtExpr :: Context -> Expr -> Expr -> IO Expr
bvLtExpr _ _ _ = return $ Expr ()

-- | Create a bitvector less than expression (alias)
mkBVLt :: Context -> Expr -> Expr -> IO Expr
mkBVLt = bvLtExpr

-- | Create a bitvector less than or equal expression
bvLeExpr :: Context -> Expr -> Expr -> IO Expr
bvLeExpr _ _ _ = return $ Expr ()

-- | Create a bitvector less than or equal expression (alias)
mkBVLe :: Context -> Expr -> Expr -> IO Expr
mkBVLe = bvLeExpr

-- | Create a bitvector greater than expression
bvGtExpr :: Context -> Expr -> Expr -> IO Expr
bvGtExpr _ _ _ = return $ Expr ()

-- | Create a bitvector greater than expression (alias)
mkBVGt :: Context -> Expr -> Expr -> IO Expr
mkBVGt = bvGtExpr

-- | Create a bitvector greater than or equal expression
bvGeExpr :: Context -> Expr -> Expr -> IO Expr
bvGeExpr _ _ _ = return $ Expr ()

-- | Create a bitvector greater than or equal expression (alias)
mkBVGe :: Context -> Expr -> Expr -> IO Expr
mkBVGe = bvGeExpr

-- | Create a signed bitvector less than expression
sbvLtExpr :: Context -> Expr -> Expr -> IO Expr
sbvLtExpr _ _ _ = return $ Expr ()

-- | Create a signed bitvector less than expression (alias)
mkBVSlt :: Context -> Expr -> Expr -> IO Expr
mkBVSlt = sbvLtExpr

-- | Create a signed bitvector less than or equal expression
sbvLeExpr :: Context -> Expr -> Expr -> IO Expr
sbvLeExpr _ _ _ = return $ Expr ()

-- | Create a signed bitvector less than or equal expression (alias)
mkBVSle :: Context -> Expr -> Expr -> IO Expr
mkBVSle = sbvLeExpr

-- | Create a signed bitvector greater than expression
sbvGtExpr :: Context -> Expr -> Expr -> IO Expr
sbvGtExpr _ _ _ = return $ Expr ()

-- | Create a signed bitvector greater than or equal expression
sbvGeExpr :: Context -> Expr -> Expr -> IO Expr
sbvGeExpr _ _ _ = return $ Expr ()

-- | Create a bitvector AND expression
bvAndExpr :: Context -> Expr -> Expr -> IO Expr
bvAndExpr _ _ _ = return $ Expr ()

-- | Create a bitvector AND expression (alias)
mkBVAnd :: Context -> Expr -> Expr -> IO Expr
mkBVAnd = bvAndExpr

-- | Create a bitvector OR expression
bvOrExpr :: Context -> Expr -> Expr -> IO Expr
bvOrExpr _ _ _ = return $ Expr ()

-- | Create a bitvector OR expression (alias)
mkBVOr :: Context -> Expr -> Expr -> IO Expr
mkBVOr = bvOrExpr

-- | Create a bitvector XOR expression
bvXorExpr :: Context -> Expr -> Expr -> IO Expr
bvXorExpr _ _ _ = return $ Expr ()

-- | Create a bitvector XOR expression (alias)
mkBVXor :: Context -> Expr -> Expr -> IO Expr
mkBVXor = bvXorExpr

-- | Create a bitvector NOT expression
bvNotExpr :: Context -> Expr -> IO Expr
bvNotExpr _ _ = return $ Expr ()

-- | Create a bitvector NOT expression (alias)
mkBVNot :: Context -> Expr -> IO Expr
mkBVNot = bvNotExpr

-- | Create a bitvector sign extend expression
bvSignExtend :: Context -> Expr -> Int -> IO Expr
bvSignExtend _ _ _ = return $ Expr ()

-- | Create a bitvector sign extend expression (alias)
mkBVSignExtend :: Context -> Expr -> Int -> IO Expr
mkBVSignExtend = bvSignExtend

-- | Create a bitvector left shift expression
bvLeftShiftExpr :: Context -> Int -> Expr -> IO Expr
bvLeftShiftExpr _ _ _ = return $ Expr ()

-- | Create a bitvector left shift expression (alias)
mkBVShiftLeft :: Context -> Expr -> Int -> IO Expr
mkBVShiftLeft ctx e i = bvLeftShiftExpr ctx i e

-- | Create a bitvector right shift expression
bvRightShiftExpr :: Context -> Int -> Expr -> IO Expr
bvRightShiftExpr _ _ _ = return $ Expr ()

-- | Create a bitvector right shift expression (alias)
mkBVShiftRight :: Context -> Expr -> Int -> IO Expr
mkBVShiftRight ctx e i = bvRightShiftExpr ctx i e

-- | Create a bitvector left shift expression with an expression shift amount
bvLeftShiftExprExpr :: Context -> Int -> Expr -> Expr -> IO Expr
bvLeftShiftExprExpr _ _ _ _ = return $ Expr ()

-- | Create a bitvector left shift expression with an expression shift amount (alias)
mkBVShiftLeftExpr :: Context -> Int -> Expr -> Expr -> IO Expr
mkBVShiftLeftExpr = bvLeftShiftExprExpr

-- | Create a bitvector right shift expression with an expression shift amount
bvRightShiftExprExpr :: Context -> Int -> Expr -> Expr -> IO Expr
bvRightShiftExprExpr _ _ _ _ = return $ Expr ()

-- | Create a bitvector right shift expression with an expression shift amount (alias)
mkBVShiftRightExpr :: Context -> Int -> Expr -> Expr -> IO Expr
mkBVShiftRightExpr = bvRightShiftExprExpr

-- | Create a bitvector signed right shift expression with an expression shift amount
bvSignedRightShiftExprExpr :: Context -> Int -> Expr -> Expr -> IO Expr
bvSignedRightShiftExprExpr _ _ _ _ = return $ Expr ()

-- | Create a bitvector signed right shift expression with an expression shift amount (alias)
mkBVSignedShiftRightExpr :: Context -> Int -> Expr -> Expr -> IO Expr
mkBVSignedShiftRightExpr = bvSignedRightShiftExprExpr

-- | Create a bitvector concatenate expression
bvConcatExpr :: Context -> Expr -> Expr -> IO Expr
bvConcatExpr _ _ _ = return $ Expr ()

-- | Create a bitvector concatenate expression (alias)
mkBVConcat :: Context -> Expr -> Expr -> IO Expr
mkBVConcat = bvConcatExpr

-- | Create a bitvector extract expression
bvExtract :: Context -> Expr -> Int -> Int -> IO Expr
bvExtract _ _ _ _ = return $ Expr ()

-- | Create a bitvector extract expression (extended interface)
mkBVExtract :: Context -> Int -> Int -> Expr -> IO Expr
mkBVExtract ctx lb ub e = bvExtract ctx e lb ub

-- | Extract a single bit from a bitvector and return it as a boolean
bvBoolExtractBit :: Context -> Expr -> Int -> IO Expr
bvBoolExtractBit _ _ _ = return $ Expr ()

-- | Extract a single bit from a bitvector and return it as a boolean (alias)
mkBVBoolExtract :: Context -> Int -> Expr -> IO Expr
mkBVBoolExtract ctx i e = bvBoolExtractBit ctx e i

-- | Delete an expression
deleteExpr :: Expr -> IO ()
deleteExpr _ = return ()

-- | Set a flag
setFlag :: Context -> Char -> IO ()
setFlag _ _ = return ()

-- | Check the version of STP
checkVersion :: IO String
checkVersion = return "STP stub version 1.0"
