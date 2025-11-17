set term !! ;
create trigger THIPDEL for MCHIS_PROJET
before delete
position 0 as
/* Destruction dans la relation MCHIS_PROJET
 ;
 ;/P/ Programmeur..: Marc Morissette
 ;    Date Création: 20 Octobre 1993
 ;  
 ;                   Mise à jour des fichiers de prix de revient
 ;                                GPPRO_TRANS, GPACT_TRANS, GPUNI_TRANS
 ;
 ;/M/ François Déry, 3 juin 1999
 ;      Conversion en ISQL.
*/
Declare Variable t_coddc Char(1);
Declare Variable t_mnt   Double Precision;

begin
/* Info. de base pour mise à jour */
  Select CPTCODDC 
    From MCCOMPTE
   Where CPTCLE = OLD.CPTCLE
    Into :t_coddc;
/* Calcul des montants */
  if ( "C" = :t_coddc )
  then t_mnt = prosig_round( OLD.HIPMNTCRT /1) - 
               prosig_round( OLD.HIPMNTDBT /1);
  else t_mnt = prosig_round( OLD.HIPMNTDBT /1) -
               prosig_round( OLD.HIPMNTCRT /1);
/*
  Mise à jour de GPPRO_TRANS
*/
  Update GPPRO_TRANS Set TRDMNT = TRDMNT - :t_mnt
                Where CIECLE = OLD.CIECLE
                  And PROCLE = OLD.PROCLE
                  And CPTCLE = OLD.CPTCLE
                  And UNACLE = OLD.UNACLE;
/*
  Mise à jour de GPACT_TRANS
*/
  Update GPACT_TRANS Set TRDMNT = TRDMNT - :t_mnt
                Where CIECLE = OLD.CIECLE
                  And PROCLE = OLD.PROCLE
                  And ACTCLE = OLD.ACTCLE
                  And CPTCLE = OLD.CPTCLE
                  And UNACLE = OLD.UNACLE;
/*
  Mise à jour de GPUNI_TRANS
*/
  Update GPUNI_TRANS Set TRDMNT = TRDMNT - :t_mnt
                Where CIECLE = OLD.CIECLE
                  And UNICAT = OLD.UNICAT
                  And UNICLE = OLD.UNIClE
                  And CPTCLE = OLD.CPTCLE
                  And UNACLE = OLD.UNACLE;
end !!
set term ; !!
