import Data.List

testData :: [Int]
testData = [28, 33, 18, 42, 31, 14, 46, 20, 48, 47, 24, 23, 49, 45, 19, 38, 39,
            11, 1, 32, 25, 35, 8, 17, 7, 9, 4, 2, 34, 10, 3]

testData2 :: [Int]
testData2 = [16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4]

diff :: Num a => [a] -> [a]
diff xs = zipWith (-) (drop 1 xs) xs

countDiffs :: (Ord a, Num a) => [a] -> (Int, Int)
countDiffs xs = (countOf 1 diffxs, countOf 3 diffxs)
  where
    countOf n = length . filter (== n)
    diffxs = sort $ diff xs

addSourceAndSink :: [Int] -> [Int]
addSourceAndSink xs = sort $ [0, devRating] ++ xs
  where devRating = 3 + maximum xs

triples :: [a] -> [(a,a,a)]
triples xs = zip3 xs (drop 1 xs) (drop 2 xs)

triplesWith :: (a -> a -> a -> d) -> [a] -> [d]
triplesWith fn xs = zipWith3 fn xs (drop 1 xs) (drop 2 xs)

curry3 :: ((a,b,c) -> d) -> a -> b -> c -> d
curry3 fn x y z = fn (x,y,z)

solvePartOne :: [Int] -> Int
solvePartOne xs = ones * threes
  where
    diffxs = countDiffs $ addSourceAndSink xs
    ones = fst diffxs
    threes = snd diffxs

printPartTwoAttempt :: [Int] -> IO Int
printPartTwoAttempt xs = do
  let xs' = addSourceAndSink xs
  print xs'
  let xs''= triplesWith (\x y z -> (y-x,z-x)) xs'
  print xs''
  let xs''' = length $ filter (==(1,2)) xs''
  print xs'''
  return xs'''

main :: IO ()
main = do
  --datafile <- readFile "10.txt"
  --let realData = read <$> lines datafile

  --putStrLn "Test Part One (should be 220)"
  --print $ solvePartOne testData
  --putStrLn "Answer"
  --print $ solvePartOne realData

  putStrLn "Test Part Two (should be 19208)"
  _ <- printPartTwoAttempt testData2
  putStrLn ""
  answer <- printPartTwoAttempt testData

  print ((2 :: Integer) ^ answer)

  print $ addSourceAndSink testData

