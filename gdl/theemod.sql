set term !! ;
create trigger THEEMOD for MCHIS_ECR_ENG
before update
position 0 as
/* Ajout dans la relation MCHIS_ECR_ENG
 ;
 ;/P/ Programmeur..: Steeve Duguay 
 ;    Date Création: 7 février 1995
 ;  
 ;    Description..: On peut faire que des ajouts dans cette table, ils sont
 ;                   faits lors des journalisations par des programmes QTP.
 ;
 ;                   Mise à jour des soldes annuels et des soldes restric-
 ;                   tifs.
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
  then t_eng = NEW.HEEMNTCRT - OLD.HEEMNTCRT -
               NEW.HEEMNTDBT + OLD.HEEMNTDBT;
  else t_eng = NEW.HEEMNTDBT - OLD.HEEMNTDBT -
               NEW.HEEMNTCRT + OLD.HEEMNTCRT;

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
    Mise à jour du solde annuel dans le grand livre.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Update MCSOLDE_ANNUEL Set SANCUMENG1  = SANCUMENG1  + :t_eng01,
                            SANCUMENG2  = SANCUMENG2  + :t_eng02,
                            SANCUMENG3  = SANCUMENG3  + :t_eng03,
                            SANCUMENG4  = SANCUMENG4  + :t_eng04,
                            SANCUMENG5  = SANCUMENG5  + :t_eng05,
                            SANCUMENG6  = SANCUMENG6  + :t_eng06,
                            SANCUMENG7  = SANCUMENG7  + :t_eng07,
                            SANCUMENG8  = SANCUMENG8  + :t_eng08,
                            SANCUMENG9  = SANCUMENG9  + :t_eng09,
                            SANCUMENG10 = SANCUMENG10 + :t_eng10,
                            SANCUMENG11 = SANCUMENG11 + :t_eng11,
                            SANCUMENG12 = SANCUMENG12 + :t_eng12,
                            SANCUMENG13 = SANCUMENG13 + :t_eng13,
                            SANCUMENG14 = SANCUMENG14 + :t_eng14
                Where SANANN = :t_pecann
                  And CIECLE = NEW.CIECLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;

/*
  Mise à jour du solde restrictif dans le grand livre.
  Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  if ( NEW.HEEFLGINT = "1" )
  then begin
    Update MCSAN_REST Set SRECUMENG1  = SRECUMENG1  + :t_eng01,
                          SRECUMENG2  = SRECUMENG2  + :t_eng02,
                          SRECUMENG3  = SRECUMENG3  + :t_eng03,
                          SRECUMENG4  = SRECUMENG4  + :t_eng04,
                          SRECUMENG5  = SRECUMENG5  + :t_eng05,
                          SRECUMENG6  = SRECUMENG6  + :t_eng06,
                          SRECUMENG7  = SRECUMENG7  + :t_eng07,
                          SRECUMENG8  = SRECUMENG8  + :t_eng08,
                          SRECUMENG9  = SRECUMENG9  + :t_eng09,
                          SRECUMENG10 = SRECUMENG10 + :t_eng10,
                          SRECUMENG11 = SRECUMENG11 + :t_eng11,
                          SRECUMENG12 = SRECUMENG12 + :t_eng12,
                          SRECUMENG13 = SRECUMENG13 + :t_eng13,
                          SRECUMENG14 = SRECUMENG14 + :t_eng14
                Where SANANN    = :t_pecann
                  And CIECLE    = NEW.CIECLE
                  And CPTCLE    = NEW.CPTCLE
                  And UNACLE    = NEW.UNACLE
                  And SRECIEINT = NEW.HEECIEINT
                  And SREUNAINT = NEW.HEEUNAINT;

  end             /* if HEEFLGINT */
end !!
set term ; !!
