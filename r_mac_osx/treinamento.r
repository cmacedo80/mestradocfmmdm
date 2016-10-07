#########################################################
# script de treinamento dos modelos 
# Autor: Cristiano Francis Matos de Macedo
#########################################################

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

library(neuralnet)
library(e1071) 
library(dplyr)
library(party)
library(tm)
library(caret)
library(rpart)
library(rpart.plot)
library(e1071)
library(nnet)
library(wordcloud)
library(Rserve)
library(randomForest)

#########################################################
# Configura??o
#########################################################
#cores
pal2 <- brewer.pal(8,"Dark2")

# comando para permitir a comunica????o com o aplicativo java
# Rserve(args = '--no-save')


#########################################################
# Carga dos dados
#########################################################

Sys.setlocale("LC_ALL", locale="pt_PT.UTF-8")
ag <- read.csv(file="ag.csv", header=TRUE, sep=";",encoding = 'UTF-8',stringsAsFactors = F,nrows = 10000)
pj <- read.csv(file="pj.csv", header=TRUE, sep=";",encoding = 'UTF-8',stringsAsFactors = F,nrows = 10000)


totalAmostras <- min(nrow(ag),nrow(pj))
percent60 <- round(totalAmostras * 0.6);
percent80 <- round(totalAmostras * 0.8);

set.seed(123)
indices_ag <- sample( 1:totalAmostras, totalAmostras)
set.seed(123)
indices_pj <- sample( (totalAmostras+1):(totalAmostras*2), totalAmostras)

ag.tr <- indices_ag[1:percent60]     # %60
ag.va <- indices_ag[(percent60+1):percent80]  # %20
ag.te <- indices_ag[(percent80+1):totalAmostras]  # %20

pj.tr <- indices_pj[1:percent60]     # %60
pj.va <- indices_pj[(percent60+1):percent80]  # %20
pj.te <- indices_pj[(percent80+1):totalAmostras]  # %20


#########################################################
# Gera??o da WordCloud
#########################################################

#  ag_corpus = Corpus(VectorSource(ag$titulo))
#  ag_corpus = tm_map(ag_corpus, content_transformer(tolower))
#  ag_corpus = tm_map(ag_corpus, removeNumbers)
#  ag_corpus = tm_map(ag_corpus, removePunctuation)
#  ag_corpus = tm_map(ag_corpus, removeWords, c(stopwords("portuguese")))
#  ag_corpus =  tm_map(ag_corpus, stripWhitespace)
#  ag_corpus =  tm_map(ag_corpus, PlainTextDocument)
#  ag_corpus =  tm_map(ag_corpus, stemDocument)
#  wordcloud(ag_corpus,max.words = 100, min.freq = 2,random.order = FALSE,colors=pal2)
# 
#  pj_corpus = Corpus(VectorSource(pj$titulo))
#  pj_corpus = tm_map(pj_corpus, content_transformer(tolower))
#  pj_corpus = tm_map(pj_corpus, removeNumbers)
#  pj_corpus = tm_map(pj_corpus, removePunctuation)
#  pj_corpus = tm_map(pj_corpus, removeWords, c(stopwords("portuguese")))
#  pj_corpus =  tm_map(pj_corpus, stripWhitespace)
#  pj_corpus =  tm_map(pj_corpus, PlainTextDocument)
#  pj_corpus =  tm_map(pj_corpus, stemDocument)
# wordcloud(pj_corpus,max.words = 100, min.freq = 2,random.order = FALSE,colors=pal2)

#########################################################
# Prepara??o das bases de treinamento, validacao e teste
#########################################################
atividades  = rbind(ag,pj)

atividades_corpus = Corpus(VectorSource(atividades$titulo))
atividades_corpus = tm_map(atividades_corpus, content_transformer(tolower))
atividades_corpus = tm_map(atividades_corpus, removeNumbers)
atividades_corpus = tm_map(atividades_corpus, removePunctuation)
atividades_corpus = tm_map(atividades_corpus, removeWords, c(stopwords("portuguese")))
atividades_corpus = tm_map(atividades_corpus, stripWhitespace)
atividades_corpus = tm_map(atividades_corpus, stemDocument)
atividades_corpus = tm_map(atividades_corpus, PlainTextDocument)
#atividades_dtm <- DocumentTermMatrix(atividades_corpus)
#atividades_dtm = removeSparseTerms(atividades_dtm, 0.99)
#findFreqTerms(atividades_dtm, 2)

#atividades_dtm_tfidf <- DocumentTermMatrix(atividades_corpus, control = list(weighting = weightTfIdf))
atividades_dtm_tfidf <- DocumentTermMatrix(atividades_corpus)
atividades_dtm_tfidf

atividades_dtm_tfidf = removeSparseTerms(atividades_dtm_tfidf, 0.99)
#findFreqTerms(atividades_dtm_tfidf, 1)

atividades$titulo = NULL
atividades = cbind(atividades, as.matrix(atividades_dtm_tfidf))
atividades$descricao = as.factor(atividades$descricao)

#set.seed(1234)
#indices = sample(3, nrow(atividades) , repl = TRUE,prob = c(0.6,0.2,0.2))

atividades.train<-rbind(atividades[ag.tr,],atividades[pj.tr,])
atividades.validation<-rbind(atividades[ag.va,],atividades[pj.va,])
atividades.test<-rbind(atividades[ag.te,],atividades[pj.te,])

#atividades.train      <- atividades[indices == 1,]
#atividades.validation <- atividades[indices == 2,]
#atividades.test       <- atividades[indices == 3,]

#ag_indices <- which(atividades$descricao =="acaogerencial")
#pj_indices <- which(atividades$descricao =="projeto")

#atividades[ag_indices,]
#
# Treinamento e predi??o com a arvore de decisao
atividades.tree = rpart(descricao~.,  method = "class", data = atividades.train);  
pred.tree = predict(atividades.tree, atividades.validation,  type="class")
# table(atividades.validation$descricao,pred.tree,dnn=c("Real","Previsto"))
caret::confusionMatrix(table(atividades.validation$descricao,pred.tree,dnn=c("Real","Previsto")))

# Treinamento e predi??o com naives bayes
atividades.naiveBayes <- naiveBayes(descricao ~ ., data = atividades.train)
pred.naiveBayes <- predict(atividades.naiveBayes,atividades.validation)
#table(atividades.validation$descricao,pred=pred.naiveBayes,dnn=c("Real","Previsto"))
caret::confusionMatrix(table(atividades.validation$descricao,pred=pred.naiveBayes,dnn=c("Real","Previsto")))
#table(atividades.validation$descricao,pred.naiveBayes,dnn=c("Obs","Pred"))

# Treinamento e predi??o com random folrest
atividades.randomForest <- randomForest(descricao ~ .,  data=atividades.train, importance=TRUE,   ntree=2000)
pred.randomForest <- predict(atividades.randomForest, atividades.validation)
#table(atividades.validation$descricao,pred=pred.randomForest,dnn=c("Real","Previsto"))
caret::confusionMatrix(table(atividades.validation$descricao,pred=pred.randomForest,dnn=c("Real","Previsto")))

# Treinamento e predi??o com SVM
atividades.svm = svm(descricao~., data = atividades.train);
pred.svm = predict(atividades.svm, atividades.validation)
#table(atividades.validation$descricao,pred.svm,dnn=c("Real","Previsto"))
caret::confusionMatrix(table(atividades.validation$descricao,pred.svm,dnn=c("Real","Previsto")))

# Predi??o final com a base de teste com o random forest
pred.randomForest <- predict(atividades.randomForest, atividades.test)
caret::confusionMatrix(table(atividades.validation$descricao,pred=pred.randomForest,dnn=c("Real","Previsto")))

#save(preditor,atividades_dtm_tfidf,file="modelo.RData")
#save.image("modelo.RDAta")
preditor <- atividades.randomForest;
save(preditor, atividades_dtm_tfidf, file="var.RData")
#save.image(file="cfmm.RData")


