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

allJumps :: [a] -> [[a]]
allJumps = ([] :) . aux []
  where
    aux acc []     = acc
    aux acc (x:xs) = aux (acc ++ [[x]] ++ map (++ [x]) acc) xs

hasValidJumps :: Int -> Int -> [Int] -> Bool
hasValidJumps start end = aux start
  where
    aux lst []       = end - lst <= 3
    aux lst (x:xs)
      | x - lst <= 3 = aux x xs
      | otherwise     = False

countValidJumps :: Int -> Int -> [[Int]] -> Int
countValidJumps start end = sum . map (fromEnum . (hasValidJumps start end))

jumpsOf :: Int -> Int
jumpsOf n = countValidJumps 0 (n + 3) xs
  where xs = allJumps . scanl1 (+) . take n $ repeat (1 :: Int)

countJumpChoices :: [Int] -> Integer
countJumpChoices =
  product . map (toInteger . jumpsOf . length) . filter grpOnes . group . diff . withEnds
    where
      grpOnes []    = undefined
      grpOnes (x:_)
        | x == 1    = True
        | otherwise = False
      withEnds []   = undefined
      withEnds xs   = [0] ++ xs ++ [maximum xs + 3]

solvePartTwo :: [Int] -> Integer
solvePartTwo = countJumpChoices . sort

main :: IO ()
main = do
  datafile <- readFile "10.txt"
  let realData = read <$> lines datafile

  --putStrLn "Test Part One (should be 220)"
  --print $ solvePartOne testData
  --putStrLn "Answer:"
  --print $ solvePartOne realData

  putStrLn "Test Part Two (should be 19208)"
  print $ solvePartTwo testData
  putStrLn "Answer:"
  print $ solvePartTwo realData


