{-# LANGUAGE TemplateHaskell #-}
module Version(bluespec, bscVersionStr, versionStr, versionname,
               copyright, buildnum, gitHash, gitBranch, gitDirty
              ) where

import Data.Maybe (fromMaybe)
import GitInfo
import Development.GitRev

{-# NOINLINE bluespec #-}
{-# NOINLINE versionname #-}
{-# NOINLINE copyright #-}

bluespec :: String
bluespec = "Bluespec"

-- Version information
versionname :: String
versionname = version

buildnum :: Integer
buildnum = read ("0x" ++ take 8 gitHash) :: Integer

-- Generate the version string (for a given tool)
versionStr :: Bool -> String -> String
versionStr showVersion toolname
  | not showVersion = toolname
  | otherwise =
    let emptyOr a b = if null a then a else b
        versionstr  = versionname `emptyOr` (", version " ++ versionname)
        buildInfo   = gitHash `emptyOr` (" (build " ++ gitHash ++ dirtyFlag ++ ")")
        dirtyFlag   = if gitDirty then "-dirty" else ""
    in  concat [toolname, versionstr, buildInfo]

-- The version string for BSC
bscVersionStr :: Bool -> String
bscVersionStr showVersion = versionStr showVersion (bluespec ++ " Compiler")

copyright :: String
copyright = unlines copyrights

copyrights :: [String]
copyrights = ["This is free software; for source code and copying conditions, see",
              "https://github.com/B-Lang-org/bsc"]

-- Get git hash
gitHash :: String
gitHash = $(gitHash)

-- Get git branch
gitBranch :: String
gitBranch = $(gitBranch)

-- Get whether working directory is dirty
gitDirty :: Bool
gitDirty = $(gitDirtyTracked)
