from z3 import *

# Alocação das variaveis 
professores = ["Ana","Beatriz","Carlos"]
aulas = [1,2,3,4,5]
x={}
for p in professores:
    x[p]={}
    for a in aulas:
        x[p][a]= Bool("%s,%d" % (p,a))

# Criação do solver 
s = Solver()

# O Carlos não pode dar a primeira aula.
s.add(Not(x["Carlos"][1]))
# Se a Beatriz der a primeira aula, não poderá dar a última.
s.add(Implies(x["Beatriz"][1],Not(x["Beatriz"][5])))
# Cada aula tem pelo menos um formador.
for a in aulas:
    s.add(Or(x["Ana"][a],x["Beatriz"][a],x["Carlos"][a]))
# As quatro primeiras aulas têm no máximo um formador.
# O a varia de 1 a 4 
# x Carlos a -> Not(x Ana a) and Not(x Beatriz a)
# x Ana a -> Not(x Beatriz a) and Not(x Carlos a)
# x Beatriz a -> Not(x Ana a) and Not(x Carlos a) 
for a in aulas[:-1]:
    s.add(And(Implies(x["Carlos"][a],And(Not(x["Ana"][a]),Not(x["Beatriz"][a]))),Implies(x["Ana"][a],And(Not(x["Beatriz"][a]),Not(x["Carlos"][a]))),Implies(x["Beatriz"][a],And(Not(x["Ana"][a]),Not(x["Carlos"][a])))))
# A última aula pode ter no máximo dois formadores.
# Not(x["Carlos"][5] e x["Beatriz"][5] e x["Ana"][5])
s.add(Not(And(x["Carlos"][5],x["Ana"][5],x["Beatriz"][5])))
# Nenhum formador pode dar 4 aulas consecutivas.
for p in professores:
    s.add(Not(Or(And(x[p][1],x[p][2],x[p][3],x[p][4]),And(x[p][2],x[p][3],x[p][4],x[p][5]))))

# Para testar se um conjunto de restrições são satisfazíveis :
if s.check() == sat:
   print("O conjunto de regras é consistente.")
   print(s.model())
else:
  print("O conjunto de regras é inconsistente.")