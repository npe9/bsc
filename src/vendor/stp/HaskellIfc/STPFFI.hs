{-# LANGUAGE ForeignFunctionInterface   #-}
{-# LANGUAGE EmptyDataDecls             #-}
-- LANGUAGE GeneralizedNewtypeDeriving

module STPFFI where

-- Minimal stub implementation for STPFFI
-- This would need to be properly filled with actual FFI declarations
-- for full functionality

-- Empty data declarations for STP types
data SContext
data SType
data SExpr

foreign import ccall unsafe "stpvc.h vc_createValidityChecker"
  c_vc_createValidityChecker :: IO ()

foreign import ccall unsafe "stpvc.h vc_query"
  c_vc_query :: IO Bool

-- Additional FFI functions would be declared here
