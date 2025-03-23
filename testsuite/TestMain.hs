module Main where

import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.Options
import System.Directory
import System.Environment
import System.FilePath
import System.Process
import System.Exit
import Control.Monad
import Data.List (isSuffixOf)
import Data.Proxy
import Data.Typeable
import Data.Char (toLower)
import Options.Applicative
import Test.Tasty.Runners (consoleTestReporter)

import DejaGNUDriver
import DejaGNUTest

-- Command line options
data TestOptions = TestOptions
  { testDir :: FilePath
  , stopOnFailure :: Bool
  }

-- Custom option type for stop-on-failure
newtype StopOnFailure = StopOnFailure Bool
  deriving (Eq, Ord, Typeable)

instance IsOption StopOnFailure where
  defaultValue = StopOnFailure False
  parseValue str = Just $ StopOnFailure $ case str of
    "" -> True  -- Handle the switch case (no value)
    s  -> case map toLower s of  -- Handle the value case
      "true"  -> True
      "false" -> False
      _       -> True  -- Default to True for any other value
  optionName = return "stop-on-failure"
  optionHelp = return "Stop after first test failure"
  optionCLParser = flag' (StopOnFailure True)
    ( long "stop-on-failure"
    <> short 'f'
    <> help "Stop after first test failure"
    )

-- Custom option type for test directory
newtype TestDirectory = TestDirectory FilePath
  deriving (Eq, Ord, Typeable)

instance IsOption TestDirectory where
  defaultValue = TestDirectory "testsuite"
  parseValue = Just . TestDirectory
  optionName = return "test-dir"
  optionHelp = return "Directory containing tests"

testOptions :: Parser TestOptions
testOptions = TestOptions
  <$> strOption
      ( long "test-dir"
      <> short 'd'
      <> metavar "DIR"
      <> help "Directory containing tests"
      <> value "testsuite"
      )
  <*> flag False True
      ( long "stop-on-failure"
      <> short 'f'
      <> help "Stop after first test failure"
      )

main :: IO ()
main = do
  -- Find the test directories
  testDirs <- findTestDirs "testsuite"
  testCases <- concat <$> mapM createTestsForDir testDirs
  
  -- Run the tests with custom options
  let testConfig = testGroup "BSC Dejagnu Tests" testCases
  defaultMainWithIngredients
    [ consoleTestReporter
    , includingOptions [Option (Proxy :: Proxy StopOnFailure)]
    , includingOptions [Option (Proxy :: Proxy TestDirectory)]
    ] testConfig

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
  -- If the test fails, provide more detailed error information
  unless result $ do
    putStrLn $ "\nTest failed: " ++ testFile
    putStrLn "Please check the test output for more details."
  assertBool ("Test failed: " ++ testFile) result 