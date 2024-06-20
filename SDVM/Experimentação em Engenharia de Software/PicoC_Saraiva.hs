--------------------------------------------------------
--  Sw Maintenance and Evolution
--  Combinadores de Parsing
--  2023/2024
--------------------------------------------------------

module PicoC where
import Prelude hiding ((<*>),(<$>))
import Data.Char
import Data.Maybe

import Parser


-- TPC (aula de 22/2)

-- completar o parser
-- estender o parser para permitir outros operadores
-- (úteis nas condições do While e IFE) 
--       por exemplo em Haskell/C/Java é possível 
--            ghci> 2 + 3 > 5
--            False
--       logo a adição tem mais prioridade que > ...
-- completar a função unparser
-- melhorar a função opt para fazer todas as optimizacoes
-- testar a propriedade definida pela função prop
--   prop :: PicoC -> Bool
--   prop ast = ast == parser (unparse ast)
-- (precisam usar deriving Eq nos datas types)



--------------------------------------------------------
-- Arvore de Syntaxe Abstrata
--------------------------------------------------------

data PicoC = PicoC [Inst]

data Inst = Atrib String Exp
          | While Exp BlocoC
	  | ITE   Exp BlocoC BlocoC

type BlocoC = [Inst]


data Exp = Add Exp Exp
         | Mul Exp Exp
	 | Neg Exp
         | Const Int
         | Var   String
	 deriving Show


--------------------------------------------------------
-- Parser
--------------------------------------------------------


-- pPicoC :: Parser PicoC


pExp1 :: Parser Exp
pExp1    =   f <$>    pExp0  <*> symbol' '+' <*>  pExp1
        <|>  g <$>    pExp0
    where f a b c = Add a c
          g r     = r

pExp0 :: Parser Exp
pExp0    =   f <$>    pFactor  <*> symbol' '*' <*>  pExp0
        <|>  g <$>    pFactor
    where f a b c = Mul a c
          g r     = r

pFactor :: Parser Exp
pFactor =   f  <$>  pInt
        <|> g  <$>  pNomes
	<|> h  <$>  symbol' '(' <*> pExp1 <*> symbol' ')'
    where f a     = Const a
          g a     = Var   a
          h a b c = b

--------------------------------------------------------
-- Unparser: Da AST para texto
-- (pretty printing)
--------------------------------------------------------

{-
instance Show PicoC where
  show = Unparser

unparser :: PicoC -> String
-}



-- pExp1 "(3 + aux1) * 5"
ast = Mul (Add (Const 3) (Var "aux1")) (Const 5)


eval :: Exp -> [(String,Int)] -> Int
eval (Const i) _ = i
eval (Var   n) c = fromJust (lookup n c) 
eval (Neg e)   c =  - (eval e c)
eval (Add e d) c = eval e c + eval d c
eval (Mul e d) c = eval e c * eval d c


--opt :: PicoC -> PicoC


--opt :: Exp -> Exp
opt (Add (Const 0) e)         = opt e
opt (Add e (Const 0))         = opt e
opt (Add (Const a) (Const b)) = Const (a + b)
opt (Neg (Const a))           = Const (-a)
opt (Mul e1 e2)               = Mul (opt e1) (opt e2)
opt (Add e1 e2)               = Add (opt e1) (opt e2)
opt e                         = e


ast2 = Mul (Add (Const 3) (Const 0)) (Const 5)



--   (neg 4  +  4) + 5
--   --> 5

ast3 = Add (Add (Neg (Const 4)) (Const 4)) (Const 5)

{-
ghci> opt ast3
Add (Add (Const (-4)) (Const 4)) (Const 5)
ghci> opt $ opt ast3
Add (Const 0) (Const 5)
ghci> opt $ opt $ opt ast3
Const 5
ghci> opt $ opt $ opt $ opt ast3
Const 5

Ponto Fixo!
-}


