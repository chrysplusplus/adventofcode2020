--import Data.Foldable (foldlM)
import Control.Arrow
import qualified Data.Maybe
import qualified Text.Read hiding (step)

testData :: [Int]
testData = [5, 35, 20, 15, 25, 47, 40, 62, 55, 65, 95, 102, 117, 150, 182, 127,
            219, 299, 277, 309, 576]

-- iteratee-like pattern to search for an input in a stream that breaks the rule
data BreakSearcher = BreakFound Int Int | BreakFinding (Int -> BreakSearcher)

messageFrom :: [a] -> (a,[a])
messageFrom = arr head &&& arr (drop 1)

uniquePairsOf :: [a] -> [(a,a)]
uniquePairsOf []     = []
uniquePairsOf (x:xs) = [(x,x') | x' <- xs] ++ uniquePairsOf xs

hasSumPairTo :: Int -> [Int] -> Bool
hasSumPairTo n xs = any ((==n) . uncurry (+)) $ uniquePairsOf xs

shift :: [a] -> a -> [a]
shift [] _  = []
shift xs x' = drop 1 xs ++ [x']

breakSearcher :: Int -> BreakSearcher
breakSearcher npreamble = BreakFinding (step (-1) []) where
  step idx acc x
    | length acc < npreamble = BreakFinding (step (succ idx) (acc ++ [x]))
    | hasSumPairTo x acc     = BreakFinding (step (succ idx) (shift acc x))
    | otherwise              = BreakFound (succ idx) x

printStepBreakSearcher :: BreakSearcher -> Int -> IO BreakSearcher
printStepBreakSearcher s@(BreakFound _ x) x' = do
  putStrLn (show x' ++ " -> break already found: " ++ show x)
  return s

printStepBreakSearcher (BreakFinding step) x = do
  let stepped = step x
  case stepped of
    BreakFound idx x' -> putStrLn (show x ++ " -> break found at " ++ show idx ++ " : " ++ show x')
    _                 -> putStrLn (show x ++ " -> still looking...")
  return stepped

findBreak :: Int -> [Int] -> Int
findBreak npreamble = aux (breakSearcher npreamble) where
  aux _ []                        = -1
  aux (BreakFound _ x') _         = x'
  aux (BreakFinding step) (x:xs') = aux (step x) xs'

findBreak2 :: Int -> [Int] -> Maybe BreakSearcher
findBreak2 npreamble = aux (breakSearcher npreamble) where
  aux _ []                       = Nothing
  aux (BreakFinding step) (x:xs) = aux (step x) xs
  aux searcher _                 = Just searcher

fromMaybeBreakSearcher :: Maybe BreakSearcher -> (Int,Int)
fromMaybeBreakSearcher (Just (BreakFound idx result)) = (idx,result)
fromMaybeBreakSearcher _                              = (-1,-1)

solvePart1 :: [Int] -> Int
solvePart1 = uncurry findBreak . messageFrom

main :: IO ()
main = do
  dataFile <- readFile "09.txt"
  let realData = map (Data.Maybe.fromJust . Text.Read.readMaybe) $ lines dataFile

  putStrLn "Test Part One (should be 127)"
  let (testNPreamble,testMsg) = messageFrom testData
  let (testIdx,testInvalidN) = fromMaybeBreakSearcher $ findBreak2 testNPreamble testMsg
  print testInvalidN

  putStrLn "Answer:"
  let (realNPreamble,realMsg) = messageFrom realData
  let (realIdx,realInvalidN) = fromMaybeBreakSearcher $ findBreak2 realNPreamble realMsg
  print realInvalidN -- 248131121

  putStrLn "Test Part Two (should be 62)"

  mapM_ print . concat
        . map (scanr (:) [])
        . scanr (:) [] $ take testIdx testMsg

