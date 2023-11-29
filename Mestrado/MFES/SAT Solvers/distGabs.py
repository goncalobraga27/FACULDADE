from z3 import *

pessoas = ["Ana","Nuno","Pedro","Maria"]
gabs = [1,2,3]
x = {}
for p in pessoas:
    x[p] = {}
    for g in gabs:
        x[p][g] = Bool("%s,%d" % (p,g))

s = Solver()



# Cada pessoa ocupa pelo menos um gabinete.
for p in pessoas:
  s.add(Or([x[p][g] for g in gabs]))

# Cada pessoa ocupa no máximo um gabinete.
for p in pessoas:
    for g in gabs[:-1]:
        s.add(Implies(x[p][g]),And(Not(x[p][h])for h in gabs if h>g))
# O Nuno e o Pedro não podem partilhar gabinete.

# Se a Ana ficar sozinha num gabinete, então o Pedro também terá que ficar sozinho num gabinete.

# Cada gabinete só pode acomodar, no máximo, 2 pessoas.



s.push()

if s.check() == sat:
    m = s.model()
    for p in pessoas:
        for g in gabs:
            if is_true(m[x[p][g]]):
                print("%s fica no gabinete %s" % (p,g))
else:
  print("Não tem solução.")