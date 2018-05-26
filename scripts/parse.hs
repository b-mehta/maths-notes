import qualified Data.Text as T
import System.Environment
import Text.LaTeX.Base
import Text.LaTeX.Base.Parser
import Text.LaTeX.Base.Syntax

thm,thp,def :: [String]
thm = ["nthm","ncor","nlemma","nprop","thm","cor","lemma","prop"]
thp = "proof":thm
def = ["defi","ndef"]

modify :: [String] -> LaTeX -> LaTeX
modify envs = texmap test change
  where test (TeXRaw _) = True
        test (TeXComm _ _) = True
        test (TeXCommS _) = True
        test (TeXEnv _ _ _) = True
        test (TeXMath _ _) = True
        test _ = False

        change (TeXRaw _) = TeXRaw (T.pack "\n")
        change (TeXComm s as)
          | s `elem` ["section", "subsection","label"] = TeXComm s as
          | otherwise                          = TeXEmpty
        change (TeXCommS s)
          | s `elem` ["clearpage","leavevmode","maketitle"] = TeXCommS s
          | otherwise                           = TeXEmpty
        change (TeXEnv s as l)
          | s `elem` envs = TeXEnv s as (clearLinks l)
          | otherwise                                 = TeXEmpty
        change (TeXMath _ _) = TeXEmpty
        change _ = error "modify failed"

clearLinks :: LaTeX -> LaTeX
clearLinks = texmap test change
  where test (TeXComm "hyperlink" _) = True
        test _ = False
        change (TeXComm "hyperlink" [_,FixArg t]) = t
        change _ = error "clear links failed"

fix :: [String] -> LaTeX -> LaTeX
fix envs doc = getPreamble doc <> document (modify envs body)
  where Just body = getBody doc

main :: IO ()
main = do
  [loc] <- getArgs
  Right y <- parseLaTeXFile (loc ++ ".tex")
  renderFile (loc ++ "_thp.tex") (fix thp y)
  renderFile (loc ++ "_thm.tex") (fix thm y)
  renderFile (loc ++ "_def.tex") (fix def y)
