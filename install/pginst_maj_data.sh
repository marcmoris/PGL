#!/bin/sh
#
# Ce script sera exécuté pour chaque répertoire ** data **
# trouvé pour l'application.
#
# Vous êtes à l'intérieur de la commande 'more'
# utilisez la barre d'espacement pour continuer le défilement.
#
# Vous trouverez le résultat de chaque exécution dans le
# répertoire PG_TEMP, que vous pourrez consulter par la suite.
# Le nom du log est PG_TEMP/inst_data*.log.
#
# Si vous devez la reprendre manuellement, utiliser la commande:
#     '/gra/pro_appl/pgl/install/pginst_maj_data.sh /appl_root/dataXXX' 
#
# où appl_root représente le chemin complet du répertoire data, et
#    dataXXX, le nom physique du répertoire data à traiter
#
if [ -z "$1" ]
then
  echo "Paramètre 1 obligatoire"
  exit
fi

if [ ! -d "$1" ]
then
  echo "Répertoire non trouvé"
  exit
fi

if [ -f "$1/pginst_script_done" ]
then
  echo "Le traitement a déjà été exécuté"
  exit
fi

PG_DATA=$1
export PG_DATA
echo "Traitement en cours de $PG_DATA"
touch $PG_DATA/pginst_script_done

cd $PG_DATA
echo "Mise à jour de la base"
 
echo Traitement de 991101-094053.gdl
isql <<FINGDL_991101-094053
connect dict.gdb;
                                                                               
create domain BLRDATRESDEB     date;                                           
                                                                               
create domain BLRDATRESFIN     date;                                           
                                                                               
create domain BLRUSRRES        char(10);                                       
                                                                               
alter table IFBLOC                                                             
     drop  BLCDATRESDEB    ;                                                   
                                                                               
alter table IFBLOC                                                             
     drop  BLCDATRESFIN    ;                                                   
                                                                               
alter table IFBLOC                                                             
     drop  BLCUSRRES       ;                                                   
FINGDL_991101-094053
 
echo Traitement de 991101-094142.gdl
isql <<FINGDL_991101-094142
connect dict.gdb;
                                                                               
drop domain BLCDATRESDEB     ;                                                 
                                                                               
drop domain BLCDATRESFIN     ;                                                 
                                                                               
drop domain BLCUSRRES        ;                                                 
FINGDL_991101-094142
 
echo Traitement de 991101-094618.gdl
isql <<FINGDL_991101-094618
connect dict.gdb;
                                                                               
create table IFRESERVATION (                                                   
  TGRCODGRA        TGRCODGRA,                                                  
  IFCCLE           IFCCLE,                                                     
  BLCCLE           BLCCLE,                                                     
  BLCRED           BLCRED,                                                     
  BLRDATRESDEB     BLRDATRESDEB,                                               
  BLRDATRESFIN     BLRDATRESFIN,                                               
  BLRUSRRES        BLRUSRRES                                                   
  );                                                                           
                                                                               
                                                                               
                                                                               
create unique    ascending   index BLR_U01          on IFRESERVATION    (      
     TGRCODGRA,                                                                
     IFCCLE,                                                                   
     BLCCLE,                                                                   
     BLCRED);                                                                  
FINGDL_991101-094618
 
echo Traitement de 991101-101044.gdl
isql <<FINGDL_991101-101044
connect dict.gdb;
                                                                               
alter table IFRESERVATION                                                      
     add     CIECLE           CIECLE          ;                                
                                                                               
drop index BLR_U01         ;                                                   
                                                                               
create unique    ascending   index BLR_U01          on IFRESERVATION    (      
     CIECLE,                                                                   
     TGRCODGRA,                                                                
     IFCCLE,                                                                   
     BLCCLE,                                                                   
     BLCRED);                                                                  
FINGDL_991101-101044
 
echo Traitement de 991102-093044.gdl
isql <<FINGDL_991102-093044
connect dict.gdb;
                                                                               
create table IFHISTO_RESERV (                                                  
  CIECLE           CIECLE,                                                     
  TGRCODGRA        TGRCODGRA,                                                  
  IFCCLE           IFCCLE,                                                     
  BLCCLE           BLCCLE,                                                     
  BLCRED           BLCRED,                                                     
  BLRDATRESDEB     BLRDATRESDEB,                                               
  BLRDATRESFIN     BLRDATRESFIN,                                               
  BLRUSRRES        BLRUSRRES                                                   
  );                                                                           
                                                                               
                                                                               
                                                                               
create           descending  index IFH_R01          on IFHISTO_RESERV   (      
     CIECLE,                                                                   
     TGRCODGRA,                                                                
     IFCCLE,                                                                   
     BLCCLE,                                                                   
     BLCRED);                                                                  
FINGDL_991102-093044
 
echo Traitement de 991116-202524.gdl
isql <<FINGDL_991116-202524
connect dict.gdb;
                                                                               
create domain BLCIFLORI        char(1);                                        
                                                                               
create domain BLCFOUORI        char(1);                                        
                                                                               
alter table IFBLOC                                                             
     add     BLCIFLORI        BLCIFLORI       ;                                
                                                                               
alter table IFBLOC                                                             
     add     BLCFOUORI        BLCFOUORI       ;                                
FINGDL_991116-202524
 
echo Traitement de 991117-114454.gdl
isql <<FINGDL_991117-114454
connect dict.gdb;
                                                                               
create domain FTRFLGBLC        char(2);                                        
                                                                               
alter table PDFACTURE                                                          
     add     FTRFLGBLC        FTRFLGBLC       ;                                
FINGDL_991117-114454
 
echo Traitement de 991118-144503.gdl
isql <<FINGDL_991118-144503
connect dict.gdb;
                                                                               
create domain FTRFLGIMP        char(1);                                        
                                                                               
alter table PDFACTURE                                                          
     add     FTRFLGIMP        FTRFLGIMP       ;                                
FINGDL_991118-144503
 
cd $PG_INSTALL/prep_unload
echo Traitement de inst_relgs.qts
qtp subdict=search owner= nolist <<FIN_QTPINST
use /gra/pro_appl/pgl/install/inst_relgs.qts nolist
go
exit
FIN_QTPINST
 
echo Traitement de inst_relspec.qts
qtp subdict=search owner= nolist <<FIN_QTPINST
use /gra/pro_appl/pgl/install/inst_relspec.qts nolist
go
exit
FIN_QTPINST
 
#********************* fin du script *********************
