module PicoC where

import Parser
import Prelude hiding ((<*>),(<$>))
import Data.Char
import Data.Maybe

data PicoC = PicoC[Inst]
            -- deriving Show
data Inst = Atrib String Exp
          | While Exp BlocoC
          | ITE Exp BlocoC BlocoC 
          -- deriving Show 
type BlocoC = [Inst] 
data Exp = Const Int
         | Var String 
         | Add Exp Exp
         | Mult Exp Exp 
         | Neg Exp
         | Sub Exp Exp 
         deriving Show

instance Show PicoC where 
      show (PicoC insts) = showInst insts 
            where showInst [] = ""
                  showInst [x] = show x
                  showInst (x:xs) = show x ++ "; " ++ showInst xs 

instance Show Inst where
    show (Atrib var (Const n)) = var ++ " = " ++ show n
    show (Atrib var (Var str)) = var ++ " " ++ show str
    show (While (Var str) bloco) = "While(" ++ show str ++ "){" ++ show bloco ++ "}"
    show (While (Const n) bloco) = "While(" ++ show n ++ "){" ++ show bloco ++ "}"
    show (ITE (Var str) bloco1 bloco2) = "If (" ++ show str ++ ") then {" ++ show bloco1 ++ "} else {" ++ show bloco2 ++ "}; "
    show (ITE (Const n) bloco1 bloco2) = "If (" ++ show n ++ ") then {" ++ show bloco1 ++ "} else {" ++ show bloco2 ++ "}; "


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

pFator :: Parser Exp
pFator = f  <$> pInt
    <|> g <$> pNomes
    <|> h <$> symbol' '(' <*> pExp1 <*> symbol' ')'
    <|> j <$> symbol' '(' <*> pSub <*> symbol' ')'
    <|> i <$> pNeg 
    where f x = Const x 
          g x = Var x
          h _ x _ = x
          j _ x _ = x 
          i x =  x

pExp1 :: Parser Exp 
pExp1 =  h <$> pExp0 <*> symbol' '+' <*> pExp1
       <|> i <$> pExp0 
      where h a _ b = Add a b 
            i r = r

pExp0 :: Parser Exp 
pExp0 =  h <$> pFator <*> symbol' '*' <*> pExp0
       <|> i <$> pFator
      where h a _ b = Mult a b 
            i r = r

pSub :: Parser Exp 
pSub =  h <$> pExp0 <*> symbol' '-' <*> pSub
       <|> i <$> pExp0 
      where h a _ b = Sub a b 
            i r = r

pNeg :: Parser Exp 
pNeg = f <$> symbol' '-' <*> pFator
      where f _ y = Neg y


pAtrib = f <$> pTipo <*> pFator
      <|> g <$> oneOrMore (satisfy' isLower) <*> pIgual <*> pFator
      where f x y = Atrib x y 
            g x _ y = Atrib x y

pWhile = f <$> pX <*> pFator <*> pBlocoC
      where f _ y z = While y z 

pITE = f <$> pIf <*> pFator <*> pThen <*> pBlocoC <*> pElse <*> pBlocoC
      where f _ x _ y _ z = ITE x y z

pInst = pAtrib 
      <|> pWhile
      <|> pITE

pBlocoC = enclosedBy (symbol' '{') (followedBy pInst (symbol' ';')) (symbol' '}')

pPicoC = f <$> enclosedBy (symbol' '{') (followedBy pInst (symbol' ';')) (symbol' '}')
      where f x = PicoC x 

-- unParser : De AST para texto
unParser :: PicoC -> String  
unParser (PicoC insts) = unlines (map unParseInst insts)

unParseInst :: Inst -> String
unParseInst (Atrib var exp) = var ++ " = " ++ unParseExp exp ++ ";"
unParseInst (While exp bloco) = "while (" ++ unParseExp exp ++ ") {" ++ unParseBloco bloco ++ "}"
unParseInst (ITE exp bloco1 bloco2) =
  "if (" ++ unParseExp exp ++ ") {" ++ unParseBloco bloco1 ++ "} else {" ++ unParseBloco bloco2 ++ "}"

unParseBloco :: BlocoC -> String
unParseBloco insts = unlines (map unParseInst insts)

unParseExp :: Exp -> String
unParseExp (Const n) = show n
unParseExp (Var var) = var
unParseExp (Add exp1 exp2) = unParseExp exp1 ++ " + " ++ unParseExp exp2
unParseExp (Mult exp1 exp2) = unParseExp exp1 ++ " * " ++ unParseExp exp2

eval :: Exp -> [(String,Int)] -> Int 
eval (Const i) _ = i 
eval (Var v) c = fromJust(lookup v c)
eval (Neg e) c = -(eval e c)
eval (Add e d) c = eval e c + eval d c
eval (Mult e d) c = eval e c * eval d c
--------------------- Otimizações do artigo -------------------------------
-- opt :: PicoC -> PicoC
opt :: Exp -> Exp
opt(Add e (Const 0)) = opt e 
opt(Add (Const 0) e) = opt e 
opt(Add (Const a) (Const b)) = Const (a+b)
opt(Sub e1 e2) = Add e1 (Neg e2)
opt(Neg(Neg e)) = opt e 
opt(Neg(Const a)) = Const (-a) 
opt(Mult e1 e2) = Mult (opt e1) (opt e2)
opt(Add e1 e2) = Add (opt e1) (opt e2)
opt e = e 
