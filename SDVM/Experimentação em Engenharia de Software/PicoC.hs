module PicoC where

import Parser
import Prelude hiding ((<*>),(<$>))
import Data.Char

data PicoC = PicoC[Inst]
            -- deriving Show
data Inst = Atrib String Exp
          | While Exp BlocoC
          | ITE Exp BlocoC BlocoC 
          -- deriving Show 
type BlocoC = [Inst] 
data Exp = Const Int
         | Var String 
         -- deriving Show

instance Show PicoC where 
      show (PicoC insts) = showInst insts 
            where showInst [] = ""
                  showInst [x] = show x
                  showInst (x:xs) = show x ++ "; " ++ showInst xs 

instance Show Inst where
    show (Atrib var exp) = "Atrib " ++ var ++ " " ++ show exp
    show (While exp bloco) = "While " ++ show exp ++ " " ++ show bloco
    show (ITE exp bloco1 bloco2) = "ITE " ++ show exp ++ " " ++ show bloco1 ++ " " ++ show bloco2

instance Show Exp where
    show (Const n) = "Const " ++ show n
    show (Var str) = "Var " ++ str

pTipo = token' "int"
      <|> token' "char"
      <|> token' "float"
      <|> token' "double"

pIf = token' "if"
      <|> token' "If"
pThen = token' "then"
      <|> token' "Then"
pElse =  token' "Else"
      <|> token' "else"

pIgual = token' "="

pExp :: Parser Exp
pExp = f  <$> pInt
    <|> g <$> oneOrMore (satisfy' isLower)
    where f x = Const x 
          g x = Var x

pAtrib = f <$> pTipo <*> pExp
      <|> g <$> oneOrMore (satisfy' isLower) <*> pIgual <*> pExp
      where f x y = Atrib x y 
            g x _ y = Atrib x y

pWhile = f <$> pX <*> pExp <*> pBlocoC
      where f _ y z = While y z 

pITE = f <$> pIf <*> pExp <*> pThen <*> pBlocoC <*> pElse <*> pBlocoC
      where f _ x _ y _ z = ITE x y z

pInst = pAtrib 
      <|> pWhile
      <|> pITE

pBlocoC = enclosedBy (symbol' '{') (followedBy pInst (symbol' ';')) (symbol' '}')

pPicoC = f <$> enclosedBy (symbol' '{') (followedBy pInst (symbol' ';')) (symbol' '}')
      where f x = PicoC x 

