module Generator where
import Test.QuickCheck
import Data.List
import PicoC   

-- Nos generators temos de fazer sempre estes passos:
-- 1º: Declarar a estrutura de dados que nós queremos gerar 
-- 2º: Implementar o gerador dessa mesma estrutura de dados 
-- 3º: Declarar a instância do gerador que implementamos para assim podermos usá-lo posteriormente 
-- 4º: Para executar os geradores temos de realizar o seguinte: sample genEstruturaDados
data Cardinal = North | East | South | West
                deriving Show

genCardinal :: Gen Cardinal
genCardinal = elements [North,East,South,West]

instance Arbitrary Cardinal where
  arbitrary = genCardinal

genDate :: Gen (Int,Int,Int)
genDate = do d <- elements [1..31]
             m <- elements [1..12]
             y <- choose (1900, 2016)
             return (d,m,y)

-- 1.2 Exercícios 
-- 1. 
data Carro = Carro Tipo Marca Matricula NIF CPKm Autonomia
                deriving Show

data Tipo  = Combustao
            | Eletrico
            | Hibrido
              deriving Show

type Marca      = String
type Matricula  = String
type NIF        = String    -- NIF Proprietario
type CPKm       = Float     -- Consumo por Km
type Autonomia  = Int

-- a)
-- De acordo com as estatísticas do ACP, atualmente 70% dos automóveis usam motores a combustão,
-- 25% são hibridos e apenas 5% são elétricos.
genTipo :: Gen Tipo
genTipo = frequency [(70,return Combustao),(25,return Hibrido),(5,return Eletrico)]
-- b)
-- O consumo por quilómetro (CPKm) é dado em euros e é um valor entre 0.1 e 2 euros.
genCPKm :: Gen CPKm
genCPKm = elements (enumFromThenTo 0.1 0.2 2)
-- c)
genAutonomia :: Gen Autonomia
genAutonomia = choose(350,500)
-- d)
genMarca :: Gen Marca 
genMarca = frequency [(120,return "Renault"),(87,return "Citroen"), (57,return "Audi")
                      ,(2,return "Porsche"),(1,return "Ferrari")]
-- e)
genMatricula :: Gen Matricula
genMatricula = do 
    letra1 <- elements['A'..'Z']
    letra2 <- elements['A'..'Z']
    numero1 <- elements['0'..'9']
    numero2 <- elements['0'..'9']
    numero3 <- elements['0'..'9']
    numero4 <- elements['0'..'9']
    return $ [letra1, letra2, '-',numero1,numero2, '-',numero3,numero4]

-- f)
-- Aqui temos de utilizar os geradores criados anterirormente, além de termos de criar um gerador para o NIF escolhido
genNIF :: [NIF] -> Gen NIF
genNIF l = elements l

genCarro :: [NIF] -> Gen Carro
genCarro l = do
    tipo <- genTipo
    marca <- genMarca
    matricula <- genMatricula
    nif <- (genNIF l)
    cpkm <- genCPKm
    autonomia <- genAutonomia
    return (Carro tipo marca matricula nif cpkm autonomia)

l :: [NIF]
l = ["1111111111","222222222"]

instance Arbitrary Carro where
  arbitrary = genCarro l 

-- 2.
data Student = Student Nome Numero TipoAluno Notas 
                deriving Show 

type Nome = String 
type Numero = String 
data TipoAluno = Normal
                | Militar 
                | Trabalhador
                deriving Show 
type Notas = [Int]

genNome :: Gen Nome
genNome = frequency [(90,return "Ana Cacho Paulo"),(87,return "Jorge Antunes"), (57,return "Gonçalo Martins dos Santos")
                      ,(70,return "Miguel dos Santos da Cunha"),(60,return "Antonieta Maria Andrade da Costa")]

genNumero :: Gen String 
genNumero = do 
            num1 <- elements['0'..'9']
            num2 <- elements['0'..'9']
            num3 <- elements['0'..'9']
            num4 <- elements['0'..'9']
            num5 <- elements['0'..'9']
            return $ ['P','G',num1,num2,num3,num4,num5]

genTipoAluno :: Gen TipoAluno
genTipoAluno = frequency [(80,return Normal),(5,return Militar), (15,return Trabalhador)]

genNotas :: Gen Notas 
genNotas = do 
            num1 <- elements[0..20]
            num2 <- elements[0..20]
            num3 <- elements[0..20]
            num4 <- elements[0..20]
            num5 <- elements[0..20]
            num6 <- elements[0..20]
            return [num1,num2,num3,num4,num5,num6]

genStudent :: Gen Student
genStudent = do 
            nome <- genNome
            numero <- genNumero
            tipoAluno <- genTipoAluno
            notas <- genNotas 
            return (Student nome numero tipoAluno notas)

instance Arbitrary Student where
  arbitrary = genStudent
-- 3.
data MYEXPR = Mais MYEXPR MYEXPR
            | Vezes MYEXPR MYEXPR
            | Constante Float
            | Variavel String
              deriving Show
-- a)
genExpr :: Int -> Gen MYEXPR 
genExpr n = if n == 0 
            then 
                do 
                expr1Mais <- genExpr 1 
                expr2Mais <- genExpr 1
                expr1vezes <- genExpr 1 
                expr2vezes <- genExpr 1 
                frequency [(80,return (Mais expr1Mais expr2Mais)),(20,return (Vezes expr1vezes expr1vezes))]
            else 
                do 
                numero <- genFloat
                expr1Mais <- genExpr 1 
                expr2Mais <- genExpr 1
                expr1vezes <- genExpr 1 
                expr2vezes <- genExpr 1 
                frequency [(50,return (Constante numero)),(25,return (Mais expr1Mais expr2Mais)),(25,return (Vezes expr1vezes expr1vezes))]
            

genFloat :: Gen Float 
genFloat = elements (enumFromThenTo 0.1 0.2 10)

instance Arbitrary MYEXPR where
  arbitrary = sized genExpr
-- b)
genExpr' :: Int -> Int -> Gen MYEXPR 
genExpr' n t= if n == 0 
            then 
                do 
                expr1Mais <- genExpr' 1 (t-1)
                expr2Mais <- genExpr' 1 (t-1)
                expr1vezes <- genExpr' 1 (t-1)
                expr2vezes <- genExpr' 1 (t-1)
                frequency [(80,return (Mais expr1Mais expr2Mais)),(20,return (Vezes expr1vezes expr1vezes))]
            else 
                do 
                numero <- genFloat
                expr1Mais <- genExpr' 1 (t-1)
                expr2Mais <- genExpr' 1 (t-1)
                expr1vezes <- genExpr' 1 (t-1)
                expr2vezes <- genExpr' 1 (t-1)
                frequency [(50,return (Constante numero)),(25,return (Mais expr1Mais expr2Mais)),(25,return (Vezes expr1vezes expr1vezes))]
{--            
instance Arbitrary MYEXPR where
  arbitrary = sized (genExpr' 0) 
--}

-- c) 
genExpr'' :: [String] -> Gen MYEXPR
genExpr'' l = if (length l /= 0) 
            then 
                do 
                expr1Mais <- genExpr'' (tail l)
                expr2Mais <- genExpr'' (tail l)
                expr1vezes <- genExpr'' (tail l) 
                expr2vezes <- genExpr'' (tail l) 
                numero <- genFloat 
                str <- genString l
                frequency [(80,return (Mais expr1Mais expr2Mais)),(10,return (Vezes expr1vezes expr1vezes)),(5, return (Constante numero)),(5, return (Variavel str))]
            else 
                do
                expr1Mais <- genExpr 1
                expr2Mais <- genExpr 1
                expr1vezes <- genExpr 1
                expr2vezes <- genExpr 1 
                numero <- genFloat 
                frequency [(80,return (Mais expr1Mais expr2Mais)),(10,return (Vezes expr1vezes expr1vezes)),(5, return (Constante numero))]



genString :: [String] -> Gen String 
genString l = elements l

-- 4.
data BST = Empty
           | Node BST Int BST
              deriving Show
-- a)
genBST :: [Int] -> Gen BST 
genBST [] = return Empty
genBST (x:xs) = do 
                bstLeft <- genBST (take (div(length xs) 2) xs)  
                bstRight <- genBST (drop (div(length xs) 2) xs) 
                return (Node bstLeft x bstRight)

-- b) 
-- i. 
size :: BST -> Int
size Empty = 0
size (Node left _ right) = 1 + (size left) + (size right)

-- ii.
height:: BST -> Int
height Empty = 0
height (Node left _ right) = 1 + max (size left)  (size right)

-- iii.
maxBST :: BST -> Int
maxBST (Node Empty x Empty) = x 
maxBST (Node l x r) = maxBST r

-- iv.
inorder :: BST -> [Int]
inorder Empty = []
inorder (Node l x r) = inorder l ++ [x] ++ inorder r

-- v.
isSorted :: Ord a => [a] -> Bool
isSorted xs = xs == sort xs

ordered :: BST -> Bool
ordered Empty = True 
ordered (Node left x right) = isSorted (inorder (Node left x right)) 

-- vi. 
balanced :: BST -> Bool
balanced Empty = True
balanced (Node l x r) = if abs(height l - height r) <= 1 then balanced l && balanced r else False 

-- vii.
foldT :: (Int -> a -> a -> a) -> a -> BST -> a
foldT _ acc Empty = acc
foldT f acc (Node left val right) = f val (foldT f (foldT f acc left) left) (foldT f (foldT f acc right) right)


{-
genConst :: Gen Expr
genConst = do
        x <- arbitrary
        return $ Const x

genExpr :: Int -> Gen Expr
genExpr n = frequency [(100, genConst), 
                       (80 * n, do
                            x1 <- genExpr (div n 2)
                            x2 <- genExpr (div n 2)
                            return $ Add x1 x2),
                       (20 * n, do
                            x1 <- genExpr (div n 2)
                            x2 <- genExpr (div n 2)
                            return $ Mul x1 x2)]

instance Arbitrary Expr where
    arbitrary = sized genExpr
-}