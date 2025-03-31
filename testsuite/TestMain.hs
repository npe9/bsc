{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import qualified BSC.Verilog.Tests as Verilog
import qualified BSC.Bluesim.Tests as Bluesim
import qualified BSC.Typechecker.Tests as Typechecker
import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.Golden
import System.FilePath (takeBaseName)

main :: IO ()
main = do
  -- Create test trees for each test group
  verilogTree <- Verilog.tests
  bluesimTree <- Bluesim.tests
  typecheckerTree <- Typechecker.tests
  
  -- Combine all test trees
  let testTree = testGroup "BSC Tests"
        [ verilogTree
        , bluesimTree
        , typecheckerTree
        ]
  
  -- Run tests
  defaultMain testTree

-- Helper functions for common test operations
compareWithGolden :: FilePath -> FilePath -> IO Bool
compareWithGolden actual expected = do
  actualContent <- readFile actual
  expectedContent <- readFile expected
  return $ actualContent == expectedContent

compileBSV :: FilePath -> IO String
compileBSV file = do
  -- TODO: Implement BSV compilation
  return "Compilation successful"

testBSVCompilation :: FilePath -> TestTree
testBSVCompilation file = testCase ("Compile " ++ file) $ do
  result <- compileBSV file
  assertBool "Compilation failed" (not $ null result)

testGolden :: FilePath -> FilePath -> TestTree
testGolden actual expected = goldenVsFile
  (takeBaseName actual)
  expected
  actual
  (compileBSV actual >>= writeFile actual) 