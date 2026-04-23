import Data.List
import Data.Ord

testData :: [String]
testData = ["939", "7,13,x,x,59,x,31,19"]

realData :: [String]
realData = ["1005595", "41,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,37,x,x,x,x,x,557,x,29,x,x,x,x,x,x,x,x,x,x,13,x,x,x,17,x,x,x,x,x,23,x,x,x,x,x,x,x,419,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,19"]

parse :: [String] -> (Int,[Int])
parse (now:idents:_) = (read now, parseIDs $ breakOff idents)
  where
    parseIDs (itm,[]) = [read itm] -- last value is not "x"
    parseIDs (itm,res) = if itm == "x"
      then parseIDs $ breakOff res
      else read itm : parseIDs (breakOff res)
    breakOff xs = let (itm,res) = break (==',') xs in (itm,drop 1 res)

parse _ = error "Minimum length must be 2"

nextIn :: Int -> Int -> Int
nextIn now freq = freq - (now `mod` freq)

pairProduct :: (Int,Int) -> Int
pairProduct (x,y) = x*y

solvePart1 :: Int -> [Int] -> Int
solvePart1 now idents = pairProduct . minimumBy (comparing snd) $ map (\ident -> (ident, nextIn now ident)) idents

main :: IO ()
main = do
  putStrLn "Part One (test = 295)"
  let (testNow,testIdents) = parse testData
  print $ solvePart1 testNow testIdents
  putStrLn "Answer:"
  let (realNow,realIdents) = parse realData
  print $ solvePart1 realNow realIdents

