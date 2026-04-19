import Control.Arrow
import Data.Maybe
import Text.Read

testData :: [String]
testData = ["nop +0", "acc +1", "jmp +4", "acc +3", "jmp -3", "acc -99",
            "acc +1", "jmp -4", "acc +6"]

data Instruction = Acc Int | Jmp Int | Nop Int
  deriving Show

type Program = [Instruction]

data Machine = Machine {getVisited :: [Int], getAcc :: Int, getIP :: Int}
  deriving Show

compileProg :: [String] -> Program
compileProg = map compInstr where
  signedIntFrom =
    arr head &&&                                              -- sign
    (arr (drop 1) >>> arr readMaybe >>> arr (fromMaybe 0)) >>> -- number
    arr (\(s,n) -> case s of '+' -> n; _ -> (-1) * n)
  compInstr = arr words >>>
    arr head &&&                   -- instruction
    (arr last >>> signedIntFrom) >>> -- operand
    arr (\(i,n) -> case i of "acc" -> Acc n; "jmp" -> Jmp n; _ -> Nop n)

initMachine :: Machine
initMachine = Machine [] 0 0

stepMachine :: Program -> Machine -> Machine
stepMachine program machine = run . checkInfLoop . checkTerminate . getIP $ machine where
  checkTerminate ip = if ip < length program then Right ip else Left ()
  checkInfLoop (Left ())  = Left()
  checkInfLoop (Right ip) = if ip `elem` getVisited machine then Left () else Right (program !! ip)
  run instruction  = case instruction of
    Left ()       -> machine
    Right (Acc i) -> Machine (ip : visited) (acc + i) (ip + 1)
    Right (Jmp i) -> Machine (ip : visited) acc (ip + i)
    Right (Nop _) -> Machine (ip : visited) acc (ip + 1)
    where
      visited = getVisited machine
      acc = getAcc machine
      ip = getIP machine

findHaltingIndex :: [Machine] -> Int
findHaltingIndex = count . diff where
  diff (x0:x1:xs) = (getIP x0 == getIP x1) : diff (x1:xs)
  diff _          = []
  count = length . takeWhile not

infiniteRun :: Program -> Machine -> [Machine]
infiniteRun program = iterate (stepMachine program)

findHaltingState :: [Machine] -> Machine
findHaltingState states = (states !!) $ findHaltingIndex states

isProgramTerminated :: Program -> Machine -> Bool
isProgramTerminated program machine = length program == getIP machine

indexes :: [a] -> [(a,Int)]
indexes xs = zip xs [0..]

corruptionPoints :: Program -> [Int]
corruptionPoints = map snd . filter matchCorruptions . indexes where
  matchCorruptions (x,_) = case x of
    Nop _ -> True
    Jmp _ -> True
    _     -> False

fixCorruption :: Program -> Int -> Program
fixCorruption program idx = map fix . indexes $ program where
  fix (x,i) = if i == idx
    then case x of
      Nop n -> Jmp n
      Jmp n -> Nop n
      _     -> x
    else x

canProgramTerminate :: Program -> [Machine] -> Bool
canProgramTerminate program = isProgramTerminated program . findHaltingState

findTerminatingProgram :: Program -> Maybe (Program,[Machine])
findTerminatingProgram program = aux $ corruptionPoints program where
  aux []     = Nothing
  aux (p:ps) = if canProgramTerminate fixed run
    then Just (fixed, take (1 + findHaltingIndex run) run)
    else aux ps
    where
      fixed = fixCorruption program p
      run = infiniteRun fixed initMachine

solvePartOne :: [String] -> Int
solvePartOne = getAcc . findHaltingState . flip infiniteRun initMachine . compileProg

solvePartTwo :: [String] -> Int
solvePartTwo input = getAcc.last.snd.fromMaybe (code,[]) $ findTerminatingProgram code where
  code = compileProg input

main :: IO ()
main = do
  putStrLn "===================PROGRAM===================="

  dataFile <- readFile "08.txt"
  let realData = lines dataFile

  putStrLn "Test Part One (should be 5)"
  print . solvePartOne $ testData
  putStrLn "Answer:"
  print . solvePartOne $ realData -- 1723

  putStrLn "Test Part Two (should be 8)"
  print . solvePartTwo $ testData
  putStrLn "Answer:"
  print . solvePartTwo $ realData -- 846

