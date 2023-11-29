
%LICENCIATURA EM ENGENHARIA INFORMÁTICA
%MESTRADO integrado EM ENGENHARIA INFORMÁTICA

%Inteligência Artificial
%2022/23

%Draft Ficha 6


% Extensao do predicado filho: Filho,Pai -> {V,F}

filho( joao,jose ).
filho( jose,manuel ).
filho( carlos,jose ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado pai: Pai,Filho -> {V,F}

pai( P,F ) :- filho( F,P ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado avo: Avo,Neto -> {V,F}

avo(P,F) :- pai ( P,F ),
pai( P,F ) :- filho ( F,P ).



%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado bisavo: Bisavo,Bisneto -> {V,F}

bisavo(P,F) :- avo(F,P),
avo(P,F) :- pai ( F,P ),
pai( P,F ) :- filho ( F,P ).



%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado descendente: Descendente,Ascendente -> {V,F}







%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado descendente: Descendente,Ascendente,Grau -> {V,F}
