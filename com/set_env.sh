#ISC_USER=$LOGNAME     ; export ISC_USER
ISC_PASSWORD=applicat ; export ISC_PASSWORD
#
# Enlève les messages francais sauf pour quick
#
unset QKDMSG
unset QTPMSG
unset QUIZMSG
unset QSHOMSG
unset PDLMSG
unset QUTLMSG
#
# Setup de touche pour quick (qkgo)
#
#PHTICRS=$PG_EXF/vt100
#export PHTICRS
#
# Option de compile et d'exécution
#
QDESIGN_OPT="subdict=search"
QSHOW_OPT="subdict=search"
QUICK_OPT="entryrecall"
QUIZ_OPT="subdict=search"
QTP_OPT="subdict=search"
PDL_OPT=""

export QDESIGN_OPT
export QSHOW_OPT  
export QUICK_OPT  
export QUIZ_OPT   
export PDL_OPT    
export QTP_OPT    

#
# Sert dans l'open name de fichier séquentielle.
#
PDIMP_DOC=fct_$$
export PDIMP_DOC
GPFRM_D=frm_$$
export GPFRM_D
#
# Ne sert pas pour le moment, assigner à la bonne valeur si le client
# utilise les passerelles des comptes à recevoir et facturation
#
PG_PASS_CR=$PG_TEMP/
export PG_PASS_CR
PG_PASS_FA=$PG_TEMP/
export PG_PASS_FA
