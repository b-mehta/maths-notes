import Data.List
import System.Environment
import Control.Monad

go :: String -> [String]
go = tail . filter (isInfixOf "warning") . lines

run :: String -> IO ()
run log = case go log of
            [] -> putStrLn "No warnings!"
            x -> mapM_ putStrLn x

main :: IO ()
main = do
  (file:_) <- lines <$> readFile "state"
  log <- readFile (file ++ ".log")
  case log of
    [] -> putStrLn "compiling tex file..."
    _ -> run log
