{-# LANGUAGE TemplateHaskell #-}
module Version
    ( bluespec
    , bscVersionStr
    , versionStr
    , versionname
    , copyright
    , buildnum
    , gitHash
    , gitBranch
    , gitDirty
    , gitDescribe
    ) where

import qualified GitInfo

{-# NOINLINE bluespec #-}
{-# NOINLINE versionname #-}
{-# NOINLINE copyright #-}

bluespec :: String
bluespec = "Bluespec"

-- Version information
versionname :: String
versionname = version

buildnum :: Integer
buildnum = read ("0x" ++ take 8 GitInfo.gitHash) :: Integer

-- Generate the version string (for a given tool)
versionStr :: Bool -> String -> String
versionStr showVersion toolname
  | not showVersion = toolname
  | otherwise =
    let emptyOr a b = if null a then a else b
        versionstr  = versionname `emptyOr` (", version " ++ versionname)
        buildInfo   = GitInfo.gitHash `emptyOr` (" (build " ++ GitInfo.gitHash ++ dirtyFlag ++ ")")
        dirtyFlag   = if GitInfo.gitDirty then "-dirty" else ""
    in  concat [toolname, versionstr, buildInfo]

-- The version string for BSC
bscVersionStr :: Bool -> String
bscVersionStr showVersion = versionStr showVersion (bluespec ++ " Compiler")

-- | Get the version string
version :: String
version = GitInfo.gitHash

-- | Get the git hash
gitHash :: String
gitHash = GitInfo.gitHash

-- | Get the current branch
gitBranch :: String
gitBranch = GitInfo.gitBranch

-- | Check if the working directory is dirty
gitDirty :: Bool
gitDirty = GitInfo.gitDirty

-- | Get a full git description including tags if available
gitDescribe :: String
gitDescribe = GitInfo.gitDescribe

-- | Copyright information
copyright :: String
copyright = "Copyright (c) 2025 Bluespec, Inc. All Rights Reserved."
