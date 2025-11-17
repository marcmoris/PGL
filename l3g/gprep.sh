# /T/Complilation des programme "C" pour INTERBASE
#
#    Denis Pouliot/1999-06-02
#    Etat.........: [Terminer]
#    Description..: Reçoit comme paramètre le nom du programme sans extension
#                   L'extension du programme "C" doit être ".e" 
#                   Crée un exécutable dans PG_L3G
#   Particularité : Les libraries sont différentes sur HP versus les autres 
#                   
#

cd $PG_DATA
gpre -e -r -m $PG_L3G/${1}.e

serveur=`uname | grep -i HP`
if [ -n "$serveur" ]
then
  #
  #  C'est un HP
  #
  cc -DUNIX -v $PG_L3G/${1}.c -o $PG_L3G/${1}.exe -lgds -ldld -ltermcap -lm
else
  cc -DUNIX -# $PG_L3G/${1}.c -o $PG_L3G/${1}.exe -lgds -lm 
fi
\rm $PG_L3G/${1}.c
cd $PG_L3G
