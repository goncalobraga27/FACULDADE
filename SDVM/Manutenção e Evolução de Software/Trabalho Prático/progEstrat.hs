import Parser
import PicoC

import Prelude hiding ((<*>),(<$>))
import Data.Char
import Data.Maybe
import Data.Generics.Zipper
import Data.Data

import Library.Ztrategic
import Library.StrategicData (StrategicData)

instance StrategicData PicoC
instance StrategicData Int
instance StrategicData a => StrategicData [a]

data Foo = Foo deriving Data
data Bar = Bar Int
        | Counter String
        deriving ( Show , Data )

lista :: [Int]
lista = [1..3]

alteraLista :: [ Int ] 
alteraLista =
    let listaZipper      = toZipper lista
        (Just nodoUm)    = down' listaZipper 
        (Just listaDois) = right nodoUm
        (Just nodoDois)  = down' listaDois      
        (Just dois) = (getHole nodoDois) :: Maybe Int 
        nodoDoisAtualizado = setHole (dois + 10) nodoDois
    in
    fromZipper nodoDoisAtualizado

examplePicoC = "int margem = 15; if (margem > 30) {margem = 4 * 23 + 3;} else {margem = 0;}"

-- 1

-- 2.


--------

alteraListaS :: [ Int ] 
alteraListaS =
    let listaZipper      = toZipper lista
        Just listaNova   = applyTP (full_tdTP step) listaZipper
            where step = idTP `adhocTP` alteraDois
    in
    fromZipper listaNova

alteraDois :: Int -> Maybe Int
alteraDois 2 = Just 12
alteraDois x = Just x

etiquetaVars :: PicoC -> PicoC
etiquetaVars p =
    let pZipper = toZipper p
        Just newP = applyTP (full_tdTP step) pZipper
        step = idTP `adhocTP` etiquetaUma `adhocTP` etiquetaAtrib  -- Nesta travessia faz as duas funções ao mesmo tempo: etiquetaUma e etiquetaAtrib
    in fromZipper newP

etiquetaUma :: Exp -> Maybe Exp 
etiquetaUma (Var s) = Just (Var ("v_" ++s))
etiquetaUma e = Just e 

etiquetaAtrib :: Inst -> Maybe Inst
etiquetaAtrib (Atrib s x) = Just (Atrib ("y " ++ s) x)
etiquetaAtrib e = Just e 

etiquetaVars2 :: PicoC -> PicoC 
etiquetaVars2 p =
        let pZipper = toZipper p 
            Just newP = applyTP (full_tdTP step) pZipper
            step = idTP `adhocTP` etiquetaString
        in fromZipper newP
-- Esta função está em loop infinito 
etiquetaString :: String -> Maybe String
etiquetaString s = Just("v_"++s)


-- Exercício 4 
limpaSomas :: PicoC -> PicoC
limpaSomas p =
    let pZipper = toZipper p
        Just newP = applyTP (full_tdTP step) pZipper
        step = idTP `adhocTP` limpaAdd
    in fromZipper newP

limpaAdd :: Exp -> Maybe Exp 
limpaAdd (Add exp1 (Const 0)) = Just exp1
limpaAdd (Add (Const 0) exp2) = Just exp2
limpaAdd e = Just e 

limpaMult :: PicoC -> PicoC
limpaMult p =
    let pZipper = toZipper p
        Just newP = applyTP (full_tdTP step) pZipper
        step = idTP `adhocTP` limpaMultiplicacao
    in fromZipper newP

limpaMultiplicacao :: Exp -> Maybe Exp 
limpaMultiplicacao (Mult exp1 (Const 1)) = Just exp1
limpaMultiplicacao (Mult (Const 1) exp2) = Just exp2
limpaMultiplicacao e = Just e 

-- Exercício 6 
{--
No enunciado diz para simplificar o x+0 em x e x*1 para x, igualmente, sendo x uma expressão aritmética.
Assim existem alguns ponto de falha nas estratégias da pergunta 4, tal como :
Se tivermos (2+0)+0, a estratégia da pergunta 4 não simplifica a expressão, pois teria de ficar da seguinte forma 2;
Se tivermos 2*1*1*45, a estratégia da pergunta 4 não simplifica a expressão, pois teria de ficar da seguinte forma 2*45; 

--}

limpaSomasOpt :: PicoC -> PicoC
limpaSomasOpt p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` limpaAddOpt
    in fromZipper newP

limpaMultOpt :: PicoC -> PicoC
limpaMultOpt p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` limpaMultiplicacaoOpt
    in fromZipper newP

limpaMultiplicacaoOpt :: Exp -> Maybe Exp 
limpaMultiplicacaoOpt (Mult exp1 (Const 1)) = Just exp1
limpaMultiplicacaoOpt (Mult (Const 1) exp2) = Just exp2
limpaMultiplicacaoOpt e = Nothing

limpaAddOpt :: Exp -> Maybe Exp 
limpaAddOpt (Add exp1 (Const 0)) = Just exp1
limpaAddOpt (Add (Const 0) exp2) = Just exp2
limpaAddOpt e = Nothing

-- Exercício 1 
{-- 
Neste exercício, executamos os seguintes comandos para obter a árvore abstrata:
pPicoC "{int margem = 15; if (margem>30) then {margem = 4*23+3;} else {margem = 0;}}"
[(PicoC [Atrib "int margem" (Const 15),ITE (More (Var "margem") (Const 30)) [Atrib "margem" (Add (Mult (Const 4) (Const 23)) (Const 3))] [Atrib "margem" (Const 0)]],""),(PicoC [Atrib "int margem" (Const 15),ITE (Minus (Var "margem") (Const 30)) [Atrib "margem" (Add (Mult (Const 4) (Const 23)) (Const 3))] [Atrib "margem" (Const 0)]],"")]

E de seguida, para obter apenas a árvore abstrata fizemos:
givePicoC [(PicoC [Atrib "int margem" (Const 15),ITE (More (Var "margem") (Const 30)) [Atrib "margem" (Add (Mult (Const 4) (Const 23)) (Const 3))] [Atrib "margem" (Const 0)]],""),(PicoC [Atrib "int margem" (Const 15),ITE (Minus (Var "margem") (Const 30)) [Atrib "margem" (Add (Mult (Const 4) (Const 23)) (Const 3))] [Atrib "margem" (Const 0)]],"")]
PicoC [Atrib "int margem" (Const 15),ITE (More (Var "margem") (Const 30)) [Atrib "margem" (Add (Mult (Const 4) (Const 23)) (Const 3))] [Atrib "margem" (Const 0)]]

Obtendo assim a árvore abstrata 
--}

-- Exercício 2
{-- 
Neste exercício apenas é colocar o deriving (Data,Show) nos dataType do parser PicoC
--}
---------------------------------------------- CODE SMELLS -------------------------------------

-- Refactoring
{-- 
Podemos mudar este tipo de expressão : Neg(Neg(Exp)) -> Exp
--}

limpaDoubleNegOpt :: PicoC -> PicoC
limpaDoubleNegOpt p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` limpaDuplaNegOpt
    in fromZipper newP

limpaDuplaNegOpt :: Exp -> Maybe Exp 
limpaDuplaNegOpt (Neg (Neg (exp1))) = Just exp1
limpaDuplaNegOpt e = Nothing


{-- 
Trocamos as condições do if se a ccondição for negativa 
if not(e1) then e2 else e3 -> if e1 then e3 else e2
--}
limpaITEOpt :: PicoC -> PicoC
limpaITEOpt p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` limpaIfOpt
    in fromZipper newP

limpaIfOpt :: Inst -> Maybe Inst
limpaIfOpt (ITE (Neg (exp)) bloco1 bloco2) = Just (ITE exp bloco2 bloco1)
limpaIfOpt e = Nothing 

{-- 
Limpa os comentários 
--}
limpaComment :: PicoC -> PicoC
limpaComment p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` limpaComentarios
    in fromZipper newP

limpaComentarios :: Inst -> Maybe Inst
limpaComentarios (Comment sep texto) = Nothing
limpaComentarios (Atrib s x) = Just (Atrib s x)
limpaComentarios (While e b) = Just (While e b)
limpaComentarios (ITE e b1 b2) = Just (ITE e b1 b2)

{-- 
Limpa os Neg(More x y) ou Neg(Minus x y)
--}
limpaNegMoreMinus :: PicoC -> PicoC
limpaNegMoreMinus p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` limpaNeg
    in fromZipper newP

limpaNeg :: Exp -> Maybe Exp
limpaNeg (Neg(More x y)) = Just (Minus x y)
limpaNeg (Neg(Minus x y)) = Just (More x y)
limpaNeg e = Nothing
