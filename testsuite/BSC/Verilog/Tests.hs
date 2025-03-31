{-# LANGUAGE OverloadedStrings #-}
module BSC.Verilog.Tests (tests) where

import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.Golden
import System.FilePath
import System.Directory
import Control.Monad
import Data.List (isSuffixOf)
import System.Process

tests :: IO TestTree
tests = do
  -- Get all BSV files in the verilog test directory
  let verilogDir = "testsuite/bsc.verilog"
  files <- listDirectory verilogDir
  let bsvFiles = filter (isSuffixOf ".bsv" .||. isSuffixOf ".bs") files
  
  -- Create test cases for each BSV file
  testCases <- forM bsvFiles $ \file -> do
    let baseName = takeBaseName file
        expectedFile = verilogDir </> "sys" ++ baseName ++ ".out.expected"
        actualFile = verilogDir </> "sys" ++ baseName ++ ".out"
    
    -- Check if we have an expected output file
    hasExpected <- doesFileExist expectedFile
    
    if hasExpected
      then return $ goldenVsFile
             ("Verilog " ++ file)
             expectedFile
             actualFile
             (compileBSV (verilogDir </> file) >>= writeFile actualFile)
      else return $ testCase ("Compile " ++ file) $ do
        result <- compileBSV (verilogDir </> file)
        assertBool "Compilation failed" (not $ null result)
  
  return $ testGroup "Verilog Tests" testCases

-- Helper functions
(.||.) :: (a -> Bool) -> (a -> Bool) -> a -> Bool
(.||.) f g x = f x || g x

compileBSV :: FilePath -> IO String
compileBSV file = do
  let baseName = takeBaseName file
      dir = takeDirectory file
      verilogFile = dir </> baseName ++ ".v"
      simFile = dir </> baseName ++ ".sim"
      outFile = dir </> "sys" ++ baseName ++ ".out"
  
  -- Compile to Verilog
  system $ "bsc -verilog -g " ++ baseName ++ " " ++ file
  -- Compile to simulation
  system $ "bsc -sim -g " ++ baseName ++ " " ++ file
  -- Link simulation
  system $ "bsc -sim -e " ++ baseName ++ " -o " ++ simFile
  -- Run simulation and capture output
  (_, stdout, _) <- readProcessWithExitCode simFile [] ""
  return stdout 