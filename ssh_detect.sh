#!/bin/bash

#### SHELL SCRIPT PARA DETECCAO DE LOGIN SSH ###########
#                                                      #
# Verifica no auth.log a existencia da frase:          #
#                                                      #
# pam_unix(sshd:session): session opened for user root #
#                                                      #
# Intuito principal do script e ser utilizado com o    #
# userparameter do zabbix                              #
# O script retorna 0 se nao ha sessao ssh aberta       #
# Caso haja sessao ssh aberta o script retorna 1       #
########################################################

# A variavel MYLINE precisa ser alterada para que contenha
# uma data/timestamp valida dentro do arquivo auth.log

MYSCRIPT="/nome_deste_script.sh"
MYLINE="Oct 19 10:50:17"
MYTARGET="/var/log/auth.log"
MYLOG="/tmp/zabbix/temp.log"
MYWORD="pam_unix(sshd:session): session opened for user root"
LINHA="0"


#cria arquivo de log e pasta se nao existente
mkdir /tmp/zabbix &> /dev/null
touch $MYLOG &> /dev/null


# da um grep pelas linhas que contem o conteudo de MYLINE
# no AUTH.LOG, cortando informacoes desnecessarias 
#posteriormente
LINHA=$(grep -n "$MYLINE" $MYTARGET | tail -1 | cut -d ':' -f1)


#se linha nao nulo (-n) ira executar a funcao do corte.
if [ -n $LINHA ]
then
    #sed para cortar a LINHA referente a MYLINE
    #e levar para o MYLOG apenas o que ainda nao 
    #foi lido pelo script
    sed -e "1,$LINHA d" $MYTARGET > $MYLOG
else
    LINHA = "2"
    sed -e "1,$LINHA d" $MYTARGET > $MYLOG
fi


#funcao que escaneia para localizar a string desejada
fnSCAN(){
    SCAN_RETURN=$(grep -o "$MYWORD" $MYLOG)
    if [ ! -z "$SCAN_RETURN" ]
    then
        echo "1"
        MYLINE=$(sed -e :a -e '$q;N;2;$D;ba' $MYLOG | awk '{print $1" "$2" "$3}')

    else
        echo "0"
    fi
}
fnSCAN


# substitui a linha na frente da variavel MYLINE
# para que nao localize informacoes repetidas
sed -i "s/^MYLINE=.*/MYLINE=\"$MYLINE\"/" $MYSCRIPT
