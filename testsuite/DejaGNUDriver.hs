module DejaGNUDriver (runDejaGNUDriver) where

import System.Process
import System.Exit
import System.FilePath
import System.Directory

-- Run dejagnu test driver
runDejaGNUDriver :: FilePath -> IO Bool
runDejaGNUDriver testFile = do
  -- Get the test directory and file name
  let dir = takeDirectory testFile
      file = takeFileName testFile
      baseName = takeBaseName file
      testName = dir </> baseName
  
  -- Create temporary directory for test results
  tmpDir <- getTemporaryDirectory
  let resultDir = tmpDir </> "bsc-test-results"
  createDirectoryIfMissing True resultDir
  
  -- Find the actual test runner
  binDir <- getBinDir
  let bscPath = binDir </> "bsc"
  
  -- Run the test with dejagnu-like environment
  putStrLn $ "Running test: " ++ testName
  (exitCode, stdout, stderr) <- readProcessWithExitCode bscPath ["-p", testName] ""
  
  -- Process results
  case exitCode of
    ExitSuccess -> do
      putStrLn "Test passed."
      return True
    ExitFailure code -> do
      putStrLn $ "Test failed with exit code: " ++ show code
      putStrLn "Stdout:"
      putStrLn stdout
      putStrLn "Stderr:"
      putStrLn stderr
      return False

-- Get the bin directory where bsc is located
getBinDir :: IO FilePath
getBinDir = do
  -- We'll use the cabal dist-newstyle directory for the bin path
  pwd <- getCurrentDirectory
  return $ pwd </> "dist-newstyle" </> "build" </> "x86_64-osx" </> "ghc-8.8.4" </> 
           "bsc-0.1.0.0" </> "x" </> "bsc" </> "build" </> "bsc" 