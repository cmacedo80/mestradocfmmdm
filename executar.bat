rcmd BATCH r\javabeforeapp.r
set diretorio=%cd%
set diretorio=%diretorio:\=/%
echo %diretorio%
java -jar  bin\appdm.jar %diretorio%/r
