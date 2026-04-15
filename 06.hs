import Data.List

testData :: [String]
testData = ["abc", "", "a", "b", "c", "", "ab", "ac", "", "a", "a", "a", "a", "", "b", ""]

nextGroup :: [String] -> ([String],[String])
nextGroup = aux . break null where
  aux (grp, xs) = (grp, drop 1 xs)

splitIntoGroups :: [String] -> [[String]]
splitIntoGroups = aux . nextGroup where
  aux (grp,[])   = grp : []
  aux (grp,rmdr) = grp : (aux . nextGroup $ rmdr)

unique :: Eq a => [a] -> [a]
unique = foldr aux [] where
  aux x acc = if x `elem` acc then acc else x : acc

uniqueResponses  :: [String] -> String
uniqueResponses = unique . sort . foldr1 (++)

unpackGroupsUniques :: [String] -> ([[String]],[String])
unpackGroupsUniques s = (grps, map uniqueResponses grps) where
  grps = splitIntoGroups s

groupAgreement :: [String] -> String -> [Bool]
groupAgreement grp uniques = map aux uniques where
  aux uniq = all (elem uniq) grp

countAgreements :: [String] -> String -> Int
countAgreements grp uniqs = sum . map fromEnum $ groupAgreement grp uniqs

printGroupAgreement :: [String] -> String -> IO ()
printGroupAgreement grp uniqs = do
  print grp
  print uniqs
  print $ countAgreements grp uniqs
  putStrLn ""

bind2 :: (a -> b -> c) -> (a,b) -> c
bind2 fn (x,y) = fn x y

main :: IO ()
main = do
  putStrLn "===================PROGRAM===================="

  dataFile <- readFile "06.txt"
  let actualData = lines $ dataFile
  let (actGroups, actUniques) = unpackGroupsUniques actualData

  let (testGroups, testUniques) = unpackGroupsUniques testData

  putStrLn "Test Part One (should be 11)"
  print . foldr1 (+) . map length $ testUniques
  putStrLn "Answer:"
  print . foldr1 (+) . map length $ actUniques -- 6809
  
  putStrLn "Test Part Two (should be 6)"
  print . sum . map (bind2 countAgreements) $ zip testGroups testUniques
  putStrLn "Answer:"
  print . sum . map (bind2 countAgreements) $ zip actGroups actUniques -- 3394

