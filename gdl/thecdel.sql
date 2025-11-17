set term !! ;
create trigger THECDEL for MCHIS_ECR
Before delete
position 0 as
/* Destruction dans la relation MCHIS_ECR
;
;/P/ Programmeur..: Marc Morissette 
;    Date Création: 28 Octobre 1993
;  
;/M/ François Déry, 3 juin 1999
;       Conversion en ISQL
;
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
  t_pecann = prosig_extract(1,2,OLD.PECCLE," ");
  t_pecnum = prosig_extract(3,2,OLD.PECCLE," ");
  Select CPTCODDC
    From MCCOMPTE
   Where CPTCLE = OLD.CPTCLE
    Into :t_coddc;
/*
  Calcul des montants à mettre à jour
*/
  if ( :t_coddc = "C" )
  then t_ree = (OLD.HECMNTCRT - OLD.HECMNTDBT);
  else t_ree = (OLD.HECMNTDBT - OLD.HECMNTCRT);

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
    Mise à jour du solde annuel dans le grand livre.
*/
  Update MCSOLDE_ANNUEL Set SANCUMREE1  = SANCUMREE1  - :t_ree01,
                            SANCUMREE2  = SANCUMREE2  - :t_ree02,
                            SANCUMREE3  = SANCUMREE3  - :t_ree03,
                            SANCUMREE4  = SANCUMREE4  - :t_ree04,
                            SANCUMREE5  = SANCUMREE5  - :t_ree05,
                            SANCUMREE6  = SANCUMREE6  - :t_ree06,
                            SANCUMREE7  = SANCUMREE7  - :t_ree07,
                            SANCUMREE8  = SANCUMREE8  - :t_ree08,
                            SANCUMREE9  = SANCUMREE9  - :t_ree09,
                            SANCUMREE10 = SANCUMREE10 - :t_ree10,
                            SANCUMREE11 = SANCUMREE11 - :t_ree11,
                            SANCUMREE12 = SANCUMREE12 - :t_ree12,
                            SANCUMREE13 = SANCUMREE13 - :t_ree13,
                            SANCUMREE14 = SANCUMREE14 - :t_ree14
                Where SANANN = :t_pecann
                  And CIECLE = OLD.CIECLE
                  And CPTCLE = OLD.CPTCLE
                  And UNACLE = OLD.UNACLE;
/*
    Mise à jour du solde restrictif dans le grand livre.
*/
  if ( OLD.HECFLGINT = "1" )
  then begin
    Update MCSAN_REST Set SRECUMREE1  = SRECUMREE1  - :t_ree01,
                          SRECUMREE2  = SRECUMREE2  - :t_ree02,
                          SRECUMREE3  = SRECUMREE3  - :t_ree03,
                          SRECUMREE4  = SRECUMREE4  - :t_ree04,
                          SRECUMREE5  = SRECUMREE5  - :t_ree05,
                          SRECUMREE6  = SRECUMREE6  - :t_ree06,
                          SRECUMREE7  = SRECUMREE7  - :t_ree07,
                          SRECUMREE8  = SRECUMREE8  - :t_ree08,
                          SRECUMREE9  = SRECUMREE9  - :t_ree09,
                          SRECUMREE10 = SRECUMREE10 - :t_ree10,
                          SRECUMREE11 = SRECUMREE11 - :t_ree11,
                          SRECUMREE12 = SRECUMREE12 - :t_ree12,
                          SRECUMREE13 = SRECUMREE13 - :t_ree13,
                          SRECUMREE14 = SRECUMREE14 - :t_ree14
                Where SANANN    = :t_pecann
                  And CIECLE    = OLD.CIECLE
                  And CPTCLE    = OLD.CPTCLE
                  And UNACLE    = OLD.UNACLE
                  And SRECIEINT = OLD.HECCIEINT
                  And SREUNAINT = OLD.HECUNAINT;
  end 
end !!
set term ; !!
