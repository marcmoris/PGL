set term !! ;
create trigger THPEMOD for MCHIS_PROJET_ENG
before update
position 0 as
/* Ajout dans la relation MCHIS_PROJET_ENG
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
Declare Variable t_eng    Double Precision;
Declare Variable t_eng01  Double Precision;
Declare Variable t_eng02  Double Precision;
Declare Variable t_eng03  Double Precision;
Declare Variable t_eng04  Double Precision;
Declare Variable t_eng05  Double Precision;
Declare Variable t_eng06  Double Precision;
Declare Variable t_eng07  Double Precision;
Declare Variable t_eng08  Double Precision;
Declare Variable t_eng09  Double Precision;
Declare Variable t_eng10  Double Precision;
Declare Variable t_eng11  Double Precision;
Declare Variable t_eng12  Double Precision;
Declare Variable t_eng13  Double Precision;
Declare Variable t_eng14  Double Precision;

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
  if ( :t_coddc = "C" )
  then t_eng = NEW.HPEMNTCRT - OLD.HPEMNTCRT -
               NEW.HPEMNTDBT + OLD.HPEMNTDBT;
  else t_eng = NEW.HPEMNTDBT - OLD.HPEMNTDBT -
               NEW.HPEMNTCRT + OLD.HPEMNTCRT;

  if ( "01" = :t_pecnum )
  then t_eng01 = t_eng;
  else t_eng01 = 0;
  if ( "02" = :t_pecnum )
  then t_eng02 = t_eng;
  else t_eng02 = 0;
  if ( "03" = :t_pecnum )
  then t_eng03 = t_eng;
  else t_eng03 = 0;
  if ( "04" = :t_pecnum )
  then t_eng04 = t_eng;
  else t_eng04 = 0;
  if ( "05" = :t_pecnum )
  then t_eng05 = t_eng;
  else t_eng05 = 0;
  if ( "06" = :t_pecnum )
  then t_eng06 = t_eng;
  else t_eng06 = 0;
  if ( "07" = :t_pecnum )
  then t_eng07 = t_eng;
  else t_eng07 = 0;
  if ( "08" = :t_pecnum )
  then t_eng08 = t_eng;
  else t_eng08 = 0;
  if ( "09" = :t_pecnum )
  then t_eng09 = t_eng;
  else t_eng09 = 0;
  if ( "10" = :t_pecnum )
  then t_eng10 = t_eng;
  else t_eng10 = 0;
  if ( "11" = :t_pecnum )
  then t_eng11 = t_eng;
  else t_eng11 = 0;
  if ( "12" = :t_pecnum )
  then t_eng12 = t_eng;
  else t_eng12 = 0;
  if ( "13" = :t_pecnum )
  then t_eng13 = t_eng;
  else t_eng13 = 0;
  if ( "14" = :t_pecnum )
  then t_eng14 = t_eng;
  else t_eng14 = 0;
/*
  Mise à jour du budget comptable du projet.
*/
  Update GPPRO_BDG_CTB Set PBCMNTENG = PBCMNTENG + :t_eng,
                           PBCDATENG = "TODAY",
                           PBCUSRENG = USER
                Where CIECLE = NEW.CIECLE
                  And PRJCLE = NEW.PRJCLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;
/*
    Mise à jour du budget comptable du sou-projet.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Update GPPRA_BDG_CTB Set PACMNTENG = PACMNTENG + :t_eng,
                           PACDATENG = "TODAY",
                           PACUSRENG = USER
                Where CIECLE = NEW.CIECLE
                  And PRJCLE = NEW.PRJCLE
                  And PRACLE = NEW.PRACLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;
/*
    Mise à jour du budget comptable de l'immobilisation.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Update IMIMM_BDG_CTB Set IBCMNTENG = IBCMNTENG + :t_eng,
                           IBCDATENG = "TODAY",
                           IBCUSRENG = USER
                Where CIECLE = NEW.CIECLE
                  And IMMCLE = NEW.IMMCLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;
/*
    Mise à jour du budget comptable du projet pour l'année financière.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Update GPPBC_ANNEE Set PBAMNTENG1  = PBAMNTENG1  + :t_eng01,
                         PBAMNTENG2  = PBAMNTENG2  + :t_eng02,
                         PBAMNTENG3  = PBAMNTENG3  + :t_eng03,
                         PBAMNTENG4  = PBAMNTENG4  + :t_eng04,
                         PBAMNTENG5  = PBAMNTENG5  + :t_eng05,
                         PBAMNTENG6  = PBAMNTENG6  + :t_eng06,
                         PBAMNTENG7  = PBAMNTENG7  + :t_eng07,
                         PBAMNTENG8  = PBAMNTENG8  + :t_eng08,
                         PBAMNTENG9  = PBAMNTENG9  + :t_eng09,
                         PBAMNTENG10 = PBAMNTENG10 + :t_eng10,
                         PBAMNTENG11 = PBAMNTENG11 + :t_eng11,
                         PBAMNTENG12 = PBAMNTENG12 + :t_eng12,
                         PBAMNTENG13 = PBAMNTENG13 + :t_eng13,
                         PBAMNTENG14 = PBAMNTENG14 + :t_eng14
                Where CIECLE = NEW.CIECLE
                  And PBAANN = :t_pecann
                  And PRJCLE = NEW.PRJCLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;
/*
    Mise à jour du budget comptable du projet pour l'année financière.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Update GPPAC_ANNEE Set PAAMNTENG1  = PAAMNTENG1  + :t_eng01,
                         PAAMNTENG2  = PAAMNTENG2  + :t_eng02,
                         PAAMNTENG3  = PAAMNTENG3  + :t_eng03,
                         PAAMNTENG4  = PAAMNTENG4  + :t_eng04,
                         PAAMNTENG5  = PAAMNTENG5  + :t_eng05,
                         PAAMNTENG6  = PAAMNTENG6  + :t_eng06,
                         PAAMNTENG7  = PAAMNTENG7  + :t_eng07,
                         PAAMNTENG8  = PAAMNTENG8  + :t_eng08,
                         PAAMNTENG9  = PAAMNTENG9  + :t_eng09,
                         PAAMNTENG10 = PAAMNTENG10 + :t_eng10,
                         PAAMNTENG11 = PAAMNTENG11 + :t_eng11,
                         PAAMNTENG12 = PAAMNTENG12 + :t_eng12,
                         PAAMNTENG13 = PAAMNTENG13 + :t_eng13,
                         PAAMNTENG14 = PAAMNTENG14 + :t_eng14
                Where CIECLE = NEW.CIECLE
                  And PAAANN = :t_pecann
                  And PRJCLE = NEW.PRJCLE
                  And PRACLE = NEW.PRACLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;
/*
    Mise à jour du budget comptable de l'immobilisation pour l'année financière.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Update IMIBC_ANNEE Set IBAMNTENG1  = IBAMNTENG1  + :t_eng01,
                         IBAMNTENG2  = IBAMNTENG2  + :t_eng02,
                         IBAMNTENG3  = IBAMNTENG3  + :t_eng03,
                         IBAMNTENG4  = IBAMNTENG4  + :t_eng04,
                         IBAMNTENG5  = IBAMNTENG5  + :t_eng05,
                         IBAMNTENG6  = IBAMNTENG6  + :t_eng06,
                         IBAMNTENG7  = IBAMNTENG7  + :t_eng07,
                         IBAMNTENG8  = IBAMNTENG8  + :t_eng08,
                         IBAMNTENG9  = IBAMNTENG9  + :t_eng09,
                         IBAMNTENG10 = IBAMNTENG10 + :t_eng10,
                         IBAMNTENG11 = IBAMNTENG11 + :t_eng11,
                         IBAMNTENG12 = IBAMNTENG12 + :t_eng12,
                         IBAMNTENG13 = IBAMNTENG13 + :t_eng13,
                         IBAMNTENG14 = IBAMNTENG14 + :t_eng14
                Where CIECLE = NEW.CIECLE
                  And IBAANN = :t_pecann
                  And IMMCLE = NEW.IMMCLE 
                  And CPTCLE = NEW.CPTCLE 
                  And UNACLE = NEW.UNACLE;
end !!
set term ; !!
