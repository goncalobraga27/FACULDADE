filho(joao,jose).
filho(jose,manuel).
filho(carlos,jose).

neto(nuno,ana).

mulher(maria). 
mulher(joana).

pai(paulo,filipe).
pai(paulo,maria).

homem(joao).
homem(jose).	

avo(antonio,nadia).
avo(ana,nuno).

pai(P,F):-filho(F,P).

neto(N,A):-avo(A,N).

avo(A,N):-filho(N,X),pai(A,X).