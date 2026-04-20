import Control.Arrow
import Data.Graph
import Data.Map (Map, fromList, (!))
import Data.Maybe
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
breakAt brk = break (brk ==)

intPrefixOf :: Int -> String -> Int
intPrefixOf def = fromMaybe def . readMaybe . takeWhile (`elem` ['0'..'9'])

joinWords :: [String] -> String
joinWords = foldr1 (\x acc -> x ++ " " ++ acc)

parseChild :: String -> (Int,Bag)
parseChild = arr words >>>
  (arr head >>> arr (intPrefixOf 0)) &&&            -- bag count
  (arr (drop 1) >>> arr (take 2) >>> arr joinWords) -- bag type

parseRule :: String -> Rule
parseRule = arr words >>>
  (arr (take 2) >>> arr joinWords) &&& -- bag type
  (arr (drop 4) >>> arr joinWords) >>> -- children
  second (
    hasChildren >>> noChildren ||| parseChildren
  ) >>>
  arr (uncurry Rule)
    where
      hasChildren = (arr words >>> arr head) &&& arr id >>>
        arr (\(w,s) -> if w == "no" then Left () else Right s)
      parseChildren' (this,"")   = [parseChild this]
      parseChildren' (this,next) = parseChild this : parseChildren' (breakAt ',' $ drop 1 next)
      noChildren = arr (const [])
      parseChildren = arr (breakAt ',') >>> arr parseChildren'

ruleToVertex :: Rule -> (Bag, Bag, [Bag])
ruleToVertex (Rule name children) = (name, name, [snd child | child <- children])

pairWithSnd :: Eq a => a -> [a] -> [(a,a)]
pairWithSnd l = map (, l) . filter (not . (==) l)

countContainingBags :: Bag -> [Rule] -> Int
countContainingBags bag rules = sum . map (fromEnum . uncurry (path graph)) $ pairs where
  (graph, _, vertexFromKey) = graphFromEdges . map ruleToVertex $ rules
  justVertex = fromJust . vertexFromKey
  pairs = pairWithSnd (justVertex bag) . map (\(Rule n _) -> justVertex n) $ rules

weightsMap :: (Bag -> Maybe Vertex) -> [Rule] -> Map (Vertex, Vertex) Int
weightsMap vertexFromKey = fromList . foldr1 (++) . map keyCountFromRule where
  justVertex = fromJust . vertexFromKey
  makeKVPair b c n = ((justVertex b, justVertex c), n)
  keyCountFromRule (Rule bag children) = [makeKVPair bag child count | (count,child) <- children]

traverseWeightedGraph :: Map (Vertex, Vertex) Int -> Graph -> Vertex -> Int
traverseWeightedGraph weights graph = aux . edgesOf where
  edgesOf v = filter ((==v).fst) . edges $ graph
  weightOf v0 v1 = weights ! (v0,v1)
  aux es = sum [weightOf v0 v1 * ((aux . edgesOf $ v1) + 1) | (v0,v1) <- es]

countContainedBags :: Bag -> [Rule] -> Int
countContainedBags bag rules = traverseWeightedGraph weights graph . fromJust $ vertexFromKey bag where
  (graph, _, vertexFromKey) = graphFromEdges $ map ruleToVertex rules
  weights = weightsMap vertexFromKey rules

main :: IO ()
main = do
  putStrLn "===================PROGRAM===================="

  dataFile <- readFile "07.txt"
  let realData = lines dataFile

  putStrLn "Test Part One (should be 4)"
  print . countContainingBags "shiny gold" . map parseRule $ testData
  putStrLn "Answer:"
  print . countContainingBags "shiny gold" . map parseRule $ realData -- 179

  putStrLn "Test Part Two (should be 32)"
  print . countContainedBags "shiny gold" . map parseRule $ testData
  putStrLn "Answer:"
  print . countContainedBags "shiny gold" . map parseRule $ realData -- 18925


