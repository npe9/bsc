module DejaGNUTest where

import System.FilePath
import System.Directory
import System.Process
import System.Exit
import qualified Data.Text as T
import qualified Data.Text.IO as TIO

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
  contents <- TIO.readFile expFile
  let lines = T.lines contents
      expectations = map parseExpectation lines
  return $ concat expectations

-- Parse a single line of an .exp file
parseExpectation :: T.Text -> [TestExpectation]
parseExpectation line
  | "pass" `T.isInfixOf` line = [ExpectSuccess]
  | "fail" `T.isInfixOf` line = [ExpectFailure]
  | "expect" `T.isInfixOf` line = 
      let output = T.unpack $ T.strip $ T.dropWhile (/= '{') $ T.drop 6 line
       in if not (null output) then [ExpectOutput output] else []
  | "xfail" `T.isInfixOf` line = [ExpectFailure]  -- Expected failure
  | otherwise = []

-- Verify test results against expectations
verifyExpectations :: [TestExpectation] -> ExitCode -> String -> String -> Bool
verifyExpectations expectations exitCode stdout stderr =
  all (\exp -> checkExpectation exp exitCode stdout stderr) expectations

-- Check if a single expectation was met
checkExpectation :: TestExpectation -> ExitCode -> String -> String -> Bool
checkExpectation ExpectSuccess exitCode _ _ = exitCode == ExitSuccess
checkExpectation ExpectFailure exitCode _ _ = exitCode /= ExitSuccess
checkExpectation (ExpectOutput text) _ stdout stderr = 
  text `elem` lines stdout || text `elem` lines stderr
checkExpectation (ExpectNoOutput text) _ stdout stderr = 
  text `notElem` lines stdout && text `notElem` lines stderr 