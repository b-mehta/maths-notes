import qualified Data.Text as T
import System.Environment
import Text.LaTeX.Base
import Text.LaTeX.Base.Parser
import Text.LaTeX.Base.Syntax
import Control.Monad
import Data.List

thm,thp,def :: [String]
thm = ["nthm","ncor","nlemma","nprop","thm","cor","lemma","prop"]
thp = "proof":thm
def = ["defi","ndef","notation"]

modify :: [String] -> LaTeX -> LaTeX
modify envs = texmap test change
  where test (TeXRaw _)     = True
        test (TeXComm _ _)  = True
        test (TeXCommS _)   = True
        test (TeXEnv _ _ _) = True
        test (TeXMath _ _)  = True
        test _              = False

        change (TeXRaw _) = TeXRaw (T.pack "\n")
        change (TeXComm s as)
          | s `elem` ["section","subsection","subsubsection","label"] = TeXComm s as
        change (TeXCommS s)
          | s `elem` ["clearpage","leavevmode","maketitle"] = TeXCommS s
        change (TeXEnv s as l)
          | s `elem` envs = TeXEnv s as (clearLinks l)
        change _ = TeXEmpty

clearLinks :: LaTeX -> LaTeX
clearLinks = texmap test change
  where test (TeXComm "hyperlink" _) = True
        test (TeXCommS "newlec") = True
        test _ = False
        change (TeXComm "hyperlink" [_,FixArg t]) = t
        change (TeXCommS "newlec") = TeXEmpty
        change _ = error "clear links failed"

fix :: [String] -> LaTeX -> LaTeX
fix envs doc = getPreamble doc <> document (modify envs body)
  where Just body = getBody doc

dropR :: Int -> [a] -> [a]
dropR n l = go (drop n l) l
  where
    go [] _ = []
    go (_:xs) (y:ys) = y:go xs ys

takeR :: Int -> [a] -> [a]
takeR n l = go (drop n l) l
  where
    go [] r = r
    go (_:xs) (_:ys) = go xs ys

runFile :: String -> IO ()
runFile loc =
  if ".tex" `isSuffixOf` loc
     then do
            when (take 3 (takeR 7 loc) `notElem` ["thm", "thp", "def"]) $ do
            when (takeR 10 loc /= "header.tex") $ do
            parsed <- parseLaTeXFile loc
            case parsed of
              Left _ -> putStrLn ("Failed to parse " ++ loc ++ ", skipping.")
              Right y -> zipWithM_ func ["thm", "thp", "def"] [thm, thp, def]
                where loc' = dropR 4 loc
                      func a b = renderFile (loc' ++ "_" ++ a ++ ".tex") (fix b y)
     else putStrLn (loc ++ " is an invalid filename.")

main :: IO ()
main = do
  files <- getArgs
  if null files
     then putStrLn "No files given."
     else forM_ files runFile
