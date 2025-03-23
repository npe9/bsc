{-# LANGUAGE TemplateHaskell #-}
module GitInfo where

import Development.GitRev as GitRev

-- Git information from gitrev
gitHash :: String
gitHash = $(GitRev.gitHash)

gitBranch :: String
gitBranch = $(GitRev.gitBranch)

gitDirty :: Bool
gitDirty = $(GitRev.gitDirtyTracked)

gitDescribe :: String
gitDescribe = $(GitRev.gitDescribe) 