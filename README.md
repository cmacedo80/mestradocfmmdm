# Montando o ambiente

1 Baixar o R 

2 Baixar RStudio
```
$ git clone https://github.com/cmacedo80/mestradocfmmdm.git
```
3 Colocar o R no path do windows
`` 
C:\Program Files\R\R-3.3
`` 

4 Fazer o download dos packages, 

```
  #install.packages('Rserve')
  #install.packages('tm')
  #install.packages('neuralnet')
  #install.packages('e1071')
  #install.packages('dplyr')
  #install.packages('party')
  #install.packages('caret')
  #install.packages('rpart')
  #install.packages('rpart.plot')
  #install.packages('e1071')
  #install.packages('nnet')
  #install.packages('wordcloud')
  #install.packages('randomForest')
  #install.packages('SnowballC')
```

# Aplicativo de mineração de texto

##Como realizar o treinamento?

Você ira precisar de dos arquivos com a base de dados ag.csv e pj.csv, a baixo o exemplo dos arquivos:

###ag.csv
titulo;descricao
Minha Acao Gerencial 1;acaogerencial
Minha Acao Gerencial 2;acaogerencial

###pj.csv
titulo;descricao
Meu projeto 1;projeto
Meu projeto 2;projeto


rcmd BATCH treinamento.r

##Como executar o aplicativo?

$ java -jar "/Users/.../appdm.jar" path_to_r_scripts


