
aluno(1,joao,m).
aluno(2,antonio,m).
aluno(3,carlos,m).
aluno(4,luisa,f).
aluno(5,maria,f).
aluno(6,isabel,f).

curso(1,lei).
curso(2,miei).
curso(3,lcc).

%disciplina(cod,sigla,ano,curso)
disciplina(1,ed,2,1).
disciplina(2,ia,3,1).
disciplina(3,fp,1,2).

%inscrito(aluno,disciplina)
inscrito(1,1).
inscrito(1,2).
inscrito(5,3).
inscrito(5,5).
inscrito(2,5).

%nota(aluno,disciplina,nota)
nota(1,1,15).
nota(1,2,16).
nota(1,5,20).
nota(2,5,10).
nota(3,5,8).

%copia
copia(1,2).
copia(2,3).
copia(3,4).

%1
alunoNaoInscrito(Aluno):-aluno(IdA,Aluno,_),not(inscrito(IdA,_)).

naoInscrito(L):-findall(Aluno,alunoNaoInscrito(Aluno),L).

%2 
alunoNaoInscritoTotal(Aluno):-aluno(IdA,Aluno,_),not(inscrito(IdA,_));inscrito(IdA,IdD),not(disciplina(IdD,_,_,_)).

naoInscritoTotal(L):-findall(Aluno,alunoNaoInscritoTotal(Aluno),L).

%3 
giveNotas(Aluno,N):-aluno(IdA,Aluno,_),nota(IdA,_,N).

notas(Aluno,L):-findall(N,giveNotas(Aluno,N),L).

sum([],0).
sum([H|T],R):-sum(T,R1),R is R1+H.



media(Aluno,Valor):-notas(Aluno,L),sum(L,R),length(L,R1),Valor is R/R1. 

%4
comparaMedia(Valor1,Valor2):-Valor1>Valor2.

giveNotasTotais(ListaNotas):-findall(N,nota(_,_,N),ListaNotas).

mediaTotal(Valor):-giveNotasTotais(ListaNotas),sum(ListaNotas,R1),length(ListaNotas,R2),Valor is R1/R2.

top(Aluno):-aluno(IdA,Aluno,_),nota(IdA,_,_),media(Aluno,Valor1),mediaTotal(Valor2),comparaMedia(Valor1,Valor2).

topAlunos(ListaResultado):-findall(Aluno,top(Aluno),ListaResultado).

%5
carregados(Aluno):-aluno(IdA,Aluno,_),copia(IdA,_).

copiaram(L):-findall(Aluno,carregados(Aluno),L).

%6 
carregadosDuplamente(Aluno):-aluno(IdA,Aluno,_),copia(IdA,_);copia(_,IdA),copia(IdA,_).

copiaramDuplos(L):-findall(Aluno,carregadosDuplamente(Aluno),L).


%7 
equals(N,R):-aluno(N,Aluno,_),R=[Aluno];not(aluno(N,Aluno,_)),R=[].
mapToNome([],[]).
mapToNome([H|T],R):- mapToNome(T,R1),equals(H,R2),append(R1,R2,R).

 
