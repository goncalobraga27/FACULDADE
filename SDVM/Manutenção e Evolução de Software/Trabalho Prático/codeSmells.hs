-- Neste ficheiro vamos fazer alguns refactoring a code smells que possam existir no PicoC
-- Para tal, iremos utilizar a programção estratégica para o fazer 

import Prelude hiding ((<*>),(<$>))
import Data.Char
import Data.Maybe
import Data.Generics.Zipper
import Data.Data
import Parser
import PicoC
import Library.Ztrategic
import Library.StrategicData (StrategicData)

instance StrategicData Int
instance StrategicData PicoC
instance StrategicData a => StrategicData [a]

-- 1º Identificar possíveis code smells no PicoC 
-- Code Smells:
-- x*1
-- x+0
-- -(- 1)
-- if (not(...)) else 
-- 2º Resolver estes code smells fazendo para isso um refactoring do código 

-- Code Smell (x*1)
examplePicoC1 = "{int margem = 15; if (margem > 30) then {margem = 4 * 1 * 1;} else {margem = 0;}}"
astCodeSmell1 = givePicoC(pPicoC(examplePicoC1))

codeSmellSolution1 :: Exp -> Maybe Exp
codeSmellSolution1 (Mult e1 (Const 1)) = Just e1 
codeSmellSolution1 (Mult (Const 1) e1) = Just e1
codeSmellSolution1 _ = Nothing 

refactoringCodeSmell1 :: PicoC -> PicoC
refactoringCodeSmell1 p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` codeSmellSolution1  -- Nesta travessia faz a função: codeSmellSolution1
    in fromZipper newP

refactoringAst1 = PicoC [Atrib "int margem" (Const 15),ITE (More (Var "margem") (Const 30)) [Atrib "margem" (Const 4)] [Atrib "margem" (Const 0)]]

-- Code Smell (x+0)
examplePicoC2 = "{int margem = 15; if (margem > 30) then {margem = 4 + 0 + 0;} else {margem = 0;}}"
astCodeSmell2 = givePicoC(pPicoC(examplePicoC2))

    codeSmellSolution2 :: Exp -> Maybe Exp
    codeSmellSolution2 (Add e1 (Const 0)) = Just e1 
    codeSmellSolution2 (Add (Const 0) e1) = Just e1
    codeSmellSolution2 _ = Nothing 

refactoringCodeSmell2 :: PicoC -> PicoC
refactoringCodeSmell2 p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` codeSmellSolution2  -- Nesta travessia faz a função: codeSmellSolution1
    in fromZipper newP

refactoringAst2 = PicoC [Atrib "int margem" (Const 15),ITE (More (Var "margem") (Const 30)) [Atrib "margem" (Const 4)] [Atrib "margem" (Const 0)]]

-- Code Smell (-(-1))
examplePicoC3 = "{int margem = 15; if (margem > 30) then {margem = ?(?4);} else {margem = ?(?0);}}"
astCodeSmell3 = givePicoC(pPicoC(examplePicoC3))

codeSmellSolution3 :: Exp -> Maybe Exp
codeSmellSolution3 (Neg (Neg e1)) = Just e1 
codeSmellSolution3 _ = Nothing 

refactoringCodeSmell3 :: PicoC -> PicoC
refactoringCodeSmell3 p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` codeSmellSolution3  -- Nesta travessia faz a função: codeSmellSolution1
    in fromZipper newP

refactoringAst3 = PicoC [Atrib "int margem" (Const 15),ITE (More (Var "margem") (Const 30)) [Atrib "margem" (Const 4)] [Atrib "margem" (Const 0)]]

-- Code Smell (if (not(...)) else ...)
examplePicoC4 = "{int margem = 15; if (? margem) then {margem = ?(?4);} else {margem = ?(?0);}}"
astCodeSmell4 = givePicoC(pPicoC(examplePicoC4))

codeSmellSolution4 :: Inst -> Maybe Inst
codeSmellSolution4 (ITE (Neg cond) e1 e2) = Just (ITE cond e2 e1)
codeSmellSolution4 _ = Nothing 

refactoringCodeSmell4 :: PicoC -> PicoC
refactoringCodeSmell4 p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` codeSmellSolution4  -- Nesta travessia faz a função: codeSmellSolution1
    in fromZipper newP

refactoringAst4 = PicoC [Atrib "int margem" (Const 15),ITE (Var "margem") [Atrib "margem" (Neg (Neg (Const 0)))] [Atrib "margem" (Neg (Neg (Const 4)))]]

-- Estes são alguns code smells e alguns refactoring possíveis de serem feitos no código do PicoC
