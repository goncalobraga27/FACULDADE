from random import shuffle
from hypothesis import given,assume,event,settings,strategies as st
from hypothesis.strategies import *
import math
import random
import string

############## 2. Exercícios 
## 1.
def mulLR(list_nums):
    if len(list_nums) == 0:
        return 0
    else:
        return list_nums[0] * mulLR(list_nums[1:])

def mulLI(list_nums):
    res = 0
    for n in list_nums:
        res *= n
    return res



## a)
@given(lists(integers(),min_size=1))
def test_testemulLR(lista):
    x = list(lista)
    x.reverse()
    assert mulLR(lista) == mulLR(x)

@given(lists(integers(),min_size=1))
def test_testemulLI(lista):
    x = list(lista)
    x.reverse()
    assert mulLI(lista) == mulLI(x)

## b)
@given(lists(integers(),max_size=1,min_size=1))
def test_testeForOneElem_mulLI(lista):
    assert mulLI(lista) == lista[0]

@given(lists(integers(),max_size=1,min_size=1))
def test_testeForOneElem_mulLR(lista):
    assert mulLR(lista) == lista[0]

## c)
@given(lists(integers(),max_size=1,min_size=1))
def test_equalProd_mulLI(lista):
    assert mulLI(lista) == math.prod(lista)

@given(lists(integers(),min_size=1))
def test_equalProd_mulLR(lista):
    assert mulLR(lista) == math.prod(lista)

## 2. 
def myIndex(input_list, value):
       if len(input_list) == 0:
           raise ValueError("Value not found in list")
       try:
           return 1 + myIndex(input_list[1:], value)
       except:
           if value == input_list[0]:
               return 0
           else:
               raise ValueError("Value not found in list")

## a)
@given(lists(integers(),min_size=1),integers())
@settings(max_examples=100)
def test_haveNumber(lista,numero):
    lista.append(numero)
    shuffle(lista)
    assert myIndex(lista,numero) >= 0

## b) 
## Nesta função quando encontramos o valor ele vai dar sempre "Value not found in list", pois ele faz o caso de paragem e o caso de paragem dá sempre "Value not found in list"
def myIndexCorrect(input_list, value):
    contador = 0
    for v in input_list:
        if v == value :
            return contador
        else:
            contador = contador +1
    return "Erro"

@given(lists(integers(),min_size=1),integers())
@settings(max_examples=100)
def test_haveNumberCorrect(lista,numero):
    lista.append(numero)
    shuffle(lista)
    assert myIndexCorrect(lista,numero) >= 0

## 3.
@given(integers())
def test_positive(x):
    assume(x > 0)
    assert (x * x * x) > 0


@given(integers(min_value=1, max_value=1000))
def test_positive2(x):
    assert (x * x * x) > 0

def isSorted(list_nums):
    return False not in [a <= b for (a,b) in zip(list_nums, list_nums[1:])]

def insert(elem, list_nums): 
    i=0
    r = []
    while (i < len(list_nums) and elem > list_nums[i]):
        r.append(list_nums[i])
        i += 1
    r.append(elem)
    while (i < len(list_nums)):
        r.append(list_nums[i])
        i += 1
    return r

## a)
@given(lists(integers(),min_size=1),integers())
def test_alwaysOrdered(lista,num):
    assume(isSorted(lista))
    insert(num,lista)
    assert isSorted(lista) == True

## b)
# Temos de executar com isto: python -m pytest Hypothesis.py --hypothesis-show-statistics
@given(lists(integers(),min_size=1),integers())
def test_alwaysOrderedWithEvent(lista,num):
    event(f"List length: {len(lista)}")
    assume(isSorted(lista))
    insert(num,lista)
    assert isSorted(lista) == True

## c)
@composite 
def sorted_lists(draw):
    x = draw(lists(integers()))
    return sorted(x)

## d)
@given(integers())
def test_sorted_lists_ordered(num):
    x = sorted_lists()
    insert(num,x)
    assert isSorted(x) == True 

"""
@given(integers(),sorted_lists())
def test_ordenada4(n, l):
    event(f"List length: {len(l)}")
    res = insert(n, l)
    assert isSorted(res)
"""

## 4. 
class Aluno:
      def __init__(self, _nome, _idade, _curso, _notas):
          self.nome = _nome
          self.idade = _idade
          self.curso = _curso
          self.notas = _notas

## a)

## i. 
def __str__(self):
    res = "Nome: " + self.nome + "|Idade: " + str(self.idade) + "|Curso: " + str(self.curso) + "|Notas: " + str(self.notas)
    return res

## ii.
def media(self):
    ucs = 0
    notas = 0
    for k in self.notas.keys():
        ucs = ucs + 1
        notas = notas + self.notas[k]
    return notas/ucs

## iii.
def excelente(self):
    notasPositivas = True
    for k in self.notas.keys():
        if self.notas[k]< 10:
            notasPositivas = False
            break
    if (notasPositivas and self.media()>=15):
        return True
    else:
        return False    

## b)

## i. 
def gerador_nome():
    nome = ''.join(random.choices(string.ascii_letters, k=random.randint(5, 10)))
    return nome.capitalize()

## ii. 
def gerador_idade():
    idade = ''.join(random.choice(string.digits, k=random.randint(1, 3)))
    return int(idade)

## iii.
def gerador_curso():
    curso = random.choise["LEI","LCC"]
    return curso

## iv.
def gerador_notas():
    # Lista de UCs e notas válidas
    ucs = ["Matemática", "Português", "História", "Geografia"]
    notas_validas = [random.uniform(0, 20) for _ in range(5)]  # Gerar algumas notas aleatórias válidas

    # Dicionário para armazenar as notas
    notas = {}

    # Adiciona pelo menos uma UC com pelo menos três notas
    uc = random.choice(ucs)
    notas[uc] = random.sample(notas_validas, k=random.randint(3, len(notas_validas)))

    # Adiciona outras UCs com pelo menos três notas
    for uc in random.sample(ucs, k=random.randint(1, len(ucs) - 1)):
        notas[uc] = random.sample(notas_validas, k=random.randint(3, len(notas_validas)))

    return notas

## v.
@st.composite
def alunos(draw):
    nome = draw(gerador_nome())
    idade = draw(gerador_idade())
    curso = draw(gerador_curso())  # Supondo que "LEI" e "LCC" são cursos válidos
    notas = draw(gerador_notas())  # Supondo que você já tem uma função geradora de notas
    return Aluno(nome, idade, curso, notas)

# Use a estratégia de busca na função de teste
@given(aluno=alunos)
def test_corretMedia(aluno):
    assert 0 <= aluno.media() <= 20