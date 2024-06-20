import GeradorAndQuickCheck
import Test.QuickCheck
import Data.List
import PicoC

type Inputs = [(String, Int)]

programa1 = (PicoC [Atrib "c" (Add (Var "a") (Var "d")),Atrib "b" (Add (Var "c") (Const 1))])
programa2 = (PicoC [Atrib "c" (Add (Var "a") (Var "d")),Atrib "b" (Add (Var "c") (Const 1)),Atrib "e" (Add (Var "c")(Var "b")),Atrib "g" (Mult (Var "e") (Var "b"))])
programa3 = (PicoC [Atrib "c" (Add (Var "a") (Var "d")),Atrib "b" (Add (Var "c") (Const 1)),Atrib "e" (Add (Var "c")(Var "b")),Atrib "g" (Mult (Var "e") (Var "c"))])

inputs1_programa1 :: Inputs
inputs1_programa1 = [("a",3),("d",2)]  -- Resultado esperado para o "b" no programa1 : 6

inputs2_programa1 :: Inputs
inputs2_programa1 = [("a",1),("d",1)]  -- Resultado esperado para o "b" no programa1 : 3

inputs3_programa1 :: Inputs
inputs3_programa1 = [("a",5),("d",5)]  -- Resultado esperado para o "b" no programa1 : 11

inputs1_programa2 :: Inputs
inputs1_programa2 = [("a",1),("d",1)]  -- Resultado esperado para o "g" no programa2 : 15

inputs2_programa2 :: Inputs
inputs2_programa2 = [("a",2),("d",2)]  -- Resultado esperado para o "g" no programa2 : 45

inputs3_programa2 :: Inputs
inputs3_programa2 = [("a",3),("d",3)]  -- Resultado esperado para o "g" no programa2 : 91

inputs1_programa3 :: Inputs
inputs1_programa3 = [("a",1),("d",1)]  -- Resultado esperado para o "g" no programa2 : 10

inputs2_programa3 :: Inputs
inputs2_programa3 = [("a",2),("d",2)]  -- Resultado esperado para o "g" no programa2 : 36

inputs3_programa3 :: Inputs
inputs3_programa3 = [("a",3),("d",3)]  -- Resultado esperado para o "g" no programa2 : 78

-- Enunciado do Trabalho Prático : Exercício 1 
evaluate :: PicoC -> Inputs -> Int
evaluate (PicoC insts) inputs = fst(execInsts insts inputs)

-- Esta função fornece todos os valores finais das variáveis utilizadas na linguagem 
evaluate' :: PicoC -> Inputs -> Inputs 
evaluate' (PicoC insts) inputs = snd(execInsts insts inputs)



execInsts :: [Inst] -> Inputs -> (Int, Inputs)
execInsts [] inputs = error "Nenhuma instrução para executar"
execInsts [inst] inputs = executeInst inst inputs
execInsts (inst:insts) inputs =
    let (result, newInputs) = executeInst inst inputs
    in execInsts insts newInputs


executeInst :: Inst -> Inputs -> (Int, Inputs)
executeInst (Atrib var exp) inputs =
    case lookup var inputs of
        Just _ -> error $ "Variável " ++ var ++ " já atribuída com valor " ++ show (evalExp (Var var) inputs)
        Nothing -> (evalExp exp inputs, (var, evalExp exp inputs) : inputs)
executeInst (While exp bloco) inputs = loop 0 inputs
  where
    loop acc inputs' =
        if evalExp exp inputs' /= 0
            then let (result, newInputs) = execInsts bloco inputs'
                 in loop result newInputs
            else (acc, inputs')
executeInst (ITE exp bloco1 bloco2) inputs =
    if evalExp exp inputs /= 0
        then execInsts bloco1 inputs
        else execInsts bloco2 inputs
executeInst (Comment _ _) inputs = error "Instrução de comentário não é executável"



evalExp :: Exp -> Inputs -> Int
evalExp (Const val) _ = val
evalExp (Var var) inputs = case lookup var inputs of
    Just val -> val
    Nothing -> error $ "Variável " ++ var ++ " não encontrada"
evalExp (Add exp1 exp2) inputs = evalExp exp1 inputs + evalExp exp2 inputs
evalExp (Mult exp1 exp2) inputs = evalExp exp1 inputs * evalExp exp2 inputs
evalExp (Div exp1 exp2) inputs =
    let divisor = evalExp exp2 inputs
    in if divisor == 0
        then error "Divisão por zero"
        else evalExp exp1 inputs `div` divisor
evalExp (Neg exp) inputs = - evalExp exp inputs
evalExp (Sub exp1 exp2) inputs = evalExp exp1 inputs - evalExp exp2 inputs
evalExp (More exp1 exp2) inputs = boolToInt $ evalExp exp1 inputs > evalExp exp2 inputs
evalExp (Minus exp1 exp2) inputs = boolToInt $ evalExp exp1 inputs < evalExp exp2 inputs
evalExp (NotMore exp1 exp2) inputs = boolToInt $ evalExp exp1 inputs <= evalExp exp2 inputs
evalExp (NotMinus exp1 exp2) inputs = boolToInt $ evalExp exp1 inputs >= evalExp exp2 inputs
evalExp (Equal exp1 exp2) inputs = boolToInt $ evalExp exp1 inputs == evalExp exp2 inputs

boolToInt :: Bool -> Int
boolToInt True = 1
boolToInt False = 0

-- Enunciado do Trabalho Prático : Exercício 2
runTest :: PicoC -> (Inputs, Int) -> Bool
runTest picoC (inputs, expected) = evaluate picoC inputs == expected

-- Enunciado do Trabalho Prático : Exercício 3 
runTestSuite :: PicoC -> [(Inputs, Int)] -> Bool
runTestSuite picoC [h] = runTest picoC h
runTestSuite picoC (h:t) = runTest picoC h && runTestSuite picoC t

-- Enunciado do Trabalho Prático : Exercício 4 

-- Para a execução do exercício 4 fizemos o seguinte:
-- 1ª:
-- Declaramos os seguintes programas:
-- programa1 = (PicoC [Atrib "c" (Add (Var "a") (Var "d")),Atrib "b" (Add (Var "c") (Const 1))])
-- 2ª:
-- Declaramos os seguintes inputs:
-- inputs = [("a",3),("d",2)]
-- 3ª: 
-- Declaramos os valores esperados do programa:
-- listaResultado = [(inputs,6),(inputs,7)]
-- 4ª:
-- Submissão nos testes:
--                  ghci> runTestSuite programa1 listaResultado
--                  False


-- Enunciado do Trabalho Prático : Exercício 5 

-- Cenário no qual inserimos uma mutação no código PicoC - MANUAL 
-- Mutação inserida : Atrib "" (Add (Var "")(Const 7))
programa1_Mutation = (PicoC [Atrib "c" (Add (Var "a") (Var "d")),Atrib "b" (Add (Var "c") (Const 1)),Atrib "" (Add (Var "")(Const 7))])
-- Execução do programa com mutação:
-- Ao executarmos este programa (programa1_Mutation) com o inputs definido anteriormente obtivemos o seguinte:
        --                    ghci> evaluate programa1_Mutation inputs 
        --                    *** Exception: Variável  não encontrada
        --                    CallStack (from HasCallStack):
        --                    error, called at PicoC_LastPhase.hs:55:16 in main:Main

-- Cenário no qual inserimos uma mutação no código PicoC - AUTOMÁTICO
-- Neste código, possuímos a injeção de uma mutação ao código PicoC passado como input  
mutateInst :: Inst -> Inst
mutateInst (Atrib var exp) = Atrib var (Add (Add exp (Const 5)) exp)
mutateInst (While exp bloco) = While exp (map mutateInstInsideBloco bloco)
mutateInst (ITE exp bloco1 bloco2) = ITE (Add exp exp) (map mutateInstInsideBloco bloco1) (map mutateInstInsideBloco bloco2)
mutateInst other = other

mutateInstInsideBloco:: Inst -> Inst
mutateInstInsideBloco (Atrib var exp) = Atrib var (Mult exp (Const 1))
mutateInstInsideBloco other = other

mutatePicoC :: PicoC -> PicoC
mutatePicoC (PicoC insts) = PicoC $ map mutateInst insts

-- Enunciado do Trabalho Prático : Exercício 6 

-- Para a realização deste exercício fizemos o seguinte:

-- 1ª:
-- Execução dos testes com o programa sem mutações :
--       ghci> runTestSuite programa1 [(inputs1,6),(inputs2,3),(inputs3,11)]
--       True

-- 2ª: 
-- Execução dos testes com o programa com mutações :
--      ghci> runTestSuite (mutatePicoC programa1) [(inputs1,6),(inputs2,3),(inputs3,11)]
--      False

-- Enunciado do Trabalho Prático : Exercício 7 

myevaluate :: PicoC -> Inputs -> IO ()
myevaluate (PicoC insts) inputs = mapM_ (executeAndPrintInst inputs) insts

executeAndPrintInst :: Inputs -> Inst -> IO Inputs
executeAndPrintInst inputs (Print text) = putStrLn text >> return inputs
executeAndPrintInst inputs inst = executeInst' inputs inst

executeInst' :: Inputs -> Inst -> IO Inputs 
executeInst' inputs (Atrib var exp) = do
    let value = evalExp exp inputs  -- Avalia a expressão com as variáveis atuais
    let newInputs = (var,value):inputs
    putStrLn $ "Atribuindo " ++ show exp ++ " à variável " ++ var
    print value
    print newInputs
    return newInputs

executeInst' inputs (While exp bloco) = loop 0 inputs
  where
    loop acc inputs' =
        if evalExp exp inputs' /= 0
            then do
                putStrLn $ "Executando um loop while com a condição " ++ show exp
                newInputs <- myexecInsts bloco inputs'
                loop acc newInputs
            else putStrLn "Loop while terminado" >> print acc >> print inputs' >> return inputs'

executeInst' inputs (ITE exp bloco1 bloco2) =
    if evalExp exp inputs /= 0
        then do
            putStrLn $ "Executando uma estrutura if-then-else com a condição " ++ show exp
            newInputs <- myexecInsts bloco1 inputs
            return newInputs
        else do
            putStrLn $ "Executando uma estrutura if-then-else com a condição " ++ show exp
            newInputs <- myexecInsts bloco2 inputs
            return newInputs

executeInst' _ (Comment _ _) = error "Instrução de comentário não é executável"
executeInst' inputs (Print text) = putStrLn text >> return inputs  -- Adicionado para lidar com a instrução Print

myexecInsts :: BlocoC -> Inputs -> IO Inputs
myexecInsts [] inputs = return inputs
myexecInsts (inst:insts) inputs = do
    newInputs <- executeInst' inputs inst
    myexecInsts insts newInputs

-- Enunciado do Trabalho Prático : Exercício 8
-- Para executarmos isto é necessário fazer o seguinte : let progInst = instrumentation programa1
instrumentation :: PicoC -> PicoC
instrumentation (PicoC insts) = PicoC $ concatMap instrumentInst insts

instrumentInst :: Inst -> [Inst]
instrumentInst inst@(Atrib _ _) = [Print $ "Antes da atribuicao: " ++ show inst, inst, Print $ "Depois da atribuicao: " ++ show inst]
instrumentInst inst@(While exp bloco) = [Print $ "Antes do loop while: " ++ show exp] ++ [inst] ++ [Print $ "Depois do loop while: " ++ show exp] ++ [Print ""] ++ concatMap instrumentInst bloco ++ [Print ""]
instrumentInst inst@(ITE exp bloco1 bloco2) = [Print $ "Antes da estrutura if-then-else: " ++ show exp] ++ [inst] ++ [Print $ "Depois da estrutura if-then-else: " ++ show exp] ++ [Print ""] ++ concatMap instrumentInst bloco1 ++ [Print ""] ++ concatMap instrumentInst bloco2 ++ [Print ""]
instrumentInst inst = [Print $ "Antes da instrucao: " ++ show inst, inst, Print $ "Depois da instrucao: " ++ show inst]

-- Enunciado do Trabalho Prático : Exercício 9 

-- InstrumentedTestSuite

instrumentedTestSuite :: PicoC -> [(Inputs, Int)] -> Bool
instrumentedTestSuite programa testes = all (\(inputs, expected) -> evaluate (instrumentation programa) inputs == expected) testes

-- Evaluate com trace 

evaluateWithTrace :: PicoC -> Inputs -> [Inst]
evaluateWithTrace (PicoC insts) inputs = evaluate'' insts inputs []

evaluate'' :: [Inst] -> Inputs -> [Inst] -> [Inst]
evaluate'' [] _ trace = trace
evaluate'' (inst:insts) inputs trace = evaluate'' insts newInputs (trace ++ [inst])
  where
    (_, newInputs) = executeInst inst inputs

-- Função wrapper para simplificar a chamada
evaluateToTrace :: PicoC -> Inputs -> [Inst]
evaluateToTrace programa inputs = evaluateWithTrace programa inputs

