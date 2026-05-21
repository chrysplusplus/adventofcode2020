import Control.Arrow
import Data.Word

testData :: [String]
testData = ["mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X", "mem[8] = 11", "mem[7] = 101", "mem[8] = 0"]

type UInt64 = Word64

data Instruction = SetMask String
                 | SetMem Word64 Word64

tokens :: String -> [String]
tokens = splitTokens [] ""
  where
    appendToken tkns ""      = tkns
    appendToken tkns tkn = tkns ++ [tkn]
    appendToken2 tkns "" tkn2   = tkns ++ [tkn2]
    appendToken2 tkns tkn1 tkn2 = tkns ++ [tkn1,tkn2]

    splitTokens tkns cur_tkn "" = appendToken tkns cur_tkn
    splitTokens tkns cur_tkn (x:xs) = case x of
      ' ' -> splitTokens (appendToken tkns cur_tkn) "" xs
      '[' -> splitTokens (appendToken2 tkns cur_tkn "[") "" xs
      ']' -> splitTokens (appendToken2 tkns cur_tkn "]") "" xs
      _   -> splitTokens tkns (cur_tkn ++ [x]) xs

parseInstruction :: String -> Maybe Instruction
parseInstruction = arr tokens >>>
  isSetMask >>> (isSetMem >>> noInstruction ||| mkSetMem) ||| mkSetMask
    where
      isSetMask = arr head &&& arr id >>>
        arr (\(instruction,s) -> if instruction == "mask" then Left s else Right s)
      mkSetMask =
      isSetMem = arr head &&& arr id >>>
        arr (\(instruction,s) -> if instruction == "mem" then Left () else Right s)

main :: IO ()
main = do
  putStrLn "Part One (test = 165)"
  print $ map tokens testData
