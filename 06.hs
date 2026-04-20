import Data.List

testData :: [String]
testData = ["abc", "", "a", "b", "c", "", "ab", "ac", "", "a", "a", "a", "a", "", "b", ""]

nextGroup :: [String] -> ([String],[String])
nextGroup = aux . break null where
  aux (grp, xs) = (grp, drop 1 xs)

splitIntoGroups :: [String] -> [[String]]
splitIntoGroups = aux . nextGroup where
  aux (grp,[])   = [grp]
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
groupAgreement grp = map aux where
  aux uniq = all (elem uniq) grp

countAgreements :: [String] -> String -> Int
countAgreements grp uniqs = sum . map fromEnum $ groupAgreement grp uniqs

printGroupAgreement :: [String] -> String -> IO ()
printGroupAgreement grp uniqs = do
  print grp
  print uniqs
  print $ countAgreements grp uniqs
  putStrLn ""

main :: IO ()
main = do
  putStrLn "===================PROGRAM===================="

  dataFile <- readFile "06.txt"
  let actualData = lines dataFile
  let (actGroups, actUniques) = unpackGroupsUniques actualData

  let (testGroups, testUniques) = unpackGroupsUniques testData

  putStrLn "Test Part One (should be 11)"
  print . sum $ map length testUniques
  putStrLn "Answer:"
  print . sum $ map length actUniques -- 6809
  
  putStrLn "Test Part Two (should be 6)"
  print . sum $ zipWith countAgreements testGroups testUniques
  putStrLn "Answer:"
  print . sum $ zipWith countAgreements actGroups actUniques -- 3394

