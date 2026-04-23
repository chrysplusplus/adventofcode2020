import Data.List
import Data.Ord

testData :: [String]
testData = ["939", "7,13,x,x,59,x,31,19"]

realData :: [String]
realData = ["1005595", "41,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,37,x,x,x,x,x,557,x,29,x,x,x,x,x,x,x,x,x,x,13,x,x,x,17,x,x,x,x,x,23,x,x,x,x,x,x,x,419,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,19"]

type IndexedInt = (Int,Int)

parse :: [String] -> (Int,[IndexedInt])
parse (now:idents:_) = (read now, parseIDs 0 $ breakOff idents)
  where
    parseIDs idx (itm,[]) = [(idx, read itm)] -- last value is not "x"
    parseIDs idx (itm,res) = if itm == "x"
      then parseIDs (succ idx) $ breakOff res
      else (idx, read itm) : parseIDs (succ idx) (breakOff res)
    breakOff xs = let (itm,res) = break (==',') xs in (itm,drop 1 res)

parse _ = error "Minimum length must be 2"

nextIn :: Int -> Int -> Int
nextIn now freq = freq - (now `mod` freq)

tplProduct :: (Int,Int) -> Int
tplProduct (x,y) = x*y

solvePart1 :: Int -> [IndexedInt] -> Int
solvePart1 now idents = tplProduct . minimumBy (comparing snd) $ map busNextInT idents
  where
    busNextInT (_,ident) = (ident, nextIn now ident)

testPoints :: Int -> Int -> [Integer]
testPoints idx ident = map (\x -> ident' * x - idx') [1..]
  where
    idx' = toInteger idx
    ident' = toInteger ident

solvePart2 :: Int -> [IndexedInt] -> Integer
solvePart2 skip xs = head . dropWhile testFail . drop skip . uncurry testPoints $ maximumBy (comparing snd) xs
  where testFail p = any (\(idx,x) -> (p + toInteger idx) `mod` toInteger x /= 0) xs

main :: IO ()
main = do
  putStrLn "Part One (test = 295)"
  let (testNow,testIdents) = parse testData
  print $ solvePart1 testNow testIdents
  putStrLn "Answer:"
  let (realNow,realIdents) = parse realData
  print $ solvePart1 realNow realIdents

  putStrLn "Part Two (test = 1068781)"
  print $ solvePart2 0 testIdents
  putStrLn "Answer:"
  print $ solvePart2 179533213600 realIdents -- roughly 100000000000000 `div` 557

