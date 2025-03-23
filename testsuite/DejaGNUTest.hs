module DejaGNUTest (
    TestExpectation(..)
  , parseExpFile
  , verifyExpectations
) where

import System.FilePath
import System.Directory
import System.Process
import System.Exit
import Data.List (isInfixOf)

-- Types for test expectations
data TestExpectation = 
    ExpectSuccess  -- Test should succeed
  | ExpectFailure  -- Test should fail
  | ExpectOutput String  -- Test should output specific text
  | ExpectNoOutput String  -- Test should not output specific text
  deriving (Show, Eq)

-- Parse a DejaGNU .exp file to extract test expectations
parseExpFile :: FilePath -> IO [TestExpectation]
parseExpFile expFile = do
  contents <- readFile expFile
  let lines' = lines contents
      expectations = map parseExpectation lines'
  return $ concat expectations

-- Parse a single line of an .exp file
parseExpectation :: String -> [TestExpectation]
parseExpectation line
  | "pass" `isInfixOf` line = [ExpectSuccess]
  | "fail" `isInfixOf` line = [ExpectFailure]
  | "expect" `isInfixOf` line = 
      let output = drop 1 $ dropWhile (/= '{') $ drop 6 line
       in [ExpectOutput output | not (null output)]
  | "xfail" `isInfixOf` line = [ExpectFailure]  -- Expected failure
  | otherwise = []

-- Verify test results against expectations
verifyExpectations :: [TestExpectation] -> ExitCode -> String -> String -> Bool
verifyExpectations expectations exitCode stdout stderr =
  all (\exp -> checkExpectation exp exitCode stdout stderr) expectations

-- Check if a single expectation was met
checkExpectation :: TestExpectation -> ExitCode -> String -> String -> Bool
checkExpectation ExpectSuccess exitCode _ _ = exitCode == ExitSuccess
checkExpectation ExpectFailure exitCode _ _ = 
  -- Only return True if this was an expected failure
  exitCode /= ExitSuccess
checkExpectation (ExpectOutput text) _ stdout stderr = 
  text `elem` lines stdout || text `elem` lines stderr
checkExpectation (ExpectNoOutput text) _ stdout stderr = 
  text `notElem` lines stdout && text `notElem` lines stderr 