#predict 
#load(file="cfmm.Rdata")
Sys.setlocale("LC_ALL", locale="pt_PT.UTF-8")

#titulo = c("avalia cristiano","hjhjkh","jhhjkhjk")
descricao = c("")
xreviews  = data.frame(titulo,descricao)

xcorpus = Corpus(VectorSource(xreviews$titulo))
xcorpus = tm_map(xcorpus, content_transformer(tolower))
xcorpus = tm_map(xcorpus, removeNumbers)
xcorpus = tm_map(xcorpus, removePunctuation)
xcorpus = tm_map(xcorpus, removeWords, c(stopwords("portuguese")))
xcorpus = tm_map(xcorpus, stripWhitespace)
xcorpus = tm_map(xcorpus, PlainTextDocument)
xcorpus = tm_map(xcorpus, stemDocument)
xdtm <- DocumentTermMatrix(xcorpus)
#http://stackoverflow.com/questions/21790353/dictionary-is-not-supported-anymore-in-tm-package-how-to-emend-code
#Terms(review_dtm_tfidf)

#https://cran.r-project.org/web/packages/tm/vignettes/tm.pdf
#xreview_dtm_tfidf <- DocumentTermMatrix(xcorpus, control = list(weighting = weightTfIdf),)
xreview_dtm_tfidf <- DocumentTermMatrix(xcorpus, list(dictionary = Terms(atividades_dtm_tfidf)))
#xreview_dtm_tfidf <- DocumentTermMatrix(xcorpus)


xreviews = cbind(xreviews, as.matrix(xreview_dtm_tfidf))
xreviews$titulo = NULL
xreviews.test = xreviews
#xpred <- predict(preditor, xreviews.test,  type="class")
xpred <- predict(preditor, xreviews.test)
table(xreviews.test$descricao,xpred,dnn=c("Real","Previsto"))

