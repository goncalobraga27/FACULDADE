%1 
somaValores(X,Y,Z,R):- R is X+Y+Z.
%2
somaLista([],0).
somaLista([H|T],R):- somaLista(T,R1), R is R1+H.
%3
maiorValor(X,Y,R):- X>Y, R is X.
maiorValor(X,Y,R):- Y>X, R is Y.
%4
maiorValorLista([],R):- R is 0.
maiorValorLista([H|T],R):-maiorValorLista(T,R1),maiorValor(R1,H,R).
%5
sum([],0).
sum([H|T],R):- sum(T,R1), R is R1+H.

media([],0).
media([H|T],R):- sum([H|T],R1), length([H|T],R2), R is R1/R2.

%6
ordena([],[]).
ordena([H],[H]).
ordena([H|T],L):- sort([H|T],L).

%7
numerosPares(X):- X mod 2 =:= 0.
numerosImpares(X):- X mod 2 =:= 1.

%8
pertence([],X):- false.
pertence([X],Y):- X==Y.
pertence([H|T],Y):- pertence(T,Y); H==Y .

%9 
mylength([],0).
mylength([H],1).			
mylength([H|T],R):- mylength(T,R1), R is R1+1.

%10
numerosDif([],0).
numerosDif([H|T],R):-numerosDif(T,R1),not(pertence(T,H)=true), R is R1+1. 

%13 
adicionar(X,[],[X]).
adicionar(X,[H|T],R):-not(pertence([H|T],X)),append([H|T],[X],R).
adicionar(X,[H|T],[H|T]):-pertence([H|T],X).

%14
concatena([],[],[]).
concatena([],L,L).
concatena(L,[],L).
concatena([H|T],[H1|T1],R):-concatena(T,T1,R1),append([H,H1],R1,R).

%15
inverte([],[]).
inverte([H],[H]).
inverte([H|T],R):-inverte(T,R1),append(R1,[H],R).

%16 
sublista([],[H|T]):-true.
sublista([H1|T1], [H2|T2]):-sublista(T1,[H2|T2]),pertence([H2|T2],H1).
