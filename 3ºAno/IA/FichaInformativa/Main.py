dic={1:('Bananas',1.45),2:('Maçãs',1.99)}
def comparaP(self):
    for fruta,preço in dic.values():
        if preço>1.5:
            print('A fruta:'+fruta+' está cara.')
        else :
            print('A fruta:'+fruta+' está barata.')

def printaPares(self):
    for fruta,preço in dic.values():
        print('Fruta:'+fruta+' \nPREÇO:')
        print(preço)
# Para executarmos a função comparaP basta apenas fazer isto
comparaP(dic)
print('---------------------------------------')
printaPares(dic)