-- Re-export Parse module from Libs
module Parse (module Libs.Parse) where

import Libs.Parse

-- This is a minimal implementation to allow compilation
-- It should re-export necessary parsing utilities

import qualified Text.Parsec as P 