set term !! ;
create trigger THIPSTO for MCHIS_PROJET
before insert 
position 0 as
/* Ajout dans la relation MCHIS_PROJET
 ;
 ;/P/ Programmeur..: Marc Morissette
 ;    Date Création: 20 Octobre 1993
 ;  
 ;    Description..: On peut faire que des ajouts dans cette table, ils sont
 ;                   faits lors des journalisations par des programmes QTP.
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
   Where CPTCLE = NEW.CPTCLE
    Into :t_coddc;
/* Calcul des montants */
  if ( "C" = :t_coddc )
  then t_mnt = prosig_round( NEW.HIPMNTCRT /1) - 
               prosig_round( NEW.HIPMNTDBT /1);
  else t_mnt = prosig_round( NEW.HIPMNTDBT /1) -
               prosig_round( NEW.HIPMNTCRT /1);
/*
    Mise à jour de GPPRO_TRANS
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Insert Into GPPRO_TRANS
              ( CIECLE, PROCLE, CPTCLE, UNACLE, TRDMNT )
        Select NEW.CIECLE,
               NEW.PROCLE,
               NEW.CPTCLE,
               NEW.UNACLE,
               0
          From MCHOLDING
         Where CIENMC = "1"
           And Not Exists ( Select CIECLE From GPPRO_TRANS
                                         Where CIECLE = NEW.CIECLE
                                           And PROCLE = NEW.PROCLE
                                           And CPTCLE = NEW.CPTCLE
                                           And UNACLE = NEW.UNACLE );
  Update GPPRO_TRANS Set TRDMNT = TRDMNT + :t_mnt
                Where CIECLE = NEW.CIECLE
                  And PROCLE = NEW.PROCLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;
/*
    Mise à jour de GPACT_TRANS
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Insert Into GPACT_TRANS
              ( CIECLE, PROCLE, ACTCLE, CPTCLE, UNACLE, TRDMNT )
        Select NEW.CIECLE,
               NEW.PROCLE,
               NEW.ACTCLE,
               NEW.CPTCLE,
               NEW.UNACLE,
               0
          From MCHOLDING
         Where CIENMC = "1"
           And Not Exists ( Select CIECLE From GPACT_TRANS 
                                        Where CIECLE = NEW.CIECLE
                                          And PROCLE = NEW.PROCLE
                                          And ACTCLE = NEW.ACTCLE
                                          And CPTCLE = NEW.CPTCLE
                                          And UNACLE = NEW.UNACLE );
  Update GPACT_TRANS Set TRDMNT = TRDMNT + :t_mnt
                Where CIECLE = NEW.CIECLE
                  And PROCLE = NEW.PROCLE
                  And ACTCLE = NEW.ACTCLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;
/*
    Mise à jour de GPUNI_TRANS
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Insert Into GPUNI_TRANS
              ( CIECLE, UNICAT, UNICLE, CPTCLE, UNACLE, TRDMNT )
        Select NEW.CIECLE,
               NEW.UNICAT,
               NEW.UNICLE,
               NEW.CPTCLE,
               NEW.UNACLE,
               0
          From MCHOLDING
         Where CIENMC = "1"
           And Not Exists ( Select CIECLE From GPUNI_TRANS
                                        Where CIECLE = NEW.CIECLE
                                          And UNICAT = NEW.UNICAT
                                          And UNICLE = NEW.UNICLE
                                          And CPTCLE = NEW.CPTCLE
                                          And UNACLE = NEW.UNACLE );
  Update GPUNI_TRANS Set TRDMNT = TRDMNT + :t_mnt
                Where CIECLE = NEW.CIECLE
                  And UNICAT = NEW.UNICAT
                  And UNICLE = NEW.UNICLE
                  And CPTCLE = NEW.CPTCLE
                  And UNACLE = NEW.UNACLE;
end !!
set term ; !!
