%biblioteca(id, nome, localidade)

biblioteca(1, uminhogeral, braga).
biblioteca(2, luciocraveiro, braga).
biblioteca(3, municipal, porto).
biblioteca(4, publica, viana).
biblioteca(5, ajuda, lisboa).
biblioteca(6, cidade, coimbra).


%livros( id, nome, biblioteca)

livros(1, gameofthrones, 1). 
livros(2, codigodavinci, 2).
livros(3, setimoselo, 1).
livros(4, fireblood, 4).
livros(5, harrypotter, 6).
livros(6, senhoradosneis, 7).
livros(7, oalgoritmomestre, 9).

%leitores(id, nome, genero)

leitores(1, pedro, m).
leitores(2, joao, m).
leitores(3, lucia, f).
leitores(4, sofia, f).
leitores(5, patricia, f).
leitores(6, diana, f).

%requisicoes(id_requisicao,id_leitor, id_livro, data(A,M,D))

requisicoes(1,2,3,data(2022,5,17)).
requisicoes(2,1,2,data(2022,7,10)).
requisicoes(3,1,3,data(2021,11,2)).
requisicoes(4,1,4,data(2022,2,1)).
requisicoes(5,5,3,data(2022,4,23)).
requisicoes(6,4,2,data(2021,3,9)).
requisicoes(7,4,1,data(2022,5,5)).
requisicoes(8,2,6,data(2021,7,18)).
requisicoes(9,5,7,data(2022,4,12)).


%devolucoes(id_requisicao, data(A,M, D))


devolucoes(2, data(2022, 7,26)).
devolucoes(4, data(2022,2,4)).
devolucoes(5, data(2022, 6, 13)).
devolucoes(1, data(2022, 5, 23)).
devolucoes(6, data(2022, 4, 9)).


% Quantos leitores do sexo feminino existem representados na base de conhecimentos;

mulheres(Nome):-leitores(_,Nome,f).

nomeMulheres(LR):- findall(Nome,mulheres(Nome),LR).

numeroMulheres(R):-nomeMulheres(LR),length(LR,R).

% Indique quais os livros e os respetivos leitores que efetuaram requisições em bibliotecas localizadas em Braga;

requisicoesBraga(Livro,NomeL):-requisicoes(_,IdLeitor,IdLivro,_),leitores(IdLeitor,NomeL,_),livros(IdLivro,Livro,IdBib),biblioteca(IdBib,_,braga).

livrosEleitores(LR):- findall((Livro,NomeL),requisicoesBraga(Livro,NomeL),LR).

% Quais os livros que foram requisitados por leitores, mas que não se encontram associados a nenhuma biblioteca da base de conhecimento;

livrosSemBiblioteca(Nome):-requisicoes(_,_,IdLivro,_),livros(IdLivro,Nome,IdBib),not(biblioteca(IdBib,_,_)).

livrosSemBB(LR):- findall(Nome,livrosSemBiblioteca(Nome),LR).

% Quais os livros que não tiveram nenhuma requisição. Para esta questão, assuma requisição de livros que se encontram ou não em alguma biblioteca;

livrosImpec(Nome):-livros(IdLivro,Nome,_),not(requisicoes(_,_,IdLivro,_)).
livrosIntactos(LR):- findall(Nome,livrosImpec(Nome),LR).

% Apresente a lista de livros, e a respetiva data de requisição, que tenham sido pedidos em 2022;

requisicoesEm2022(Nome,data(A,M,D)):-requisicoes(_,_,IdLivro,data(A,M,D)),livros(IdLivro,Nome,_).

livrosLevantadosEm2022(LR):- findall((Nome,data(2022,M,D)),requisicoesEm2022(Nome,data(2022,M,D)),LR).

% Que leitores requisitaram livros no Verão. Assuma que o Verão se encontra compreendido entre Julho e Setembro;

leitoresNaAreia(Nome):-requisicoes(_,IdLeitor,_,data(_,M,_)),leitores(IdLeitor,Nome,_),M>=7,M=<9.
leitoresNoverao(LR):- findall(Nome,leitoresNaAreia(Nome),LR).

xpto([X],R):-X==R.
xpto([H|T],X):-H==X,xpto(T,X).

pertence([X|T],X).
pertence([_|T],X) :- pertence(T,X).