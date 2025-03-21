module Main where

import Test.Tasty
import Test.Tasty.HUnit
import System.Directory
import System.Environment
import System.FilePath
import System.Process
import System.Exit
import Control.Monad

import DejaGNUDriver
import DejaGNUTest

main :: IO ()
main = do
  -- Set up the environment
  args <- getArgs
  let testDir = case args of
                  (dir:_) -> dir
                  [] -> "testsuite"
  
  -- Find the test directories
  testDirs <- findTestDirs testDir
  testCases <- concat <$> mapM createTestsForDir testDirs
  
  -- Run the tests
  defaultMain $ testGroup "BSC Dejagnu Tests" testCases

-- Find directories containing dejagnu test files
findTestDirs :: FilePath -> IO [FilePath]
findTestDirs baseDir = do
  exists <- doesDirectoryExist baseDir
  if not exists
    then return []
    else do
      contents <- listDirectory baseDir
      let fullPaths = map (baseDir </>) contents
      dirs <- filterM doesDirectoryExist fullPaths
      isTestDir <- mapM containsTestFiles dirs
      let testDirs = [dir | (dir, True) <- zip dirs isTestDir]
      subDirs <- concat <$> mapM findTestDirs dirs
      return (testDirs ++ subDirs)

-- Check if a directory contains .exp files (dejagnu test files)
containsTestFiles :: FilePath -> IO Bool
containsTestFiles dir = do
  contents <- listDirectory dir
  return $ any (isSuffixOf ".exp") contents

-- Create test cases for a directory
createTestsForDir :: FilePath -> IO [TestTree]
createTestsForDir dir = do
  files <- listDirectory dir
  let expFiles = filter (isSuffixOf ".exp") files
  return [testCase (takeBaseName expFile) $ runDejaGNUTest dir expFile | expFile <- expFiles]

-- Run a single dejagnu test
runDejaGNUTest :: FilePath -> FilePath -> Assertion
runDejaGNUTest dir expFile = do
  let testFile = dir </> expFile
  result <- runDejaGNUDriver testFile
  assertBool ("Test failed: " ++ testFile) result 