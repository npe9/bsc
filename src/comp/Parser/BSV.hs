module Parser.BSV( bsvParseString
                 , pStringWrapper
                 , pTypeExpr
                 , pQualConstructor
                 ) where

import Error(internalError)
import CSyntax
import Position
import Id

-- Stub implementations since Parser.BSV.CVParser is not available
bsvParseString :: String -> String -> String -> Either String CPackage
bsvParseString _ _ _ = Left "Parser.BSV.CVParser has been removed"

pStringWrapper :: String -> String -> Either String CExpr
pStringWrapper _ _ = Left "Parser.BSV.CVParser has been removed"

pTypeExpr :: String -> Either String CType
pTypeExpr _ = Left "Parser.BSV.CVParser has been removed"

pQualConstructor :: String -> Either String (String, Id)
pQualConstructor _ = Left "Parser.BSV.CVParser has been removed"
