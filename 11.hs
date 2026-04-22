import Data.List
import Data.Maybe

testData :: [String]
testData = ["L.LL.LL.LL", "LLLLLLL.LL", "L.L.L..L..", "LLLL.LL.LL",
            "L.LL.LL.LL", "L.LLLLL.LL", "..L.L.....", "LLLLLLLLLL",
            "L.LLLLLL.L", "L.LLLLL.LL"]

data Tile = Floor | FreeSeat | OccupiedSeat
  deriving Eq

instance Show Tile where
  show Floor        = "."
  show FreeSeat     = "L"
  show OccupiedSeat = "#"

data Grid = Grid { getShape :: (Int,Int), getTiles :: [[Tile]] }

instance Show Grid where
  show (Grid _ tiles) =
    foldl1 (++) . intersperse "\n" $ map (map (head . show)) tiles

instance Eq Grid where
  (Grid shp0 g0) == (Grid shp1 g1)
    | shp0 == shp1 = all (\(r0,r1) -> all (uncurry (==)) $ zip r0 r1) $ zip g0 g1
    | otherwise    = False

grid :: [String] -> Grid
grid rows = Grid (x,y) $ map gridRow rows
  where
    x       = length $ head rows
    y       = length rows
    gridRow = map (\ch -> if ch == 'L' then FreeSeat else Floor)

countBinaryPreds :: [a -> b -> Bool] -> a -> b -> Int
countBinaryPreds fns x y = sum $ map (\fn -> fromEnum $ fn x y) fns

isTileOccupied :: Grid -> Int -> Int -> Bool
isTileOccupied (Grid _ tiles) y x = checkTile ((tiles !! y) !! x)
  where
    checkTile OccupiedSeat = True
    checkTile _            = False

checkBoundedGridApplyP :: Grid -> (Grid -> Int -> Int -> Bool) -> Int -> Int -> Bool
checkBoundedGridApplyP g@(Grid (w,h) _) p y x
  | y <= -1 || y >= h || x <= -1 || x >= w = False
  | otherwise                              = p g y x

step :: Grid -> Grid
step g@(Grid shp tiles) = Grid shp $ zipWith stepRow tiles [0..]
  where
    neighbourPs = [
      \y x -> checkBoundedGridApplyP g isTileOccupied (pred y) x,
      \y x -> checkBoundedGridApplyP g isTileOccupied (pred y) (succ x),
      \y x -> checkBoundedGridApplyP g isTileOccupied y (succ x),
      \y x -> checkBoundedGridApplyP g isTileOccupied (succ y) (succ x),
      \y x -> checkBoundedGridApplyP g isTileOccupied (succ y) x,
      \y x -> checkBoundedGridApplyP g isTileOccupied (succ y) (pred x),
      \y x -> checkBoundedGridApplyP g isTileOccupied y (pred x),
      \y x -> checkBoundedGridApplyP g isTileOccupied (pred y) (pred x)]
    occupiedNeighbours = countBinaryPreds neighbourPs
    stepTile _ _ Floor                        = Floor
    stepTile ycoord xcoord FreeSeat
      | occupiedNeighbours ycoord xcoord == 0 = OccupiedSeat
      | otherwise                             = FreeSeat
    stepTile ycoord xcoord OccupiedSeat
      | occupiedNeighbours ycoord xcoord >= 4 = FreeSeat
      | otherwise                             = OccupiedSeat
    stepRow row ycoord = zipWith (stepTile ycoord) [0..] row

countOccupiedSeats :: Grid -> Int
countOccupiedSeats (Grid _ tiles) = foldl countRow 0 tiles
  where
    countRow = foldl countTile
    countTile acc OccupiedSeat = succ acc
    countTile acc _            = acc

findStableGrid :: (Grid -> Grid) -> Grid -> Grid
findStableGrid fn g = fst . head . dropWhile (uncurry (/=)) $ zip gs (drop 1 gs)
  where gs = iterate fn g

checkBoundedCoordP :: Grid -> (Int,Int) -> Bool
checkBoundedCoordP (Grid (w,h) _) (y,x)
  | y <= -1 || y >= h || x <= -1 || x >= w = False
  | otherwise                              = True

getTile :: Grid -> (Int,Int) -> Maybe Tile
getTile g@(Grid _ tiles) (y,x)
  | checkBoundedCoordP g (y,x) = Just ((tiles !! y) !! x)
  | otherwise                  = Nothing

countPreds :: (a -> Bool) -> [a] -> Int
countPreds fn = sum . map (fromEnum . fn)

isOccupied :: Tile -> Bool
isOccupied OccupiedSeat = True
isOccupied _            = False

isFloor :: Tile -> Bool
isFloor Floor = True
isFloor _     = False

isFree :: Tile -> Bool
isFree FreeSeat = True
isFree _        = False

step2 :: Grid -> Grid
step2 g@(Grid shp tiles) = Grid shp $ zipWith stepRow [0..] tiles
  where
    stepRow y = zipWith (stepTile y) [0..]
    stepTile _ _ Floor = Floor
    stepTile y x FreeSeat = let coords = (y,x) in if countPreds isOccupied (neighbours coords) == 0
      then OccupiedSeat
      else FreeSeat
    stepTile y x OccupiedSeat = let coords = (y,x) in if countPreds isOccupied (neighbours coords) >= 5
      then FreeSeat
      else OccupiedSeat
    neighbours coords = mapMaybe (findNextSeatInDirection coords) directions
    findNextSeatInDirection coords direction =
      find (not . isFloor) . catMaybes . takeWhile isJust . map (getTile g) . drop 1 $ iterate direction coords

    directions = [north, northeast, east, southeast, south, southwest, west, northwest]
    north (y,x)     = (pred y, x)
    northeast (y,x) = (pred y, succ x)
    east (y,x)      = (y, succ x)
    southeast (y,x) = (succ y, succ x)
    south (y,x)     = (succ y, x)
    southwest (y,x) = (succ y, pred x)
    west (y,x)      = (y, pred x)
    northwest (y,x) = (pred y, pred x)

main :: IO ()
main = do
  datafile <- readFile "11.txt"
  let realData = lines datafile

  putStrLn "Part One (test = 37)"
  let testGrid = grid testData
  print . countOccupiedSeats $ findStableGrid step testGrid
  putStrLn "Answer:"
  let realGrid = grid realData
  print . countOccupiedSeats $ findStableGrid step realGrid

  putStrLn "Part Two (test = 26)"
  print . countOccupiedSeats $ findStableGrid step2 testGrid
  putStrLn "Answer:"
  print . countOccupiedSeats $ findStableGrid step2 realGrid

