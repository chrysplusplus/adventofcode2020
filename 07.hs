import Data.Tuple
import Text.Read

testData :: [String]
testData = ["light red bags contain 1 bright white bag, 2 muted yellow bags.",
            "dark orange bags contain 3 bright white bags, 4 muted yellow bags.",
            "bright white bags contain 1 shiny gold bag.",
            "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.",
            "shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.",
            "dark olive bags contain 3 faded blue bags, 4 dotted black bags.",
            "vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.",
            "faded blue bags contain no other bags.",
            "dotted black bags contain no other bags."]

type Bag = String
data Rule = Rule Bag [(Int,Bag)]
  deriving Show

breakAt :: Eq a => a -> [a] -> ([a],[a])
breakAt brk = break ((==) brk)

maybeIntPrefixOf :: String -> Maybe Int
maybeIntPrefixOf = readMaybe . takeWhile (`elem` ['0'..'9'])

intPrefixOf :: Int -> String -> Int
intPrefixOf def s = maybe def id $ maybeIntPrefixOf s

joinWords :: [String] -> String
joinWords = foldr1 (\x acc -> x ++ " " ++ acc)

parseRule = toRule . children . skipDefineTkn . subjectColor . words where
  subjectColor = swap . breakAt "bags"
  skipDefineTkn (parse,keep) = (drop 2 parse, keep)
  childCount = intPrefixOf 0
  bagTknFilter = (`notElem` ["bag", "bags", "bag.", "bags."])
  childBag = joinWords . filter bagTknFilter . drop 1 . words
  parseChild child = (childCount child, childBag child)
  parseChildren (this,[]) = parseChild this : []
  parseChildren (this,next) = parseChild this : (parseChildren . breakAt ',' . drop 2 $ next)
  children (parse,keep) = (parseChildren . breakAt ',' . joinWords $ parse, keep)
  toRule (children,subject) = Rule (joinWords subject) children

main :: IO ()
main = do
  putStrLn "===================PROGRAM===================="

  putStrLn "Test Part One (should be 4)"
  print . parseRule $ head testData

