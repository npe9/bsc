import Distribution.Simple
import Distribution.PackageDescription
import Distribution.Text
import System.Process (readProcess)
import Data.Version (Version(..), makeVersion)

main = defaultMainWithHooks $ simpleUserHooks { readPackageDesc = readPackageDesc' }

readPackageDesc' :: IO (Maybe GenericPackageDescription)
readPackageDesc' = do
    mDesc <- readPackageDesc
    case mDesc of
        Nothing -> return Nothing
        Just desc -> do
            version <- getGitVersion
            return $ Just $ updateVersion version desc

getGitVersion :: IO String
getGitVersion = do
    version <- readProcess "git" ["describe", "--tags", "--dirty"] ""
    return $ filter (/= '\n') version

updateVersion :: String -> GenericPackageDescription -> GenericPackageDescription
updateVersion version desc = desc { packageDescription = (packageDescription desc) { pkgVersion = parseVersion version } }

parseVersion :: String -> Version
parseVersion str = makeVersion $ map read $ filter (/= "") $ split '-' str
    where split c = foldr f [[]]
            where f x acc | x == c = []:acc
                         | otherwise = (x:head acc):tail acc 