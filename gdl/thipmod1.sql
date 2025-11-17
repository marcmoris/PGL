set term !! ;
create trigger THIPMOD1 for MCHIS_PROJET
before update
position 1 as
/* Ajout dans la relation MCHIS_PROJET
 ;
 ;/P/ Programmeur..: Steeve Duguay
 ;    Date Création: 7 Février 1995
 ;  
 ;    Description..: On peut faire que des ajouts dans cette table, ils sont
 ;                   faits lors des journalisations par des programmes QTP.
 ;
 ;                   Mise à jour des budgets comptables des projets et      
 ;                   sous-projets ainsi que pour l'année financière.
 ;
 ;/M/ François Déry, 3 juin 1999
 ;      Conversion en ISQL.
*/
Declare Variable t_pecann char(2);
Declare Variable t_pecnum char(2);
Declare Variable t_coddc  char(1);
/* Mise à jour des montants */
Declare Variable t_ree    Double Precision;
Declare Variable t_ree01  Double Precision;
Declare Variable t_ree02  Double Precision;
Declare Variable t_ree03  Double Precision;
Declare Variable t_ree04  Double Precision;
Declare Variable t_ree05  Double Precision;
Declare Variable t_ree06  Double Precision;
Declare Variable t_ree07  Double Precision;
Declare Variable t_ree08  Double Precision;
Declare Variable t_ree09  Double Precision;
Declare Variable t_ree10  Double Precision;
Declare Variable t_ree11  Double Precision;
Declare Variable t_ree12  Double Precision;
Declare Variable t_ree13  Double Precision;
Declare Variable t_ree14  Double Precision;

begin
/*
  Recherche des informations pour la mise à jour
*/
  t_pecann = prosig_extract(1,2,NEW.PECCLE," ");
  t_pecnum = prosig_extract(3,2,NEW.PECCLE," ");
  Select CPTCODDC
    From MCCOMPTE
   Where CPTCLE = NEW.CPTCLE
    Into :t_coddc;
/*
  Calcul des montants à mettre à jour
*/
  if ( "C" = :t_coddc )
  then t_ree = NEW.HIPMNTCRT - OLD.HIPMNTCRT - NEW.HIPMNTDBT + OLD.HIPMNTDBT;
  else t_ree = NEW.HIPMNTDBT - OLD.HIPMNTDBT - NEW.HIPMNTCRT + OLD.HIPMNTCRT;

  if ( "01" = :t_pecnum )
  then t_ree01 = t_ree;
  else t_ree01 = 0;
  if ( "02" = :t_pecnum )
  then t_ree02 = t_ree;
  else t_ree02 = 0;
  if ( "03" = :t_pecnum )
  then t_ree03 = t_ree;
  else t_ree03 = 0;
  if ( "04" = :t_pecnum )
  then t_ree04 = t_ree;
  else t_ree04 = 0;
  if ( "05" = :t_pecnum )
  then t_ree05 = t_ree;
  else t_ree05 = 0;
  if ( "06" = :t_pecnum )
  then t_ree06 = t_ree;
  else t_ree06 = 0;
  if ( "07" = :t_pecnum )
  then t_ree07 = t_ree;
  else t_ree07 = 0;
  if ( "08" = :t_pecnum )
  then t_ree08 = t_ree;
  else t_ree08 = 0;
  if ( "09" = :t_pecnum )
  then t_ree09 = t_ree;
  else t_ree09 = 0;
  if ( "10" = :t_pecnum )
  then t_ree10 = t_ree;
  else t_ree10 = 0;
  if ( "11" = :t_pecnum )
  then t_ree11 = t_ree;
  else t_ree11 = 0;
  if ( "12" = :t_pecnum )
  then t_ree12 = t_ree;
  else t_ree12 = 0;
  if ( "13" = :t_pecnum )
  then t_ree13 = t_ree;
  else t_ree13 = 0;
  if ( "14" = :t_pecnum )
  then t_ree14 = t_ree;
  else t_ree14 = 0;

/*
  Mise à jour du budget comptable du projet.
  Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
/* Mise à jour */
  Update GPPRO_BDG_CTB Set PBCMNTREE = PBCMNTREE + :t_ree,
                           PBCDATREE = "TODAY",
                           PBCUSRREE = USER
                Where CIECLE = NEW.CIECLE
                  And PRJCLE = NEW.PRJCLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;

  Update GPPRA_BDG_CTB Set PACMNTREE = PACMNTREE + :t_ree,
                           PACDATREE = "TODAY",
                           PACUSRREE = USER
                Where CIECLE = NEW.CIECLE
                  And PRJCLE = NEW.PRJCLE
                  And PRACLE = NEW.PRACLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;

  Update IMIMM_BDG_CTB Set IBCMNTREE = IBCMNTREE + :t_ree,
                           IBCDATREE = "TODAY",
                           IBCUSRREE = USER
                Where CIECLE = NEW.CIECLE
                  And IMMCLE = NEW.IMMCLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;

  Update GPPBC_ANNEE Set PBAMNTREE1  = PBAMNTREE1  + :t_ree01,
                         PBAMNTREE2  = PBAMNTREE2  + :t_ree02,
                         PBAMNTREE3  = PBAMNTREE3  + :t_ree03,
                         PBAMNTREE4  = PBAMNTREE4  + :t_ree04,
                         PBAMNTREE5  = PBAMNTREE5  + :t_ree05,
                         PBAMNTREE6  = PBAMNTREE6  + :t_ree06,
                         PBAMNTREE7  = PBAMNTREE7  + :t_ree07,
                         PBAMNTREE8  = PBAMNTREE8  + :t_ree08,
                         PBAMNTREE9  = PBAMNTREE9  + :t_ree09,
                         PBAMNTREE10 = PBAMNTREE10 + :t_ree10,
                         PBAMNTREE11 = PBAMNTREE11 + :t_ree11,
                         PBAMNTREE12 = PBAMNTREE12 + :t_ree12,
                         PBAMNTREE13 = PBAMNTREE13 + :t_ree13,
                         PBAMNTREE14 = PBAMNTREE14 + :t_ree14
                Where CIECLE = NEW.CIECLE
                  And PBAANN = :t_pecann
                  And PRJCLE = NEW.PRJCLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;

  Update GPPAC_ANNEE Set PAAMNTREE1  = PAAMNTREE1  + :t_ree01,
                         PAAMNTREE2  = PAAMNTREE2  + :t_ree02,
                         PAAMNTREE3  = PAAMNTREE3  + :t_ree03,
                         PAAMNTREE4  = PAAMNTREE4  + :t_ree04,
                         PAAMNTREE5  = PAAMNTREE5  + :t_ree05,
                         PAAMNTREE6  = PAAMNTREE6  + :t_ree06,
                         PAAMNTREE7  = PAAMNTREE7  + :t_ree07,
                         PAAMNTREE8  = PAAMNTREE8  + :t_ree08,
                         PAAMNTREE9  = PAAMNTREE9  + :t_ree09,
                         PAAMNTREE10 = PAAMNTREE10 + :t_ree10,
                         PAAMNTREE11 = PAAMNTREE11 + :t_ree11,
                         PAAMNTREE12 = PAAMNTREE12 + :t_ree12,
                         PAAMNTREE13 = PAAMNTREE13 + :t_ree13,
                         PAAMNTREE14 = PAAMNTREE14 + :t_ree14
                Where PAAANN = :t_pecann
                  And PRJCLE = NEW.PRJCLE
                  And PRACLE = NEW.PRACLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;

  Update IMIBC_ANNEE Set IBAMNTREE1  = IBAMNTREE1  + :t_ree01,
                         IBAMNTREE2  = IBAMNTREE2  + :t_ree02,
                         IBAMNTREE3  = IBAMNTREE3  + :t_ree03,
                         IBAMNTREE4  = IBAMNTREE4  + :t_ree04,
                         IBAMNTREE5  = IBAMNTREE5  + :t_ree05,
                         IBAMNTREE6  = IBAMNTREE6  + :t_ree06,
                         IBAMNTREE7  = IBAMNTREE7  + :t_ree07,
                         IBAMNTREE8  = IBAMNTREE8  + :t_ree08,
                         IBAMNTREE9  = IBAMNTREE9  + :t_ree09,
                         IBAMNTREE10 = IBAMNTREE10 + :t_ree10,
                         IBAMNTREE11 = IBAMNTREE11 + :t_ree11,
                         IBAMNTREE12 = IBAMNTREE12 + :t_ree12,
                         IBAMNTREE13 = IBAMNTREE13 + :t_ree13,
                         IBAMNTREE14 = IBAMNTREE14 + :t_ree14
                Where IBAANN = :t_pecann
                  And IMMCLE = NEW.IMMCLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;
end !!
set term ; !!
