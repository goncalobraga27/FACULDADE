module PicoXML where 

import Parser
import Prelude hiding ((<*>),(<$>))
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
instance StrategicData PicoXML
instance StrategicData a => StrategicData [a]

exemploXML = "<pedido><cliente><nome>Maria</nome><telefone>123456789</telefone></cliente><itens><item><produto>Sapatos</produto><quantidade>1</quantidade></item><item><produto>Camisa</produto><quantidade>2</quantidade></item></itens></pedido><pedido><cliente><nome>Antonio</nome><telefone>1111111222222</telefone></cliente><itens><item><produto>Benfica</produto><quantidade>38</quantidade></item><item><produto>Sporting</produto><quantidade>20</quantidade></item></itens></pedido>"

data PicoXML = PicoXML [Content]
            deriving (Data,Show,Eq) 

data Content = Pedido [ItemsTag]
            deriving (Data,Show,Eq) 

data ItemsTag = Itens [SubTags]
              | Cliente [SubContentCliente]
          deriving (Data,Show,Eq) 

data SubTags = Item [SubContentItens]
             deriving (Data,Show,Eq) 

data SubContentCliente = Nome Conteudo
                | Telefone  Conteudo
                deriving (Data,Show,Eq)  

data SubContentItens = Produto  Conteudo
                     | Quantidade Conteudo 
                    deriving (Data,Show,Eq) 
            
data Conteudo = ConteudoTag String 
                deriving (Data,Show,Eq) 


pConteudo = f <$> symbol' '>' <*> zeroOrMore (satisfy isAlphaNum) <*> symbol' '<'
          where f _ x _  = ConteudoTag x 

pSubContentItens = f <$> symbol' '<' <*> token' "produto" <*> pConteudo <*> symbol' '/' <*> token' "produto" <*> symbol' '>'
                <|> g <$> symbol' '<' <*> token' "quantidade" <*> pConteudo <*> symbol' '/' <*> token' "quantidade" <*> symbol' '>'
                where f _ _ y _ _ _ = Produto y 
                      g _ _ y _ _ _ = Quantidade y  

pSubContentCliente = f <$> symbol' '<' <*> token' "nome" <*> pConteudo <*> symbol' '/' <*> token' "nome" <*> symbol' '>'
                <|> g <$> symbol' '<' <*> token' "telefone" <*> pConteudo <*> symbol' '/' <*> token' "telefone" <*> symbol' '>'
                where f _ _ y _ _ _ = Nome y 
                      g _ _ y _ _ _ = Telefone y  

pSubTags = g <$> symbol' '<' <*> token' "item" <*> symbol' '>' <*> (followedBy pSubContentItens (succeed [])) <*> symbol' '<' <*> token' "/item" <*> symbol' '>'
        where g _ _ _ y _ _ _ = Item y 

pItemsTag = f <$> symbol' '<' <*> token' "itens" <*> symbol' '>' <*>  (followedBy pSubTags (succeed [])) <*> symbol' '<' <*> token' "/itens" <*> symbol' '>'
            <|> g <$> symbol' '<' <*> token' "cliente" <*> symbol' '>' <*> (followedBy pSubContentCliente (succeed [])) <*> symbol' '<' <*> token' "/cliente" <*> symbol' '>'
                where f _ _ _ x _ _ _ = Itens x
                      g _ _ _ y _ _ _ = Cliente y

pContent = f <$> symbol' '<' <*> token' "pedido" <*> symbol' '>' <*> (followedBy pItemsTag (succeed [])) <*> symbol' '<' <*> token' "/pedido" <*> symbol' '>'
        where f _ _ _ y _ _ _= Pedido y 

pPicoXML = f <$> (followedBy pContent (succeed []))
        where f x = PicoXML x 

giveAST l = fst(last l)

-- AST do exemplo acima 
ast = giveAST(pPicoXML exemploXML)

---------- PROGRAMAÇÃO ESTRATÉGICA -------------
etiquetaTags :: PicoXML -> PicoXML 
etiquetaTags p =
    let pZipper = toZipper p
        Just newP = applyTP (full_tdTP step) pZipper
        step = idTP `adhocTP` etiquetaNomeETelefone `adhocTP` etiquetaProdutoEQuantidade  -- Nesta travessia faz as duas funções ao mesmo tempo: etiquetaUma e etiquetaAtrib
    in fromZipper newP

etiquetaNomeETelefone :: SubContentCliente -> Maybe SubContentCliente
etiquetaNomeETelefone (Nome (ConteudoTag c)) = Just (Nome (ConteudoTag ("Nome: "++c)))
etiquetaNomeETelefone (Telefone (ConteudoTag c)) = Just (Telefone (ConteudoTag ("Telefone: "++c)))

etiquetaProdutoEQuantidade :: SubContentItens -> Maybe SubContentItens
etiquetaProdutoEQuantidade (Produto (ConteudoTag c)) = Just (Produto (ConteudoTag ("Produto: "++c)))
etiquetaProdutoEQuantidade (Quantidade (ConteudoTag c)) = Just (Quantidade (ConteudoTag ("Quantidade: "++c)))
----------------- Code Smells with refactoring --------
-- Um exemplo de um code smell que podemos possuir nesta linguagem é o conteudo vazio, tipo isto:
-- <teste></teste>
-- TESTAR COM ITEMSTAG
limpaTagsCliente :: SubContentCliente -> Maybe SubContentCliente
limpaTagsCliente (Nome (ConteudoTag s)) = if (s == "") then Nothing else Just (Nome (ConteudoTag s))
limpaTagsCliente (Telefone (ConteudoTag s)) = if (s == "") then Nothing else Just (Telefone (ConteudoTag s))

limpaTagsItens :: SubContentItens -> Maybe SubContentItens
limpaTagsItens (Produto (ConteudoTag s)) = if (s == "") then Nothing else Just (Produto (ConteudoTag s))
limpaTagsItens (Quantidade (ConteudoTag s)) = if (s == "") then Nothing else Just (Quantidade (ConteudoTag s))

limpaTags :: PicoXML -> PicoXML 
limpaTags p =
    let pZipper = toZipper p
        Just newP = applyTP (full_tdTP step) pZipper
        step = idTP `adhocTP` limpaTagsCliente `adhocTP` limpaTagsItens  -- Nesta travessia faz as duas funções ao mesmo tempo: etiquetaUma e etiquetaAtrib
    in fromZipper newP

-------------- QuickCheck ----------------------
-- Uma das propriedades que o xml tem de possuir é o seguinte:
-- O pedido não é nulo 
-- Se o XML possui alguma coisa válida 

-- Propriedade que testa se o XML tem alguma coisa válida 
prop_xmlIsDead :: PicoXML -> Bool
prop_xmlIsDead (PicoXML l) = if length l == 0 then True else False

-- Propriedade que testa se uma tag não tem conteúdo nulo 
prop_requestNotValid :: PicoXML -> Bool
prop_requestNotValid (PicoXML []) = True 
prop_requestNotValid (PicoXML (x:xs)) = if prop_requestIsValid(x) then prop_requestNotValid (PicoXML xs) else True

prop_requestIsValid :: Content -> Bool
prop_requestIsValid (Pedido l) = if length l == 0 then False else True

--------------- Generator -------------------
conteudoProduto = ["macas","peras","laranjas","pessego"]
conteudoQuantidade = ["1","2","3","4","5","6","7","8","9","10"]
conteudoNome = ["Antonio","Maria","Joao","Candida","Jose"]
conteudoTelefone = ["11111111","222222222","333333333","444444444"]

genConteudoProduto :: Gen Conteudo
genConteudoProduto = do 
                     conteudo <- elements conteudoProduto
                     return $ ConteudoTag conteudo

genConteudoQuantidade :: Gen Conteudo
genConteudoQuantidade = do 
                     conteudo <- elements conteudoQuantidade
                     return $ ConteudoTag conteudo

genConteudoNome :: Gen Conteudo
genConteudoNome = do 
                     conteudo <- elements conteudoNome
                     return $ ConteudoTag conteudo

genConteudoTelefone :: Gen Conteudo
genConteudoTelefone = do 
                     conteudo <- elements conteudoTelefone 
                     return $ ConteudoTag conteudo

genSubContentItens :: Gen SubContentItens
genSubContentItens = do 
                        conteudoProduto <- genConteudoProduto
                        conteudoQuantidade <- genConteudoQuantidade
                        frequency[(50,return(Produto conteudoProduto)),(50,return(Quantidade conteudoQuantidade))] 

genSubContentCliente:: Gen SubContentCliente
genSubContentCliente = do 
                        conteudoNome <- genConteudoNome
                        conteudoTelefone <- genConteudoTelefone
                        frequency[(50,return(Nome conteudoNome)),(50,return(Telefone conteudoTelefone))] 

genListSubContentItens :: Int -> Gen [SubContentItens]
genListSubContentItens x = sequence [genSubContentItens | n <- [1..x]]


genListSubContentCliente :: Int -> Gen [SubContentCliente]
genListSubContentCliente x = sequence [genSubContentCliente | n <- [1..x]]

genSubTags :: Int -> Gen SubTags 
genSubTags n = do
                listaItens <- genListSubContentItens n
                return $ Item listaItens

genListSubTags :: Int -> Gen [SubTags]
genListSubTags x = sequence [genSubTags x | n <- [1..x]]

genItemsTag :: Int -> Gen ItemsTag
genItemsTag n = do 
                listaSubTags <- genListSubTags n 
                listaSubContentCliente <- genListSubContentCliente n 
                frequency[(25,return (Cliente listaSubContentCliente)),(75,return (Itens listaSubTags))]

genListItensTag :: Int -> Gen [ItemsTag]
genListItensTag x = sequence [genItemsTag x | n <- [1..x]]

genContent :: Int -> Gen Content
genContent n = do 
                listItemsTag <- genListItensTag n
                return $ Pedido listItemsTag

genListContent :: Int -> Gen [Content]
genListContent x = sequence [genContent x | n <- [1..x]]

genPicoXML :: Int -> Gen PicoXML
genPicoXML n = do 
                listaContent <- genListContent n
                return $ PicoXML listaContent

instance Arbitrary PicoXML where
  arbitrary = sized genPicoXML 