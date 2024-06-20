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

-- 2. Exercícios 
examplePicoC = "{int margem = 15; if (margem > 30) then {margem = 4 * 23 + 3;} else {margem = 0;}}"

-- 1.
-- Para que o parser gere a árvore abstrata temos de fazer o seguinte:
-- 1º Fazer o parser da linguagem, utilizando a função pPicoC definida no PicoC.hs
-- 2º Temos de invocar uma função auxiliar para extrair a AST da linguagem 

ast = givePicoC(pPicoC(examplePicoC))

-- 2. 
-- Nesta pergunta apenas é necessário alterar o deriving, acrescentando o Data

----------------- PROGRAMAÇÃO ESTRATÉGICA -------------------------------------
alteraListaS :: [Int] ->[Int] 
alteraListaS lista =
    let listaZipper      = toZipper lista
        Just listaNova   = applyTP (full_tdTP step) listaZipper
            where step = idTP `adhocTP` alteraDois
    in
    fromZipper listaNova

alteraDois :: Int -> Maybe Int
alteraDois 2 = Just 12
alteraDois x = Just x
-- 1.
-- Para adequar o código PicoC á programação estratégica temos de fazer o seguinte:
-- instance StrategicData PicoC
-- Isto faz com que consigamos criar uma instância do StrategicData, utilizado na programação estratégica no PicoC

-- 2.
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

-- 3.
-- full_buTP
etiquetaVars' :: PicoC -> PicoC
etiquetaVars' p =
    let pZipper = toZipper p
        Just newP = applyTP (full_buTP step) pZipper
        step = idTP `adhocTP` etiquetaUma `adhocTP` etiquetaAtrib  -- Nesta travessia faz as duas funções ao mesmo tempo: etiquetaUma e etiquetaAtrib
    in fromZipper newP
-- once_tdTP
etiquetaVars'' :: PicoC -> PicoC
etiquetaVars'' p =
    let pZipper = toZipper p
        Just newP = applyTP (once_tdTP step) pZipper
        step = idTP `adhocTP` etiquetaUma `adhocTP` etiquetaAtrib  -- Nesta travessia faz as duas funções ao mesmo tempo: etiquetaUma e etiquetaAtrib
    in fromZipper newP
-- once_buTP
etiquetaVars''' :: PicoC -> PicoC
etiquetaVars''' p =
    let pZipper = toZipper p
        Just newP = applyTP (once_buTP step) pZipper
        step = idTP `adhocTP` etiquetaUma `adhocTP` etiquetaAtrib  -- Nesta travessia faz as duas funções ao mesmo tempo: etiquetaUma e etiquetaAtrib
    in fromZipper newP
-- Neste caso, as estretégias que possuem a estratégia once não fazem nada, pois no primeiro nodo dos zippers não possuem nada para fazer 
-- assim, o etiquetaVars sai desse nodo sem fazer nada.
-- Desta forma, o etiquetaVars não faz nada do PicoC

-- 4.
limpaSomas :: PicoC -> PicoC
limpaSomas p =
    let pZipper = toZipper p
        Just newP = applyTP (full_tdTP step) pZipper
        step = idTP `adhocTP` cleanSomas  -- Nesta travessia faz a função: cleanSomas
    in fromZipper newP

cleanSomas :: Exp -> Maybe Exp 
cleanSomas (Add (Const 0) e1) = Just e1
cleanSomas (Add e1 (Const 0)) = Just e1
cleanSomas e = Just e

limpaMult :: PicoC -> PicoC
limpaMult p =
    let pZipper = toZipper p
        Just newP = applyTP (full_tdTP step) pZipper
        step = idTP `adhocTP` cleanMult  -- Nesta travessia faz a função: cleanSomas
    in fromZipper newP

cleanMult :: Exp -> Maybe Exp 
cleanMult (Mult (Const 1) e1) = Just e1
cleanMult (Mult e1 (Const 1)) = Just e1
cleanMult e = Just e

-- 5.
modificaLimpa :: PicoC -> PicoC
modificaLimpa p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` etiquetaAtrib `adhocTP` cleanSomas `adhocTP` cleanMult  -- Nesta travessia faz as duas funções ao mesmo tempo: etiquetaAtrib
    in fromZipper newP
-- 6.
limpaEverything :: PicoC -> PicoC
limpaEverything p =
    let pZipper = toZipper p
        Just newP = applyTP (innermost step) pZipper
        step = failTP `adhocTP` cleanSomasOpt `adhocTP` cleanMultOpt  -- Nesta travessia faz a função: cleanSomas
    in fromZipper newP

cleanSomasOpt :: Exp -> Maybe Exp 
cleanSomasOpt (Add (Const 0) e1) = Just e1
cleanSomasOpt (Add e1 (Const 0)) = Just e1
cleanSomasOpt e = Nothing

cleanMultOpt :: Exp -> Maybe Exp 
cleanMultOpt (Mult (Const 1) e1) = Just e1
cleanMultOpt (Mult e1 (Const 1)) = Just e1
cleanMultOpt e = Nothing

etiquetaUmaOpt :: Exp -> Maybe Exp 
etiquetaUmaOpt (Var s) = Just (Var ("v_" ++s))
etiquetaUmaOpt e = Nothing

etiquetaAtribOpt :: Inst -> Maybe Inst
etiquetaAtribOpt (Atrib s x) = Just (Atrib ("y " ++ s) x)
etiquetaAtribOpt e = Nothing