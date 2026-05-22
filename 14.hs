import Control.Arrow
import Data.Word

testData :: [String]
testData = ["mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X", "mem[8] = 11", "mem[7] = 101", "mem[8] = 0"]

type UInt64 = Word64

data Instruction = SetMask String
                 | SetMem Word64 Word64

rightarr = right . arr

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
parseInstruction = arr tokens >>> arr matchInstruction
  where
    mEq tkns = case tkns of
      []     -> Left ()
      (x:xs) -> if (x == "=") then Right xs else Left ()
    mSbl tkns = case tkns of
      []     -> Left ()
      (x:xs) -> if (x == "[") then Right xs else Left ()
    mSbr tkns = case tkns of
      []     -> Left ()
      (x:xs) -> if (x == "]") then Right xs else Left ()
    extractMask tkns = case tkns of
      []    -> Left ()
      (x:_) -> Right $ SetMask x
    extractAddr tkns = case tkns of
      []
      (x:xs)
    extractInstruction x = case x of
      Left _            -> Nothing
      Right instruction -> Just instruction
    parseSetMask = arr mEq >>> rightarr extractMask >>> arr extractInstruction
    parseSetMem = arr mSbl >>> rightarr extractAddr >>> rightarr mSbr >>>
                    rightarr mEq >>> rightarr extractVal >>> arr extractInstruction
    matchInstruction tkns = case tkns of
      []     -> Nothing
      (command:tkns') -> case command of
        "mask" -> parseSetMask tkns'
        "mem"  -> parseSetMem tkns'
        _      -> Nothing

main :: IO ()
main = do
  putStrLn "Part One (test = 165)"
  print $ map tokens testData
