%LICENCIATURA EM ENGENHARIA INFORMATICA
%MESTRADO integrado EM ENGENHARIA INFORMATICA

%Inteligencia Artificial
%2022/23

%Draft Ficha 8


%biblioteca(id, nome, localidade)

biblioteca(1, uminhogeral, braga).
biblioteca(2, luciocracveiro, braga).
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

%requisicoes(id_requisicao,id_leitor, id_livro, data(A,M,D)

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

%1 
leitoras(Mulher):-leitores(_,Mulher,f).

mulheresLeitoras(LR):-findall(Mulher,leitoras(Mulher),LR).

numeroLeitoras(R):-mulheresLeitoras(LM),length(LM,R).

%2
livrosPerdidos(Livro):-livros(_,Livro,IdB),not(biblioteca(IdB,_,_)).

livrosSemBiblioteca(L):-findall(Livro,livrosPerdidos(Livro),L).

%3
emBraga(Livro,Leitor):-requisicoes(_,IdLP,IdL,_),leitores(IdLP,Leitor,_),livros(IdL,Livro,IdB),biblioteca(IdB,_,braga).

requisicoesBraga(L):-findall((Livro,Leitor),emBraga(Livro,Leitor),L).

%4
intactos(Livro):-livros(IdL,Livro,IdB),not(requisicoes(_,_,IdL,_));livros(IdL,Livro,IdB),not(biblioteca(IdB,_,_)).

livrosIntactos(L):-findall(Livro,intactos(Livro),L).

%5 
livrosLidos(Livro,data(A,M,D)):-livros(IdL,Livro,_),requisicoes(_,_,IdL,data(A,M,D)),A==2022.

livrosEm2022(LR):-findall((Livro,data(A,M,D)),livrosLidos(Livro,data(A,M,D)),LR).

%6
leitoresCalorentos(Nome):-requisicoes(_,IdL,_,data(A,M,D)),leitores(IdL,Nome,_),(M>=7),(M=<9).

leitoresRequisitados(L):-findall(Nome,leitoresCalorentos(Nome),L).
%7
testaDatas(A,M,D,A1,M1,D1):- A>A1, !;M>M1, !;R=D-D1, R>15.
entregueComAtraso(Nome,R):-devolucoes(IdR,data(A,M,D)),requisicoes(IdR,IdL,_,data(A1,M1,D1)),leitores(IdL,Nome,_),testaDatas(A,M,D,A1,M1,D1).
atrasados(L):-findall(Nome,entregueComAtraso(Nome,R),L).


