module GeradorAndQuickCheck where
import Test.QuickCheck
import Data.List
import PicoC
-- Exercicio 3 
-- a
-- Gerar o tipo de dados Exp 
genExpr :: Int -> Gen Exp
genExpr n =  -- valor nao precisa de ser 100
        frequency[(100,genConst),
                    (8*n, do 
                        x1 <- genExpr (div n 2)
                        x2 <- genExpr (div n 2)
                        return (Add x1 x2)),
                    (2*n, do 
                        x1 <- genExpr (div n 2)
                        x2 <- genExpr (div n 2)
                        return (Mult x1 x2))]
genConst :: Gen Exp  
genConst = do 
        x <- arbitrary
        return (Const x)

instance Arbitrary Exp where 
    arbitrary = sized genExpr

-- Gerar o tipo de dados SeparadorC 
genSeparadorC :: Int -> Gen SeparadorC
genSeparadorC n = do 
                    x1 <- genStringComment (div n 2)
                    return (Sep x1)
genStringComment :: Int -> Gen String 
genStringComment n = frequency [(10,return "teste0"),(7,return "teste1")
                      ,(4,return "teste2"),(2,return "teste3")]

instance Arbitrary SeparadorC where 
    arbitrary = sized genSeparadorC 

-- Gerar o BlocoC 
genBlocoC :: Int -> Int -> Gen [Inst]
genBlocoC x opt = sequence [genInst n opt | n <- [1..x]]


-- Gerar a Inst
genInst :: Int -> Int -> Gen Inst
genInst n op = if op == 1 then 
                        frequency [(10,do 
                            x1 <- genString
                            x2 <- genExpr (div n 2)
                            return (Atrib x1 x2)
                        ),
                        (6,do 
                            x1 <- genExpr (div n 2)
                            x2 <- genBlocoC ((div n 2) +1) 0
                            return (While x1 x2)
                        ),
                        (8,do 
                            x1 <- genExpr ((div n 2) +1)
                            x2 <- genBlocoC ((div n 2) +1) 0
                            x3 <- genBlocoC ((div n 2) +1) 0
                            return (ITE x1 x2 x3)
                        ),
                        (2,do 
                            x1 <- genSeparadorC (div n 2)
                            x2 <- genStringComment (div n 2)
                            return (Comment x1 x2)
                        )
                        ]
                    else 
                        frequency [(10,do 
                            x1 <- genString
                            x2 <- genExpr (div n 2) 
                            return (Atrib x1 x2)
                        ),
                        (6,do 
                            x1 <- genExpr (div n 2)
                            x2 <- genBlocoC ((div n 2) +1) 0
                            return (While x1 x2)
                        ),
                        (8,do 
                            x1 <- genExpr ((div n 2) +1)
                            x2 <- genBlocoC ((div n 2) +1) 0
                            x3 <- genBlocoC ((div n 2) +1) 0
                            return (ITE x1 x2 x3)
                        )
                        ]
instance Arbitrary Inst where 
    arbitrary = sized (\n -> genInst n n)

-- Gerar String random
genString :: Gen String
genString = elements fixedVariables

-- Lista de variáveis disponiveis para o código
fixedVariables :: [String]
fixedVariables = ["x", "y", "z", "w", "v"]

-- Gerar PicoC 
genPicoC :: Int -> Gen PicoC
genPicoC 0 = return (PicoC [])
genPicoC n = do
        insts <- genBlocoC n 1
        return (PicoC insts)
   

instance Arbitrary PicoC where 
    arbitrary = sized genPicoC



-- Propriedade da linguagem
prop_Parser_Unparse :: PicoC -> Bool
prop_Parser_Unparse ast = givePicoC(pPicoC(unParser ast)) == ast