import Test.QuickCheck
import Data.List
import GeradorAndQuickCheck
-- Para testar as funções é : sample genDia
-- Gera números de 1 a 31 
genDia = elements [1..31]

-- Ficha de exercícios 
-- Parte 1.2 
-- Exercício 1 

data Carro = Carro Tipo Marca Matricula NIF CPKm Autonomia
            deriving Show

data Tipo  = Combustao
            | Eletrico
            | Hibrido
                deriving Show 

type Marca      = String
type Matricula  = String
type NIF        = String -- NIF Proprietario
type CPKm       = Float -- Consumo por Km
type Autonomia  = Int

genTipo :: Gen Tipo
genTipo =  frequency [(70,return Combustao),(5,return Eletrico),(25,return Hibrido)]

genCPKm :: Gen Float
genCPKm = choose(0.1,2.0)

genAutonomia :: Gen Int
genAutonomia = choose(300,700)

genMarca :: Gen String 
genMarca = frequency [(12,return "Renault"),(85,return "Mercedes")
                      ,(120,return "Porsche"),(4,return "Ferrari")]

genMatricula :: Gen String
genMatricula = do 
    char1 <- elements ['A'..'Z']
    char2 <- elements ['A'..'Z']
    num1 <- elements ['0'..'9']
    num2 <- elements ['0'..'9']
    num3 <- elements ['0'..'9']
    num4 <- elements ['0'..'9']
    return $ [char1, char2, '-',num1,num2, '-',num3,num4]

genNIF :: [NIF] -> Gen String
genNIF l = elements l 

genCarro :: [NIF] -> Gen Carro
genCarro l = do 
    tipo <- (genTipo) 
    marca <- (genMarca) 
    matricula <- (genMatricula) 
    nif <- (genNIF l) 
    cPKm <- (genCPKm) 
    autonomia <- (genAutonomia)
    return (Carro tipo marca matricula nif cPKm autonomia)

-- Exercício 2 
data Student = Student Nome Numero Tipo' Notas 
             deriving Show 

data Tipo' = Normal 
          | Trabalhador 
          | Militar 
          deriving Show 

type Nome = String 
type Numero = Int 
type Notas = [Int]

genTipo' :: Gen Tipo'
genTipo' =  frequency [(80,return Normal),(15,return Trabalhador),(5,return Militar)]

genNome :: Gen String
genNome = elements ["Nuno","Patricia","Andre","Maria","Ana","Joao"]

genNumero :: Gen Int
genNumero = elements[0..100]

genNotas :: Gen [Int]
genNotas = shuffle [0..20]

genStudent :: Gen Student
genStudent = do 
    nome <- genNome
    numero <- genNumero
    tipo <- genTipo'
    notas <- genNotas
    return (Student nome numero tipo notas)

-- Ficha : QuickCheck - Property Testing
-- Exercicio 1 
mulL :: Num a => [a] -> a
mulL [] = 0
mulL (h : t) = h * mulL t

-- a)
prop_reverse :: Num a => Eq a => [a] -> Bool
prop_reverse l = (mulL(reverse l) == mulL l) 

-- b)
prop_equal :: [Int] -> Property
prop_equal l =length l == 1 ==> (mulL l == head l)

-- c)
prop_product :: Num a => Eq a => [a] -> Bool
prop_product l = ((mulL l) == product l)
-- Exercicio 2 
data BST = Empty 
        | Node BST Int BST deriving (Show, Read, Eq)
-- Cria uma BST simples
fromList :: [Int] -> BST
fromList [] = Empty
fromList (x:xs) = Node Empty x (fromList xs)

-- Verifica se a árvore é uma BST
isBST :: BST -> Bool
isBST Empty = True
isBST (Node l x r) = isBST l && isBST r
                && maybeBigger (Just x) (maybeMax l)
                && maybeBigger (maybeMin r) (Just x)
    where maybeBigger _ Nothing = True
          maybeBigger Nothing _ = True
          maybeBigger (Just x) (Just y) = x >= y
          maybeMax Empty = Nothing
          maybeMax (Node _ x Empty) = Just x
          maybeMax (Node _ _ r) = maybeMax r
          maybeMin Empty = Nothing
          maybeMin (Node Empty x _) = Just x
          maybeMin (Node l _ _) = maybeMin l
-- a)
genBST :: Int -> Gen BST 
genBST size = if size == 0 
                then return (Empty)
                else do
                      l <- sort <$> vectorOf size arbitrary
                      genFullBST l

genFullBST :: [Int] -> Gen BST
genFullBST l = return (Node Empty (head l) (fromList (tail l)))

instance Arbitrary BST where 
    arbitrary = sized genBST
--b)

prop_isBST :: BST -> Bool 
prop_isBST bst = (isBST bst)

--c)

prop_balanced :: BST -> Bool
prop_balanced Empty = True
prop_balanced (Node left _ right) =
  abs (height left - height right) <= 1 && prop_balanced left && prop_balanced right
  where
    height Empty = 0
    height (Node left _ right) = 1 + max (height left) (height right)

