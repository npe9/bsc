import Distribution.Simple
import Distribution.Simple.Setup
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Program as Program
import Distribution.PackageDescription
import Distribution.Simple.Utils as Utils
import Distribution.Verbosity
import Distribution.Text
import Distribution.System
import Distribution.Simple.PackageIndex
import Distribution.Simple.InstallDirs
import Distribution.Simple.BuildPaths
import Distribution.Simple.Program.Types

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
import Data.List (isSuffixOf)

-- Helper function to run BSC with proper path handling
runBSC :: String -> FilePath -> String -> String -> IO ()
runBSC bscPath buildDir flags file = do
  let args = ["-bdir", buildDir </> "bsvlib", flags, file]
  (_, _, _, ph) <- createProcess (proc bscPath args)
    { std_out = Inherit
    , std_err = Inherit
    }
  _ <- waitForProcess ph
  return ()

main :: IO ()
main = defaultMainWithHooks simpleUserHooks
    { preConf = \args flags -> do
        -- Create build directories using proper path handling
        createDirectoryIfMissing True $ "build" </> "bsvlib"
        createDirectoryIfMissing True $ "build" </> "tcllib" </> "bluespec"
        preConf simpleUserHooks args flags
    , buildHook = \pkg lbi hooks flags -> do
        -- First create build directories
        createDirectoryIfMissing True $ buildDir lbi </> "bsvlib"
        
        -- Get the system bsc command
        bscPath <- fromMaybe "bsc" <$> lookupEnv "BSC"
        
        -- Build libraries in dependency order using proper path handling
        let base1Dir = "src" </> "Libraries" </> "Base1"
        runBSC bscPath (buildDir lbi) "-no-use-prelude" $ base1Dir </> "Prelude.bs"
        runBSC bscPath (buildDir lbi) "-no-use-prelude" $ base1Dir </> "PreludeBSV.bsv"
        runBSC bscPath (buildDir lbi) ("-p " ++ base1Dir) $ base1Dir </> "FIFOF_.bsv"
        runBSC bscPath (buildDir lbi) ("-p " ++ base1Dir) $ base1Dir </> "FIFOF.bs"
        runBSC bscPath (buildDir lbi) ("-p " ++ base1Dir) $ base1Dir </> "FIFO.bs"
        runBSC bscPath (buildDir lbi) ("-p " ++ base1Dir) $ base1Dir </> "GetPut.bs"
        
        -- Continue with normal build
        buildHook simpleUserHooks pkg lbi hooks flags
        
    , copyHook = \pkg lbi hooks flags -> do
        -- First do the normal copy
        copyHook simpleUserHooks pkg lbi hooks flags
        
        -- Then copy our build products to the installation directory
        let verbosity = fromFlag (copyVerbosity flags)
            buildDir' = buildDir lbi
            installDir = datadir (localInstallDir lbi)
            bsvLibDir = buildDir' </> "bsvlib"
            tclLibDir = buildDir' </> "tcllib"
            installBsvLibDir = installDir </> "lib" </> "bsvlib"
            installTclLibDir = installDir </> "lib" </> "tcllib"
        
        -- Create installation directories
        createDirectoryIfMissing True installBsvLibDir
        createDirectoryIfMissing True installTclLibDir
        
        -- Copy build products
        copyDirectoryRecursive verbosity bsvLibDir installBsvLibDir
        copyDirectoryRecursive verbosity tclLibDir installTclLibDir
        
        -- Create symbolic links for library files
        let base1Dir = "src" </> "Libraries" </> "Base1"
            base2Dir = "src" </> "Libraries" </> "Base2"
            base3ContextsDir = "src" </> "Libraries" </> "Base3-Contexts"
            base3MathDir = "src" </> "Libraries" </> "Base3-Math"
            base3MiscDir = "src" </> "Libraries" </> "Base3-Misc"
        
        -- Create symbolic links for each library file
        forM_ [base1Dir, base2Dir, base3ContextsDir, base3MathDir, base3MiscDir] $ \dir -> do
          files <- listDirectory dir
          forM_ files $ \file -> do
            when (".bs" `isSuffixOf` file || ".bsv" `isSuffixOf` file) $ do
              let srcPath = dir </> file
              let dstPath = installBsvLibDir </> file
              createSymbolicLink srcPath dstPath
    }

-- Helper function for whenM
whenM :: Monad m => m Bool -> m () -> m ()
whenM p m = p >>= flip when m

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