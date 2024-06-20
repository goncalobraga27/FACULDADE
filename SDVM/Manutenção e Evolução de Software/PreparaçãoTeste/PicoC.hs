module PicoC where

import Parser
import Prelude hiding ((<*>),(<$>))
import Data.Char
import Data.Maybe
import Data.Data
import Debug.Trace

data PicoC = PicoC[Inst]
            deriving (Data,Show,Eq)

data Inst = Atrib String Exp
          | While Exp BlocoC
          | ITE Exp BlocoC BlocoC 
          | Comment SeparadorC String
          | Print String   -- Para imprimir a string 
          deriving (Data,Show,Eq) 

type BlocoC = [Inst] 

data Exp = Const Int
         | Var String 
         | Add Exp Exp
         | Mult Exp Exp 
         | Div Exp Exp
         | Neg Exp
         | Sub Exp Exp 
         | More Exp Exp 
         | Minus Exp Exp 
         | NotMore Exp Exp 
         | NotMinus Exp Exp 
         | Equal Exp Exp 
         deriving (Data,Show,Eq)

data SeparadorC = Sep String
                  deriving (Data,Show,Eq)

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
    <|> i <$> pNeg 
    where f x = Const x 
          g x = Var x
          h _ x _ = x
          i x =  x

pExp1 :: Parser Exp 
pExp1 =  h <$> pExp0 <*> symbol' '+' <*> pExp1
      <|>  g <$> pExp0 <*> symbol' '-' <*> pExp1
       <|> i <$> pExp0 
      where h a _ b = Add a b 
            g a _ b = Sub a b 
            i r = r

pExp0 :: Parser Exp 
pExp0 =  h <$> pFator <*> symbol' '*' <*> pExp0
      <|> g <$> pFator <*> symbol' '/' <*> pExp0
       <|> i <$> pFator
      where h a _ b = Mult a b 
            g a _ b = Div a b 
            i r = r
pCond :: Parser Exp 
pCond = h <$> pExp1 <*> symbol' '>' <*> pExp1 
      <|> g <$> pExp1 <*> symbol' '<' <*> pExp1
      <|> i <$> pExp1 <*> symbol' '=' <*> pExp1
      <|> j <$> token' "not" <*> pExp1 <*> symbol' '>' <*> pExp1 
      <|> k <$> token' "not" <*> pExp1 <*> symbol' '<' <*> pExp1
      <|> l <$> pFator
      where h x _ y = More x y
            g x _ y = Minus x y 
            i x _ y = Equal x y
            j _ x _ y = NotMore x y
            k _ x _ y = NotMinus x y
            l x = x

pNeg :: Parser Exp 
pNeg = f <$> symbol' '?' <*> pFator
      where f _ y = Neg y

pSeparadorC :: Parser SeparadorC
pSeparadorC = f <$> token' "\\"
            where f x = Sep x

pComment :: Parser Inst 
pComment = f <$> pSeparadorC <*> pNomes <*> symbol' ';'
      where f x y _= Comment x y

pAtrib = f <$> pTipo <*> pNomes <*> symbol' ';'
      <|> g <$> pTipo <*> pNomes <*> symbol' '=' <*> pExp1 <*> symbol' ';'
      <|> h <$> pNomes <*> symbol' '=' <*> pExp1 <*> symbol' ';'
      where f x y _     = Atrib x (Var y)
            g x y _ w _ = Atrib (x ++[' '] ++ y) w
            h x _ z _   = Atrib x z

pWhile = f <$> pX <*> symbol' '('<*> pCond <*> symbol' ')'<*> pBlocoC
      where f _ _ y _ z = While y z 

pITE = f <$> pIf <*> symbol' '('<*> pCond <*> symbol' ')' <*> pThen <*> pBlocoC <*> pElse <*> pBlocoC
      <|> g <$> pIf <*> token' "not"<*> symbol' '('<*> pCond <*> symbol' ')' <*> pThen <*> pBlocoC <*> pElse <*> pBlocoC
      where f _ _ x _ _ y _ z = ITE x y z
            g _ _ _ x _ _ y _ z = ITE (Neg x) y z

pInst = pAtrib 
      <|> pWhile
      <|> pITE
      <|> pComment

pBlocoC = enclosedBy (symbol' '{') (followedBy pInst (succeed [])) (symbol' '}')

pPicoC = f <$> enclosedBy (symbol' '{') (followedBy pInst (succeed [])) (symbol' '}')
      where f x = PicoC x 
      
givePicoC :: [(PicoC, b)] -> PicoC
givePicoC p = if length(p) /= 0 then (fst(head p)) else (PicoC [])

-- unParser : De AST para texto
unParser :: PicoC -> String  
unParser (PicoC insts) = "{" ++ concat (map unParseInst insts) ++ "}"

unParseInst :: Inst -> String
unParseInst (Atrib var exp) = var ++ " = " ++ unParseExp exp ++ ";"
unParseInst (While exp bloco) = "while (" ++ unParseExp exp ++ ") {" ++ unParseBloco bloco ++ "}"
unParseInst (ITE exp bloco1 bloco2) =
  "if (" ++ unParseExp exp ++ ") then {" ++ unParseBloco bloco1 ++ "} else {" ++ unParseBloco bloco2 ++ "}"
unParseInst (Comment sep texto) =
  "\\"++ texto ++";"

unParseBloco :: BlocoC -> String
unParseBloco insts = concat (map unParseInst insts)

unParseExp :: Exp -> String
unParseExp (Const n) = show n
unParseExp (Var var) = var
unParseExp (Add exp1 exp2) = "(" ++ unParseExp exp1 ++ " + " ++ unParseExp exp2 ++ ")"
unParseExp (Mult exp1 exp2) = "(" ++ unParseExp exp1 ++ " * " ++ unParseExp exp2 ++ ")"
unParseExp (Div exp1 exp2) = "(" ++ unParseExp exp1 ++ " / " ++ unParseExp exp2 ++ ")"
unParseExp (Neg exp1 ) = "-" ++ unParseExp exp1
unParseExp (Sub exp1 exp2) ="(" ++ unParseExp exp1 ++ " - " ++ unParseExp exp2 ++ ")"
unParseExp (More exp1 exp2) = unParseExp exp1 ++ " > " ++ unParseExp exp2
unParseExp (Minus exp1 exp2) = unParseExp exp1 ++ " < " ++ unParseExp exp2
unParseExp (Equal exp1 exp2) = unParseExp exp1 ++ " = " ++ unParseExp exp2

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

