{-# LANGUAGE OverloadedStrings #-}
module BSC.Bluesim.Tests (tests) where

import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.Golden
import System.FilePath
import System.Directory
import Control.Monad
import Data.List (isSuffixOf)

tests :: IO TestTree
tests = do
  -- Get all BSV files in the bluesim test directory
  let bluesimDir = "testsuite/bsc.bluesim"
  files <- listDirectory bluesimDir
  let bsvFiles = filter (isSuffixOf ".bsv" .||. isSuffixOf ".bs") files
  
  -- Create test cases for each BSV file
  testCases <- forM bsvFiles $ \file -> do
    let baseName = takeBaseName file
        expectedFile = bluesimDir </> "sys" ++ baseName ++ ".out.expected"
        actualFile = bluesimDir </> "sys" ++ baseName ++ ".out"
    
    -- Check if we have an expected output file
    hasExpected <- doesFileExist expectedFile
    
    if hasExpected
      then return $ goldenVsFile
             ("Bluesim " ++ file)
             expectedFile
             actualFile
             (compileBSV (bluesimDir </> file) >>= writeFile actualFile)
      else return $ testCase ("Compile " ++ file) $ do
        result <- compileBSV (bluesimDir </> file)
        assertBool "Compilation failed" (not $ null result)
  
  return $ testGroup "Bluesim Tests" testCases

-- Helper functions
(.||.) :: (a -> Bool) -> (a -> Bool) -> a -> Bool
(.||.) f g x = f x || g x

compileBSV :: FilePath -> IO String
compileBSV file = do
  -- TODO: Implement BSV compilation
  return "Placeholder output" 