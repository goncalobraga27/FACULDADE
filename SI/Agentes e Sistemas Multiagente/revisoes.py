
def parOuImpar(x):
    if x%2 == 0 :
        return "Par"
    else:
        return "Impar"

def calculaMedia(list):
    soma = 0
    for it in list:
        soma += it
    return soma/len(list)
def searchPair(dict,key):
    if key in dict:
        print("Key:"+str(key)+"|Value:"+str(dict[key]))

class Person:
    ## T2.3
    def __init__(self,fstName,lstName,age,nacionality):
        self.firstName = fstName
        self.lastName = lstName
        self.age = age
        self.nacionality = nacionality
    
    def printfname(self):
       return "First Name:"+str(self.firstName)+"|Last Name:"+str(self.lastName)

class Student:
    ## T2.4
    def __init__(self,p,curso,ano):
        self.person = p
        self.curso = curso
        self.ano = ano
    
    def printStudent(self):
        return self.person.printfname() + "|Curso:" + str(self.curso)+"|Ano:"+str(self.ano)
def main():
    ## T2.1
    res = parOuImpar(124)
    print(res)
    ## T2.2
    res = calculaMedia([1,2])
    print(res)
    p = Person("Gonçalo","Santos",21,"Angolano")
    print(p.printfname())
    s = Student(p,"Mestrado em Engeharia Informática",4)
    print(s.printStudent())
    ## T2.5
    phone_book = {
        "John" : [ "8592970000", "" ],
        "Bob" : [ "7994880000", "" ],
        "Tom" : [ "9749552647", "" ]
    }
    searchPair(phone_book,"John")


if "__main__":
    main()