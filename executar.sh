diretorio=$(pwd)/r
echo $diretorio
# Rscript r/javabeforeapp.r
comando="java -jar  bin/appdm.jar ${diretorio//[$'\t\r\n']} outro"
eval $comando
