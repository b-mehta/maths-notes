import Data.List
import System.Environment
import Control.Monad

go :: String -> [String]
go = tail . filter (isInfixOf "warning") . lines

main = do
  [file] <- getArgs
  log <- readFile (file ++ ".log")
  mapM_ putStrLn (go log)
