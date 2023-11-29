import sklearn as skl
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn import preprocessing


# Load csv 
df = pd.read_csv('sentiment_analysis.csv')

print(df["birthday"])

# See the types of data 
# df.info()

# T1-b) : Dispersão estatística
print(df.describe())

# Change the categorial type of some data to numerical type 
df['Sentiment Analysis'] = df['Sentiment Analysis'].astype('category')
df['Sentiment Analysis'] = df['Sentiment Analysis'].cat.codes

df['MaritalStatus'] = df['MaritalStatus'].astype('category')
df['MaritalStatus'] = df['MaritalStatus'].cat.codes

df['Gender'] = df['Gender'].astype('category')
df['Gender'] = df['Gender'].cat.codes

# Drop some columns we don't need 
del df['Products']
del df['birthday']

# print(df)

# T1-a) e c) : Tendência central e Correlação entre features 
corr_matrix = df.corr(numeric_only= True)
f,ax = plt.subplots(figsize=(12,10))
sns.heatmap(corr_matrix,vmin = -1,vmax = 1,square = True,annot = True)
#  T2 - Criar plots para visualização dos dados
plt.show()  # Correlation Matrix

print(f"Histogram:{df['Sentiment Analysis'].hist()}")
plt.show() # Histogram - Sentiment Analysis

print(f"Skewness:{df['Sentiment Analysis'].skew()}")
print(f"Kurtosis:{df['Sentiment Analysis'].kurt()}")

# sns.pairplot(df,hue="Sentiment Analysis")
# plt.show() # Relation between all variables

# T3 - Aplicar diferentes tratamentos de dados como por exemplo:
# a. Tratar valores em falta 
print(df.isna().sum())   # Não há valores em falta 

# b. Remover registos duplicados
print(df.duplicated().sum()) # Quantos duplicados existem 
print(df.drop_duplicates(inplace=True))
print(df.info())

# c. Criar um atributo «age_binned» como resultado da criação de 3 bins de igual frequência sobre a feature «age»;
# Como a variavel age tem no maximo valor igual a 100, logo os intervalos serão: [0,33.33,66.66,100]
bins = [0,33.33,66.66,100]
df["age_binned"] = pd.cut(df["Age"],bins)
print(df)

# d. Para cada registo, extrair o ano, mês e dia da semana da feature «birthday»;
