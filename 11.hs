import Data.List

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

countPreds :: [a -> b -> Bool] -> a -> b -> Int
countPreds fns x y = sum $ map (\fn -> fromEnum $ fn x y) fns

isTileOccupied :: Grid -> Int -> Int -> Bool
isTileOccupied (Grid _ tiles) y x = checkTile ((tiles !! y) !! x)
  where
    checkTile OccupiedSeat = True
    checkTile _            = False

checkBoundedGridP :: Grid -> (Grid -> Int -> Int -> Bool) -> Int -> Int -> Bool
checkBoundedGridP g@(Grid (w,h) _) p y x
  | y <= -1 || y >= h || x <= -1 || x >= w = False
  | otherwise                              = p g y x

step :: Grid -> Grid
step g@(Grid shp tiles) = Grid shp $ zipWith stepRow tiles [0..]
  where
    neighbourPs = [
      (\y x -> checkBoundedGridP g isTileOccupied (pred y) x),
      (\y x -> checkBoundedGridP g isTileOccupied (pred y) (succ x)),
      (\y x -> checkBoundedGridP g isTileOccupied y (succ x)),
      (\y x -> checkBoundedGridP g isTileOccupied (succ y) (succ x)),
      (\y x -> checkBoundedGridP g isTileOccupied (succ y) x),
      (\y x -> checkBoundedGridP g isTileOccupied (succ y) (pred x)),
      (\y x -> checkBoundedGridP g isTileOccupied y (pred x)),
      (\y x -> checkBoundedGridP g isTileOccupied (pred y) (pred x))]
    occupiedNeighbours y x = countPreds neighbourPs y x
    stepTile _ _ Floor                        = Floor
    stepTile ycoord xcoord FreeSeat
      | occupiedNeighbours ycoord xcoord == 0 = OccupiedSeat
      | otherwise                             = FreeSeat
    stepTile ycoord xcoord OccupiedSeat
      | occupiedNeighbours ycoord xcoord >= 4 = FreeSeat
      | otherwise                             = OccupiedSeat
    stepRow row ycoord = zipWith (stepTile ycoord) [0..] row

main :: IO ()
main = do
  putStrLn "Part One (test = 37)"
  let g = grid testData

  let gs = iterate step g
  let gN = (gs !!)

  let zs = zip gs (drop 1 gs)

  let (z0,z1) = zs !! 5
  print z0
  putStrLn ""
  print z1
  putStrLn ""
  print (z0 == z1)

