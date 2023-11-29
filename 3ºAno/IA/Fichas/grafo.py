# Biblioteca de tratamento de grafos necessária para desenhar graficamente o grafo
 #import networkx as nx

 #import matplotlib.pyplot as plt
# Biblioteca de tratamento de grafos necessária para desenhar graficamente o grafo


#biblioteca necessária para se poder utilizar o valor math.inf  (infinito)
import math
import queue
# Importar a classe nodo
from nodo import Node

# import do modelo de dados queue
import queue
#Definição da classe grafo:
#Um grafo tem uma lista de nodos,
#um dicionário:  nome_nodo -> lista de tuplos (nome_nodo,peso)
#para representar as arestas
#uma flag para indicar se é direcionado ou não
class Graph:
    # Construtor da classe
    def __init__(self, directed=False):
        self.m_nodes = []   # lista de nodos do grafo
        self.m_directed = directed   # se o grafo é direcionado ou nao
        self.m_graph = {}   #  dicionario para armazenar os nodos, arestas  e pesos



    ##############################
    # Escrever o grafo como string
    ##############################
    def __str__(self):
        out = ""
        for key in self.m_graph.keys():
            out = out + "node " + str(key) + ": " + str(self.m_graph[key]) + "\n"
        return out

    #####################################
    # Adicionar aresta no grafo, com peso
    ####################################
    def add_edge(self, node1, node2, weight):   #node1 e node2 são os 'nomes' de cada nodo
        n1 = Node(node1)     # cria um objeto node  com o nome passado como parametro
        n2 = Node(node2)     # cria um objeto node  com o nome passado como parametro
        if (n1 not in self.m_nodes):
            self.m_nodes.append(n1)
            self.m_graph[node1] = set()
        else:
            n1 = self.get_node_by_name(node1)

        if (n2 not in self.m_nodes):
            self.m_nodes.append(n2)
            self.m_graph[node2] = set()
        else:
            n2 = self.get_node_by_name(node2)

        self.m_graph[node1].add((node2, weight))

        # se o grafo for nao direcionado, colocar a aresta inversa
        if not self.m_directed:
            self.m_graph[node2].add((node1, weight))

    ################################
    # Encontrar nodo pelo nome
    ################################
    def get_node_by_name(self, name):
        search_node = Node(name)
        for node in self.m_nodes:
            if node == search_node:
                return node
            else:
                return None

    ###########################
    # Imprimir arestas
    ###########################
    def imprime_aresta(self):
        listaA = ""
        for nodo in self.m_graph.keys():
            for (nodo2, custo) in self.m_graph[nodo]:
                listaA = listaA + nodo + " ->" + nodo2 + " custo:" + str(custo) + "\n"
        return listaA

    ################################
    # Devolver o custo de uma aresta
    ################################
    def get_arc_cost(self, node1, node2):
        custoT=math.inf
        a=self.m_graph[node1]    # lista de arestas para aquele nodo
        for (nodo,custo) in a:
            if nodo==node2:
                custoT=custo

        return custoT



    ######################################
    # Dado um caminho calcula o seu custo
    #####################################
    def calcula_custo(self, caminho):
        #caminho é uma lista de nomes de nodos
        teste=caminho
        custo=0
        i=0
        while i+1 < len(teste):
             custo=custo + self.get_arc_cost(teste[i], teste[i+1])
             i=i+1
        return custo


    ################################################################################
    # Procura DFS
    ####################################################################################
    def procura_DFS(self,start, end, path=[], visited=set()):
        path.append(start)
        visited.add(start)

        if start == end:
            # calcular o custo do caminho funçao calcula custo.
            custoT= self.calcula_custo(path)
            return (path, custoT)
        for (adjacente, peso) in self.m_graph[start]:
            if adjacente not in visited:
                resultado = self.procura_DFS(adjacente, end, path, visited)
                if resultado is not None:
                    return resultado
        path.pop()  # se nao encontra remover o que está no caminho......
        return None

    ###########################
    # desenha grafo  modo grafico
    #########################
    def desenha(self):
        ##criar lista de vertices
        lista_v = self.m_nodes
        lista_a = []
        g=nx.Graph()

        #Converter para o formato usado pela biblioteca networkx
        for nodo in lista_v:
            n = nodo.getName()
            g.add_node(n)
            for (adjacente, peso) in self.m_graph[n]:
                lista = (n, adjacente)
                #lista_a.append(lista)
                g.add_edge(n,adjacente,weight=peso)

        #desenhar o grafo
        pos = nx.spring_layout(g)
        nx.draw_networkx(g, pos, with_labels=True, font_weight='bold')
        labels = nx.get_edge_attributes(g, 'weight')
        nx.draw_networkx_edge_labels(g, pos, edge_labels=labels)

        plt.draw()
        plt.show()
###################################################################
# Procura_BFS
###################################################################
    def procura_BFS(self, start, end):
        #definir nodos visitados para evitar ciclos
        visited=set()
        fila=[]
        custo=0
        #adicionar o nodo inicial à fila aos visitados
        fila.append(start)
        visited.add(start)
        #garantir que o start node não tem pais ...
        parent=dict()
        parent[start]=None

        path_found=False
        while len(fila)!=0 and path_found==False:
            nodo_atual=fila.pop(0)
            if nodo_atual==end:
                path_found=True
            else:
                for(adjacente,peso) in self.m_graph[nodo_atual]:
                    if adjacente not in visited:
                        fila.append(adjacente)
                        parent[adjacente]=nodo_atual
                        visited.add(adjacente)

            # reconstruir caminho
            path=[]
            if path_found:
                path.append(end)
                while parent[end] is not None:
                    path.append(parent[end])
                    end=parent[end]
                path.reverse()
                # calculo do custo do caminho
                custo=self.calcula_custo(path)
                return (path,custo)

    def add_heuristica(self,n,estima):
        nodo=Node(n)
        if nodo in self.m_nodos:
            self.m_heuristica[n]=estima
################################################################
# Procura por greedy
################################################################
    def greedy(self, start, end):
        # open_list é uma lista de nodos visitados, mas com vizinhos que ainda não foram todos visitados, começa com o  start
        # closed_list é uma lista de nodos visitados e todos os seus vizinhos também já o foram
        open_list = set([start])      # Adiciona o star á lista de nodos visitados
        closed_list = set([])         # No inicio os nodos que já foram visitados, quem não é nenhum

        # parents é um dicionário que mantém o antecessor de um nodo
        # começa com start
        parents = {}       # O dicionário dos pais dos nodos, que existem
        parents[start] = start   # O pai do star é o start

        while len(open_list) > 0:
            n = None

            # encontraf nodo com a menor heuristica
            for v in open_list:
                if n == None or self.m_h[v] < self.m_h[n]: # Aqui coloca o nodo que vai selecionar para o caminho
                    n = v

            if n == None:
                print('Path does not exist!')      # Caso o nodo não axiste, isto é todos os nodos têm valor maior que o seu pai
                return None

            # se o nodo corrente é o fim
            # reconstruir o caminho a partir desse nodo até ao start
            # seguindo o antecessor
            if n == end:
                reconst_path = []

                while parents[n] != n:
                    reconst_path.append(n)
                    n = parents[n]

                reconst_path.append(start)

                reconst_path.reverse()

                return (reconst_path, self.calcula_custo(reconst_path))

            # para todos os vizinhos  do nodo corrente
            for (m, weight) in self.getNeighbours(n):
                # Se o nodo corrente nao esta na open nem na closed list
                # adiciona-lo à open_list e marcar o antecessor
                if m not in open_list and m not in closed_list:
                    open_list.add(m)
                    parents[m] = n

            # remover n da open_list e adiciona-lo à closed_list
            # porque todos os seus vizinhos foram inspecionados
            open_list.remove(n)
            closed_list.add(n)

        print('Path does not exist!')
        return None
###################################
#Procura de A-star
###################################
    def aStar(self, start, end):
        # open_list é uma lista de nodos visitados, mas com vizinhos que ainda não foram todos visitados, começa com o  start
        # closed_list é uma lista de nodos visitados e todos os seus vizinhos também já o foram
        open_list = set([start])  # Adiciona o star á lista de nodos visitados
        closed_list = set([])  # No inicio os nodos que já foram visitados, quem não é nenhum

        # custo é um dicionário onde é guardado o custo acumulado
        # começa com o custo do start
        custo = {}
        custo[start] = 0
         # caminho que é escolhido momentaneamente pelo algoritmo
        caminho=[]
        caminho.append(start)
        while len(open_list) > 0:
            n = None

            # encontraf nodo com a menor heuristica
            for v in open_list:
                if n==None or self.m_h[v]+custo[v] < self.m_h[n]+custo[n]:
                    n = v
                    caminho.append(n)
                    gn = self.calcula_custo(caminho)
                    custo[n] = gn
            if n == None:
                print(
                    'Path does not exist!')  # Caso o nodo não axiste, isto é todos os nodos têm valor maior que o seu pai
                return None

            # para todos os vizinhos  do nodo corrente
            for (m, weight) in self.getNeighbours(n):
                # Se o nodo corrente nao esta na open nem na closed list
                # adiciona-lo à open_list e marcar o antecessor
                if m not in open_list and m not in closed_list:
                    open_list.add(m)

            # remover n da open_list e adiciona-lo à closed_list
            # porque todos os seus vizinhos foram inspecionados
            open_list.remove(n)
            closed_list.add(n)

        print('Path does not exist!')
        return None
