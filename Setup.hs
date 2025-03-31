{-# LANGUAGE CPP #-}
module Main (main) where

import Distribution.Simple
import Distribution.Simple.Setup
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Program
import Distribution.Simple.Utils
import Distribution.PackageDescription
import Distribution.Verbosity
import Distribution.System
import System.Directory
import System.FilePath
import Control.Monad
import Data.List (isSuffixOf)

setupPrograms :: Verbosity -> ProgramDb -> IO (ConfiguredProgram, ConfiguredProgram)
setupPrograms verbosity progdb = do
  let bscProgram = simpleProgram "bsc"
      cabalProgram = simpleProgram "cabal"
  (bscConf, _) <- requireProgram verbosity bscProgram progdb
  (cabalConf, _) <- requireProgram verbosity cabalProgram progdb
  return (bscConf, cabalConf)

generateCoverageReports :: Verbosity -> ConfiguredProgram -> IO ()
generateCoverageReports verbosity cabalConf = do
  runProgram verbosity cabalConf ["hpc", "report", "--all"]
  runProgram verbosity cabalConf ["hpc", "markup", "--all"]

buildPrelude :: Verbosity -> ProgramDb -> FilePath -> IO ()
buildPrelude verbosity progdb buildDir = do
  createDirectoryIfMissing True buildDir
  let bsc = simpleProgram "bsc"
  (bscProg, _) <- requireProgram verbosity bsc progdb
  
  -- Save existing Prelude.bo if it exists
  let preludeBo = buildDir </> "Prelude.bo"
  preludeExists <- doesFileExist preludeBo
  when preludeExists $ do
    copyFile preludeBo (buildDir </> "Prelude.bo.bak")
  
  -- Build MinimalPrelude first
  runProgram verbosity bscProg
    [ "-p", "."
    , "-bdir", buildDir
    , "-v"
    , "src/Libraries/Base1/MinimalPrelude.bs"
    ]
  
  -- Build base libraries in order
  let baseLibs = 
        [ "src/Libraries/Base1/Prelude.bs"
        , "src/Libraries/Base1/PreludeBSV.bsv"
        , "src/Libraries/Base1/Vector.bs"
        , "src/Libraries/Base1/List.bs"
        , "src/Libraries/Base1/FIFO.bs"
        , "src/Libraries/Base1/FIFOF.bs"
        , "src/Libraries/Base1/GetPut.bs"
        ]
  
  forM_ baseLibs $ \lib -> do
    runProgram verbosity bscProg
      [ "-p", "."
      , "-bdir", buildDir
      , "-v"
      , lib
      ]

buildTestLibraries :: Verbosity -> ConfiguredProgram -> IO ()
buildTestLibraries verbosity bscConf = do
  let buildDir = "build/bsvlib"
  
  -- Create build directory
  createDirectoryIfMissing True buildDir
  
  -- Build test libraries
  runProgram verbosity bscConf $ concat
    [ ["-p", "."]
    , ["-bdir", buildDir]
    , ["testsuite/bsc.verilog/**/*.bsv"]
    , ["testsuite/bsc.bluesim/**/*.bsv"]
    , ["testsuite/bsc.typechecker/**/*.bsv"]
    ]

preBuildHook :: Args -> BuildFlags -> IO HookedBuildInfo
preBuildHook _ flags = do
  let verbosity = fromFlag $ buildVerbosity flags
      progdb = defaultProgramDb
  (bscConf, cabalConf) <- setupPrograms verbosity progdb
  buildPrelude verbosity progdb "build/bsvlib"
  generateCoverageReports verbosity cabalConf
  return emptyHookedBuildInfo

preTestHook :: Args -> TestFlags -> IO HookedBuildInfo
preTestHook _ flags = do
  let verbosity = fromFlag $ testVerbosity flags
      progdb = defaultProgramDb
  (bscConf, cabalConf) <- setupPrograms verbosity progdb
  buildTestLibraries verbosity bscConf
  generateCoverageReports verbosity cabalConf
  return emptyHookedBuildInfo

main :: IO ()
main = defaultMainWithHooks simpleUserHooks
  { preBuild = preBuildHook
  , preTest = preTestHook
  } 