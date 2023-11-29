from z3 import *

CPU1, CPU2, MB1, MB2, PG1, PG2, RAM1, RAM2, MON1, MON2 = Bools("CPU1 CPU2 MB1 MB2 PG1 PG2 RAM1 RAM2 MON1 MON2")

s = Solver()

s.add(Or(CPU1,CPU2))
s.add(Or(MB1,MB2))
s.add(Or(RAM1,RAM2))
s.add(Or(PG1,PG2))
s.add(Implies(CPU1,Not(CPU2)))
s.add(Implies(MB1,Not(MB2)))
s.add(Implies(RAM1,Not(RAM2)))
s.add(Implies(PG1,Not(PG2)))
s.add(Not(And(MON1,MON2)))

# A motherboard MB1 quando combinada com a placa gráfica PG1, obriga à utilização da RAM1 : MB1 e PG1 -> RAM1
s.add(Implies(And(MB1,PG1),RAM1))
# A placa grágica PG1 precisa do CPU1, excepto quando combinada com uma memória RAM2 : PG1 and not(RAM2) -> CPU1
s.add(Implies(And(PG1,Not(RAM2)),CPU1))
# O CPU2 só pode ser instalado na motherboard MB2 : CPU2 -> MB2
s.add(Implies(CPU2,MB2))
# O monitor MON1 para poder funcionar precisa da placa gráfica PG1 e da memória RAM2 : MON1 -> PG1 e RAM2 
s.add(Implies(MON1,And(PG1,RAM2)))

s.push()
F1 = ((Implies(MON1,MB1)))     # Não sei se falta a negação disto 
s.add(F1)
print("O monitor MON1 só poderá ser usado com uma motherboard MB1 ?")
if (s.check()) == sat:
    print("O monitor MON1 só pode ser usado com uma motherboard MB1.")
    print(s.model())
else :
    print("O monitor MON1 não pode ser usado com uma motherboard MB1.")
    print(s.model())
s.pop()

s.push()
F2 = (And(MB2,CPU1,PG2,RAM1))    # Não sei se falta a negação disto 
s.add(F2)
print("uma motherboard MB2, o CPU1, a placa gráfica PG2 e a memória RAM1 ?")
if (s.check()) == sat:
    print("O computador pode ser personalizado dessa forma.")
    print(s.model())
else :
    print("O computador não pode ser personalizado dessa forma.")
    print(s.model())
s.pop()


# Para testar se um conjunto de restrições são satisfazíveis :
#if s.check() == sat:
#   print("O conjunto de regras é consistente.")
#else:
#  print("O conjunto de regras é inconsistente.")


