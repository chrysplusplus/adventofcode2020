import Control.Arrow

testData :: [String]
testData = ["F10", "N3", "F7", "R90", "F11"]

data Instruction = North Int
                 | East Int
                 | South Int
                 | West Int
                 | Forward Int
                 | Turn Int
                  deriving (Show, Eq, Ord)

instruction :: String -> Instruction
instruction = arr (splitAt 1) >>> arr matchType *** arr read >>> arr construct
  where
    matchType "N" = North
    matchType "E" = East
    matchType "S" = South
    matchType "W" = West
    matchType "F" = Forward
    matchType ch  = turn ch
    construct (ctor,arg) = ctor arg
    turn "L" arg = Turn (4 - arg `div` 90)
    turn _ arg   = Turn (arg `div` 90)

isNorth :: Instruction -> Bool
isNorth (North _) = True
isNorth _         = False

isEast :: Instruction -> Bool
isEast (East _) = True
isEast _        = False

isSouth :: Instruction -> Bool
isSouth (South _) = True
isSouth _         = False

isWest :: Instruction -> Bool
isWest (West _) = True
isWest _        = False

isForward :: Instruction -> Bool
isForward (Forward _) = True
isForward _           = False

isTurn :: Instruction -> Bool
isTurn (Turn _) = True
isTurn _        = False

type Facing = Int

data Ship = Ship {getCoord :: (Int,Int), getFacing :: Facing}
  deriving Show

initShip :: Ship
initShip = Ship (0,0) 1

absoluteInstructions :: Facing -> [Instruction] -> [Instruction]
absoluteInstructions f = filter (not . isTurn) . aux f
  where
    aux _ []          = []
    aux facing (x:xs) = let (x',fcing) = followTurn facing x in x' : aux fcing xs
    followTurn 0 (Forward arg)  = (North arg, 0)
    followTurn 1 (Forward arg)  = (East arg, 1)
    followTurn 2 (Forward arg)  = (South arg, 2)
    followTurn _ (Forward arg)  = (West arg, 3)
    followTurn fcing (Turn arg) = (Turn 0, (fcing + arg) `mod` 4)
    followTurn fcing instrctn   = (instrctn, fcing)

followInstructions :: Ship -> [Instruction] -> Ship
followInstructions sh = aux sh . absoluteInstructions (getFacing sh)
  where
    aux ship [] = ship
    aux ship (x:xs) = aux (follow ship x) xs
    follow (Ship (xc,yc) facing) (North arg) = Ship (xc, yc + arg) facing
    follow (Ship (xc,yc) facing) (East arg)  = Ship (xc + arg, yc) facing
    follow (Ship (xc,yc) facing) (South arg) = Ship (xc, yc - arg) facing
    follow (Ship (xc,yc) facing) (West arg)  = Ship (xc - arg, yc) facing
    follow ship _                            = ship

manhattanDistance :: (Int,Int) -> Int
manhattanDistance (x,y) = abs x + abs y

data ShipWaypoint = ShipWaypoint {getCoordW :: (Int,Int), getWaypoint :: (Int,Int)}
  deriving Show

initShipWaypoint :: ShipWaypoint
initShipWaypoint = ShipWaypoint (0,0) (10,1)

followInstructionsW :: ShipWaypoint -> [Instruction] -> ShipWaypoint
followInstructionsW ship []     = ship
followInstructionsW ship (x:xs) = followInstructionsW (follow ship x) xs
  where
    follow (ShipWaypoint coord (wx,wy)) (North arg)       = ShipWaypoint coord (wx, wy + arg)
    follow (ShipWaypoint coord (wx,wy)) (East arg)        = ShipWaypoint coord (wx + arg, wy)
    follow (ShipWaypoint coord (wx,wy)) (South arg)       = ShipWaypoint coord (wx, wy - arg)
    follow (ShipWaypoint coord (wx,wy)) (West arg)        = ShipWaypoint coord (wx - arg, wy)
    follow (ShipWaypoint (sx,sy) w@(wx,wy)) (Forward arg) = ShipWaypoint (sx + arg * wx, sy + arg * wy) w
    follow ship' (Turn arg)                               = turn ship' arg
    turn ship' 0                        = ship'
    turn (ShipWaypoint coord (wx,wy)) 1 = ShipWaypoint coord (wy,-wx)
    turn (ShipWaypoint coord (wx,wy)) 2 = ShipWaypoint coord (-wx,-wy)
    turn (ShipWaypoint coord (wx,wy)) _ = ShipWaypoint coord (-wy,wx)

main :: IO ()
main = do
  datafile <- readFile "12.txt"
  let realData = lines datafile

  putStrLn "Part One (test = 25)"
  let testInstructions = map instruction testData
  print . manhattanDistance . getCoord $ followInstructions initShip testInstructions
  putStrLn "Answer:"
  let realInstructions = map instruction realData
  print . manhattanDistance . getCoord $ followInstructions initShip realInstructions

  putStrLn "Part Two (test = 286)"
  print . manhattanDistance . getCoordW $ followInstructionsW initShipWaypoint testInstructions
  putStrLn "Answer:"
  print . manhattanDistance . getCoordW $ followInstructionsW initShipWaypoint realInstructions

