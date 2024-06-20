module Quickcheck where
import Test.QuickCheck
import Test.QuickCheck.Function
import Data.List
import PicoC   

-- No quickcheck faz-se sempre estes passos:
-- 1º : Implementa-se a função que se quer testar
-- 2º : Implementa-se a propriedade que se quer testar a função, isto é, aquilo que queremos ver se a função possui, nomeadamente certas prop
-- 3º : Executar os testes às propriedades com : quickCheck prop_AquiloQueQueremosTestar
reverse' :: [int] -> [int]
reverse' [] = []
reverse' (x:xs) = reverse' xs ++ [x]

-- Nesta propriedade verificamos se o reverse da l1 mais o reverse da l2 é igual ao reverse' de (l1++l2)
prop_Reverse1 :: Eq int => [int] -> [int] -> Bool
prop_Reverse1 l1 l2 = reverse' (l1 ++ l2) == reverse' l1 ++ reverse' l2 

-- Nesta propriedade verificamos se reverse(reverse l) == l 
prop_Reverse2 :: Eq int => [int] -> Bool
prop_Reverse2 l = reverse'(reverse' l) == l 

-- 2. EXERCÍCIOS 
-- 1. 

mulL :: Num a => [a] -> a
mulL [] = 0
mulL (h : t) = h * mulL t

-- a)
prop_mulL1 :: Num a => Eq a => [a] -> Bool
prop_mulL1 l = mulL l == mulL (reverse l)

-- b) 
prop_mulL2 :: Num a => Eq a => [a] -> Bool
prop_mulL2 [] = 0 == mulL []
prop_mulL2 [x] = x == mulL [x]

-- c)
prop_mulL3 :: Num a => Eq a => [a] -> Bool
prop_mulL3 l = mulL l == product l

-- Assim, conclui-se que a função não está conforme a especificação pretendida 
-- 2. 

data BST = Empty
           | Node BST Int BST
            deriving Show

fromList :: [Int] -> BST
fromList [] = Empty
fromList (x:xs) = Node Empty x (fromList xs)

isBST :: BST -> Bool
isBST Empty = True
isBST (Node l x r) = isBST l && isBST r
                && maybeBigger (Just x) (maybeMax l)
                && maybeBigger (maybeMin r) (Just x)
    where   maybeBigger _ Nothing = True
            maybeBigger Nothing _ = True
            maybeBigger (Just x) (Just y) = x >= y
            maybeMax Empty = Nothing
            maybeMax (Node _ x Empty) = Just x
            maybeMax (Node _ _ r) = maybeMax r
            maybeMin Empty = Nothing
            maybeMin (Node Empty x _) = Just x
            maybeMin (Node l _ _) = maybeMin l

-- a)
genBST' :: Int -> [Int] -> Gen BST
genBST' 0 _= do
            return Empty 
genBST' n l = do
            frequency [(30*n, return Empty),(70*n, return (fromList l))]
{--
instance Arbitrary BST where
  arbitrary = sized genBST
    where
      genBST 0 = return Empty
      genBST n = do
        l <- arbitrary
        genBST' n l
--}
-- b)
prop_BSTvalid :: BST -> Bool 
prop_BSTvalid bst = isBST (bst)

-- i. 
-- Neste exemplo, o que é alterado para o exemplo de cima é o seguinte :
-- Antes da lista ser utilizada na geração das BST ela é ordenada, fazendo com que os seus valores, já sejam inseridos da forma correta
instance Arbitrary BST where
  arbitrary = sized genBST

genBST 0 = return Empty
genBST n = do
        l <- arbitrary
        genBST' n (sort(l))

-- c)

balanced :: BST -> Bool
balanced Empty = True 
balanced (Node left _ right) = abs ((height left) - (height right)) <= 1 && (balanced left) && (balanced right)


height :: BST -> Int
height Empty = 0
height (Node left _ right) = 1 + max (height left) (height right)

prop_isbalanced :: BST -> Bool
prop_isbalanced bst = balanced (bst)

-- i.
-- Assim colocamos a BST balanceadas
fromList' :: [Int] -> BST
fromList' [] = Empty
fromList' (x:xs) =  Node (fromList' (take (div (length(xs)) 2) xs)) x (fromList' (drop (div (length(xs)) 2) xs))
                  
-- d)
-- Tenho de fazer esta alínea quando fizer a ficha de geradores 

-- 3.
find' :: (a -> Bool) -> [a] -> Maybe a
find' f [] = Nothing
find' f (x:xs) = case find' f xs of
        Just k -> Just k
        Nothing -> if f x then Just x else Nothing

-- O erro aqui existente é o seguinte:
-- Como podemos visualizar nesta chamada recursiva da função: find' f xs
-- Ele está a fazer o find do predicado f na cauda da lista, e caso encontre retorna Just k. Mas este valor ao contrário do que é suposto não
-- é o valor mais a esquerda da lista, mas sim o mais a direita, desta forma ele não dá o valor mais a esquerda mas sim o valor compativel mais 
-- a direita;

-- a)
-- Propriedades que a função deve ter:
-- Verificar se a função escolhe o valor que se encontra mais a esquerda possível, algo que não acontece na definição da função em cima 
prop_xMoreInLeft :: Eq a => (a -> Bool) -> [a] -> Bool
prop_xMoreInLeft f (x:xs) = if ((find' f (xs)) == Just x) then False else True

-- b)
find'' :: (a -> Bool) -> [a] -> Maybe a
find'' f [] = Nothing
find'' f (x:xs) = case f x of
        True -> Just x
        False -> find'' f xs 

-- c)
prop_find_equivalent :: Eq a => Fun a Bool -> [a] -> Bool
prop_find_equivalent f lst = (find p lst) == (find' p lst)
    where p = applyFun f

-- 4. 
prop_f1 :: [a] -> Bool
prop_f1 l1 = null' (f l1 []) && null' (f [] l1)

prop_f2 :: [a] -> [b] -> Bool
prop_f2 l1 l2 = length (f l1 l2) == min (length l1) (length l2)

prop_f3_1, prop_f3_2 :: (Eq a, Eq b) => [a] -> [b] -> Property
prop_f3_1 l1 l2 = length l1 < length l2 ==> l1 == map fst (f l1 l2)
prop_f3_2 l1 l2 = length l1 > length l2 ==> l2 == map snd (f l1 l2)

null' :: [a] -> Bool 
null' [] = True
null' _ = False 

-- a)
-- A função f é esta:
f :: [a] -> [b] -> [(a,b)]
f l1 [] = []
f [] l2 = []
f l1 l2 = (head l1,head l2): f (tail l1) (tail l2)

-- b)
prop_isEqual ::  (Eq a, Eq b) => [a] -> [b] -> Bool
prop_isEqual l1 l2 = ((f l1 l2) == (zip l1 l2))

-- 5. 
sorted :: Ord a => [a] -> Bool
sorted l = and (zipWith (<=) l (tail l))

insert' :: Ord a => a -> [a] -> [a]
insert' x [] = [x]
insert' x (y:ys)
    | x<y = x:y:ys
    | otherwise = y:insert' x ys

-- a)
prop_ins_ord :: Int -> [Int] -> Property
prop_ins_ord i l = sorted l ==> sorted (insert' i l)

-- Neste caso obtivemos isto:
-- quickCheck prop_ins_ord 
-- *** Gave up! Passed only 83 tests; 1000 discarded tests.
-- Com isto chegamos a duas conclusões:
-- Ou as listas usadas como input não estão ordenadas
-- Ou a inserção de um elemento numa lista não está a ser realizada respeitando a ordenação da lista 

-- b)
-- Nesta questão é só adicionar o seguinte : collect (length l) $, ao anteriormente desenvolvido 
prop_ins_ord' :: Int -> [Int] -> Property
prop_ins_ord' i l = collect (length l) $
                   sorted l ==> sorted (insert' i l)

-- c)
prop_ins_ord_A :: Int -> Property
prop_ins_ord_A i = forAll (orderedList :: Gen [Int]) $ \l ->
                   sorted l ==> sorted (insert' i l)