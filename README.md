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

$ java -cp frontend-1.jar br.cfmm.dm.Frontend

