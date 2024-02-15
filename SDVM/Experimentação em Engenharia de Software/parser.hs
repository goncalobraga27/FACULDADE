module Parser where 

import Data.Char 
import Prelude hiding ((<*>),(<$>))

infixl 2 <|>
infixl 3 <*>

type Parser r = String -> [(r,String)]


symbola :: String ->[(Char,String)]
symbola [] = []
symbola (h:t) = if h == 'a'
                then [('a',t)]
                else []

-- symbol :: Char -> String -> [(Char,String)]
symbol :: Char -> Parser Char 
symbol s [] = []
symbol s (h:t) = if s == h 
                 then [(s,t)]
                 else []

satisfy :: (Char -> Bool) -> Parser Char 
satisfy p [] = []
satisfy p (h:t) = if p h 
                  then [(h,t)]
                  else []

token :: [Char] -> String -> [([Char],String)]
token t inp = if take (length t) inp == t
              then [(t, drop(length t) inp)]
              else []

succeed :: a -> String -> [(a,String)]
succeed r inp = [(r,inp)]


-- Combinadores de Parsers ! 

{-
   X -> "While"
   | "For"
-}

(<|>) :: Parser a -> Parser a -> Parser a 
(p <|> q) inp = p inp ++ q inp 

pX = token "While"
    <|> token "For"
    <|> token "while"
    <|> token "for"

{-
   S -> A B 
   A -> epsilon
   | a A 
   b -> b 
   | b B 
-}
{-
(<*>) :: Parser a -> Parser b -> Parser (a,b)
(p <*> q) inp = [ ((r,r'),rst')
                | (r,rst) <- p inp
                , (r',rst') <- q rst
                ]
-}
{-
A -> a b c a
-}
pA :: Parser Char
pA = f <$> symbol 'a' <*> symbol 'b' <*> 
        symbol 'c' <*> symbol 'a'
    where f x y z w = y

(<*>) :: Parser (a->r) -> Parser a -> Parser r
(p <*> q) inp = [ (f r,rst')
                | (f,rst) <- p inp
                , (r,rst') <- q rst
                ]

(<$>) :: (a -> r) -> Parser a -> Parser r 
(f <$> p ) inp = [ (f r, rst)
                |  (r,rst) <- p inp
                ]

{-
    As -> a
    | a A
-}

pAs = f <$> symbol 'a'
    <|> g <$> symbol 'a' <*> pAs
    where f x = 1
          g x y = 1 + y 

{-
    Int -> Sinal Digitos
    Sinal -> '+'
            | '-'
            |
    Digitos -> dig 
            | dig Digitos
-}

pInt = f <$> pSinal <*> pDigitos
    where f x y = x:y

pSinal = symbol '-'
       <|> symbol '+'
       <|> succeed '+'

pDigitos = f <$> (satisfy isDigit)
        <|> g <$> (satisfy isDigit) <*> pDigitos
        where f x = [x]
              g x y = [x] ++ y

