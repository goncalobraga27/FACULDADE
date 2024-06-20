from random import shuffle
from hypothesis import given,assume,event
from hypothesis.strategies import *
import math

# python -m pytest .\ficha.py
# 



# EX 1

def mulLR(list_nums):
    if len(list_nums) == 0:
        return 1
    else:
        return list_nums[0] * mulLR(list_nums[1:])
    
def mulLI(list_nums):
    res = 1
    for n in list_nums:
        res *= n
    return res

# a)
@given(lists(integers(),min_size=1))
def test_Mul(l):
    x = list(l)
    x.reverse()
    assert mulLR(l) == mulLR(x)
    assert mulLI(l) == mulLI(x)

# b)
@given(lists(integers(),min_size=1, max_size=1))
def test_Single(l):
    assert mulLR(l) == l[0]
    assert mulLI(l) == l[0]

# c)
@given(lists(integers(),min_size=1))
def test_Math(l):
    assert mulLR(l) == math.prod(l)
    assert mulLI(l) == math.prod(l)

# EX 2 
def myIndex(input_list, value):
    if len(input_list) == 0:
        raise ValueError("Value not found in list")
    if value == input_list[0]:
            return 0
    else:
        return 1 + myIndex(input_list[1:], value)

@given(lists(integers()),integers())
def test_haveValue(x,e):
    x.append(e)
    shuffle(x)
    assert myIndex(x,e) >= 0

@given(lists(integers()),integers())
def test_myIndex_same_index(x,e):
    x.append(e)
    shuffle(x)
    assert x.index(e) == myIndex(x,e)

# EX 3
@given(integers())
def test_positive(x):
    assume(x > 0)
    assert (x * x * x) > 0

# Ou especificar estratégias mais detalhadas de geração de valores:

@given(integers(min_value=1, max_value=1000))
def test_positive2(x):
    assert (x * x * x)

def isSorted(list_nums):
    return False not in [a <= b for (a,b) in zip(list_nums, list_nums[1:])]

def insert(elem, list_nums):
    i = 0
    r = []
    while (i < len(list_nums) and elem > list_nums[i]):
        r.append(list_nums[i])
        i += 1
    r.append(elem)
    while (i < len(list_nums)):
        r.append(list_nums[i])
        i += 1
    return r

@given(integers(),lists(integers(),min_size=5))
#@settings(max_examples=100)
def test_ordenada(n, l):
    event(f"List length: {len(l)}")
    assume(isSorted(l))
    res = insert(n, l)
    assert isSorted(res)

@given(integers(),lists(integers(),min_size=5).filter(lambda l : isSorted(l)))
#@settings(max_examples=100)
def test_ordenada2(n, l):
    event(f"List length: {len(l)}")
    res = insert(n, l)
    assert isSorted(res)


@given(integers(),lists(integers(),min_size=5).map(sorted))
def test_ordenada3(n, l):
    event(f"List length: {len(l)}")
    res = insert(n, l)
    assert isSorted(res)


@composite 
def sorted_lists(draw):
    x = draw(lists(integers()))
    return sorted(x)

@given(integers(),sorted_lists())
def test_ordenada4(n, l):
    event(f"List length: {len(l)}")
    res = insert(n, l)
    assert isSorted(res)
