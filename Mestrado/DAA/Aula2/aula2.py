import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import confusion_matrix
from sklearn.metrics import recall_score
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import roc_auc_score
from sklearn.metrics import roc_curve
from sklearn.metrics import f1_score
from sklearn.metrics import fbeta_score
from sklearn.metrics import mean_absolute_error
from sklearn.metrics import mean_squared_error
#USING CROSS VALIDATION
from sklearn.model_selection import cross_val_score

# Leitura do ficheiro csv ContractData.csv 
dfCSV = pd.read_csv('ContractData.csv')
# Leitura do ficheiro excel CallsData.xls
dfXLS = pd.read_excel('CallsData.xls')

# Para imprimir as primeiras 5 linhas do dataset em questão 
# print(dfXLS.head()) 

# Para dar merge das duas tabelas, ficando apenas com uma só. Neste caso utiliza-se o inner join para juntar todos os dados das duas tabelas, sem exceção -> T1
df = pd.merge(dfCSV, dfXLS, how='inner', on=['Phone','Area Code']) 

# Para imprimir o cabeçalho da tabela 
# print(df.head())

# print(df.describe())
# print(df.shape)
# print(df.dtypes)

# Como alterar o atributo 'Churn' de inteiro para categórico -> T1 
df['Churn'] = df['Churn'].astype('category') #.apply(str)


# Para fazer o modelo, não podemos ter dados categóricos. Assim estamos a dar drop dos mesmos
x = df.drop(['Churn','State','Phone'], axis=1)
# Colocar o que queremos prever no eixo do y 
y = df['Churn'].to_frame()

# Criação do x de teste e treino, tal como, o y de treino e de teste -> T2 
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.2, random_state=2021)

# Criação da árvore de classificação para o modelo de decisão (A seed tem de ser igual à de cima)-> T2 
clf = DecisionTreeClassifier(criterion = 'gini',max_depth=10,random_state=2021)   # O criterion e o max_depth podem ser alterados 

# Para fazer k-Fold Cross validation -> T2 
scores = cross_val_score(clf,x,y,cv=10)

print("Os scores são estes:")
print(scores)
print("RESULT: %0.2f accuracy with a standart deviation of %0.2f" % (scores.mean(), scores.std()))

# Treino do modelo de aprendizagem 
clf.fit(x_train, y_train)

# Previsões do modelo de aprendizagem tendo como base o modelo de aprendizagem treinado mais os dados de teste 
predict = clf.predict(x_test)

# Criação da matriz de confusão 
confusion_matrix = confusion_matrix(y_test, predict)

print ("Matriz de confusão :")
print(confusion_matrix)


# Cálculo da accuracy do modelo de aprendizagem
accuracy = accuracy_score(y_test, predict)

print("A accuracy deste modelo é de :")
print(str(accuracy*100)+"%")


# Cálculo da precisão do modelo de aprendizagem
precision = precision_score(y_test, predict)

print("A precisão deste modelo é de :")
print(precision)


# Cálculo da recall do modelo de aprendizagem
recall = recall_score(y_test, predict)

print("A recall deste modelo é de :")
print(recall)


# Cálculo da f1_macro do modelo de aprendizagem
f1_macro = f1_score(y_test,predict,average="macro")

print("A f1_macro deste modelo é de :")
print(f1_macro)
