module CPackageTime(
    CPackage(..),
    TimeInfo,
    getNow
) where

import CSyntax(CPackage(..))

-- | Time information for parsing
type TimeInfo = Double

-- | Get current time
getNow :: IO TimeInfo
getNow = return 0.0 