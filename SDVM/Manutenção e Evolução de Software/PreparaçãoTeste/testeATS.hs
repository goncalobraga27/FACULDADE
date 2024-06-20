module TesteATS where 

import Data.Char
import Data.Maybe
import Data.Data
import Debug.Trace
import Test.QuickCheck
import Test.QuickCheck.Function


import Data.Generics.Zipper

import Library.Ztrategic
import Library.StrategicData (StrategicData)

instance StrategicData Int
-- instance StrategicData PicoXML
instance StrategicData a => StrategicData [a]

-- Pergunta 2.
data Turma = Turma [Aluno]
            deriving Show 

data Aluno = Aluno Nome [Nota]
            deriving Show 

type Nome = String 

type Nota = Int 

-- Definição dos geradores 
nomeValidos = ["Ana Cacho Paulo","Mi Jaime","Patricia Pereira","Goncalo Braga","Goncalo Santos","Jose Joao","Antonio Maria"]

geradorNome :: Gen Nome 
geradorNome = elements nomeValidos

geradorNota :: Int -> Gen Nota 
geradorNota n = frequency[(70*n,elements [10..20]),(30*n,elements[0..9])]

geradorListaNotas :: Int -> Gen [Nota]
geradorListaNotas n = sequence [geradorNota x | x <- [1..n]]

geradorAluno :: Int -> Gen Aluno 
geradorAluno n = do 
                 nome <- geradorNome
                 listaNotas <- geradorListaNotas n
                 return $ Aluno nome listaNotas

geradorListaAlunos :: Int -> Gen [Aluno]
geradorListaAlunos n = if (n < 30) then sequence [geradorAluno n | x <- [1..n]] else return []

genTurma :: Int -> Gen Turma 
genTurma n = do 
            alunos <- geradorListaAlunos n 
            return $ Turma alunos 


instance Arbitrary Turma where
  arbitrary = (sized genTurma)

-- Pergunta 3. 
-- Propriedade que testa se ao inserirmos um aluno, com a função addAluno, ele se encontra posteriormente na turma, 
-- utilizando a função containsAluno 

prop_AlunoExists :: Aluno -> Turma -> Bool
prop_AlunoExists (Aluno n lNotas) t = containsAluno(addAluno(t,(Aluno n lNotas)),n) 

-- Propriedade que testa se ao inserirmos um aluno, com a função addAluno, ele é o melhor aluno da turma,
-- utilizando a função melhorAluno 

prop_IstheBestAluno :: Aluno -> Turma -> Bool
prop_IstheBestAluno a t = melhorAluno(addAluno(t,a)) == a

-- Pergunta 4.
-- Nesta pergunta em haskell, uma mutação no código, dá origem a um código diferente e mutado, tendo assim duas hipoteses de acontecerem, qua são:
-- O parser em haskell não consegue criar a ast correspondente do código;
-- A árvore gerada pelo parser possui erros gerados pela mutação, que posteriormente não consegue ser executada;
