import Distribution.Simple
import Distribution.Simple.Setup
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Program as Program
import Distribution.PackageDescription
import Distribution.Simple.Utils as Utils
import Distribution.Verbosity
import Distribution.Text

import System.Directory
import System.FilePath
import System.Process
import System.Exit (ExitCode(..))
import Control.Monad
import Data.Version (Version(..), makeVersion)
import qualified System.Process as Process
import System.Environment
import Data.Maybe (fromMaybe)
import System.Posix.Files (createSymbolicLink)

main :: IO ()
main = defaultMainWithHooks simpleUserHooks
    { preConf = \args flags -> do
        -- Create build directories
        createDirectoryIfMissing True "build/bsvlib"
        createDirectoryIfMissing True "build/tcllib/bluespec"
        preConf simpleUserHooks args flags
    , buildHook = \pkg lbi hooks flags -> do
        -- First create build directories
        createDirectoryIfMissing True (buildDir lbi </> "bsvlib")
        
        -- Get the system bsc command
        bscPath <- fromMaybe "bsc" <$> lookupEnv "BSC"
        
        -- Build libraries in dependency order
        runBSC bscPath (buildDir lbi) "-no-use-prelude" "src/Libraries/Base1/Prelude.bs"
        runBSC bscPath (buildDir lbi) "-no-use-prelude" "src/Libraries/Base1/PreludeBSV.bsv"
        runBSC bscPath (buildDir lbi) "-p src/Libraries/Base1" "src/Libraries/Base1/FIFOF_.bsv"
        runBSC bscPath (buildDir lbi) "-p src/Libraries/Base1" "src/Libraries/Base1/FIFOF.bs"
        runBSC bscPath (buildDir lbi) "-p src/Libraries/Base1" "src/Libraries/Base1/FIFO.bs"
        runBSC bscPath (buildDir lbi) "-p src/Libraries/Base1" "src/Libraries/Base1/GetPut.bs"
        
        -- Continue with normal build
        buildHook simpleUserHooks pkg lbi hooks flags
        
    , copyHook = \pkg lbi hooks flags -> do
        -- First do the normal copy
        copyHook simpleUserHooks pkg lbi hooks flags
        
        -- Then copy our build products to the installation directory
        let verbosity = fromFlag (copyVerbosity flags)
            installLibDir = libdir $ absoluteInstallDirs pkg lbi NoCopyDest
            installBinDir = bindir $ absoluteInstallDirs pkg lbi NoCopyDest
            installExecDir = installLibDir </> "exec"
            
        -- Copy Bluespec libraries
        createDirectoryIfMissing True (installLibDir </> "Libraries")
        Utils.copyDirectoryRecursive verbosity "build/bsvlib" (installLibDir </> "Libraries")
        
        -- Copy Tcl files
        createDirectoryIfMissing True (installLibDir </> "tcllib/bluespec")
        Utils.copyDirectoryRecursive verbosity "build/tcllib/bluespec" (installLibDir </> "tcllib/bluespec")

        -- Copy simulation scripts
        createDirectoryIfMissing True installExecDir
        Utils.copyDirectoryRecursive verbosity "src/exec" installExecDir

        -- Create symlinks for simulation scripts
        let simScripts = [ "bsc_build_vsim_vcs"
                        , "bsc_build_vsim_vcsi"
                        , "bsc_build_vsim_ncverilog"
                        , "bsc_build_vsim_modelsim"
                        , "bsc_build_vsim_iverilog"
                        , "bsc_build_vsim_veriwell"
                        , "bsc_build_vsim_cver"
                        , "bsc_build_vsim_cvc"
                        , "bsc_build_vsim_isim"
                        , "bsc_build_vsim_xsim"
                        , "bsc_build_vsim_verilator"
                        ]
        forM_ simScripts $ \script -> do
            let src = installExecDir </> script
            let dst = installBinDir </> script
            whenM (doesFileExist src) $ do
                createSymbolicLink src dst
    }

-- Helper function to run a program with arguments
runBuildCommand :: Verbosity -> FilePath -> [String] -> IO ()
runBuildCommand verbosity prog args = do
    notice verbosity $ "Running: " ++ prog ++ " " ++ unwords args
    exitCode <- Process.rawSystem prog args
    when (exitCode /= ExitSuccess) $
        die' verbosity $ "Failed to run " ++ prog

-- Helper function to recursively copy a directory
copyDirectoryRecursive' :: Verbosity -> FilePath -> FilePath -> IO ()
copyDirectoryRecursive' verbosity src dst = do
    createDirectoryIfMissing True dst
    content <- getDirectoryContents src
    let files = filter (`notElem` [".", ".."]) content
    forM_ files $ \name -> do
        let srcPath = src </> name
        let dstPath = dst </> name
        isDirectory <- doesDirectoryExist srcPath
        if isDirectory
            then copyDirectoryRecursive' verbosity srcPath dstPath
            else copyFile srcPath dstPath

readPackageDesc' :: IO (Maybe GenericPackageDescription)
readPackageDesc' = undefined  -- TODO: Implement this if needed 

runBSC :: String -> FilePath -> String -> String -> IO ()
runBSC bscPath buildDir flags file = do
  let args = ["-bdir", buildDir </> "bsvlib", flags, file]
  (_, _, _, ph) <- createProcess (proc bscPath args)
    { std_out = Inherit
    , std_err = Inherit
    }
  _ <- waitForProcess ph
  return () 

-- Helper function for whenM
whenM :: Monad m => m Bool -> m () -> m ()
whenM cond action = do
    result <- cond
    when result action 