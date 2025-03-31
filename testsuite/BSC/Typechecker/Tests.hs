{-# LANGUAGE OverloadedStrings #-}
module BSC.Typechecker.Tests (tests) where

import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.Golden
import System.FilePath
import System.Directory
import Control.Monad
import Data.List (isSuffixOf)

tests :: IO TestTree
tests = do
  -- Get all BSV files in the typechecker test directory
  let typecheckerDir = "testsuite/bsc.typechecker"
  files <- listDirectory typecheckerDir
  let bsvFiles = filter (isSuffixOf ".bsv" .||. isSuffixOf ".bs") files
  
  -- Create test cases for each BSV file
  testCases <- forM bsvFiles $ \file -> do
    let baseName = takeBaseName file
        expectedFile = typecheckerDir </> baseName ++ ".out.expected"
        actualFile = typecheckerDir </> baseName ++ ".out"
    
    -- Check if we have an expected output file
    hasExpected <- doesFileExist expectedFile
    
    if hasExpected
      then return $ goldenVsFile
             ("Typecheck " ++ file)
             expectedFile
             actualFile
             (typecheckBSV (typecheckerDir </> file) >>= writeFile actualFile)
      else return $ testCase ("Typecheck " ++ file) $ do
        result <- typecheckBSV (typecheckerDir </> file)
        assertBool "Typechecking failed" (not $ null result)
  
  return $ testGroup "Typechecker Tests" testCases

-- Helper functions
(.||.) :: (a -> Bool) -> (a -> Bool) -> a -> Bool
(.||.) f g x = f x || g x

typecheckBSV :: FilePath -> IO String
typecheckBSV file = do
  -- TODO: Implement BSV typechecking
  return "Placeholder output" 