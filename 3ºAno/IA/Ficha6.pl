filho(joao,jose).
filho(jose,manuel).
filho(carlos,jose).

pai(paulo,filipe).
pai(paulo,maria).
pai(P,F):-filho(F,P).

avo(antonio,nadia).
avo(A,N):-pai(A,P),pai(P,N).
avo(A,N):- graudescendente(N,A,2).

neto(nuno,ana).
neto(N,A):-avo(A,N).

homem(joao).
homem(jose).

mulher(maria).
mulher(joana).

descendente(A,Y,_):-neto(A,Y);filho(A,Y);pai(Y,A);avo(Y,A).

graudescendente(A,Y,G):- descendente(A,Y1,G1), descendente(Y1,Y,1),G is G1+1.

bisavo(X,Y):-neto(Y,W),filho(W,X).

trisavo(X,Y):-bisavo(W,Y),filho(W,X).

tetraneto(X,Y):- trisavo(Y,W),filho(X,W).
