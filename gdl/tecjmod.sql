set term !! ;
create trigger TECJMOD for GLECRITURE_JG
before update
position 0 as
/*
;----------------------------------------------------------------------------
;/T/ Modification dans la table GLECRITURE_JG
;
;/P/ Programmeur..: Alain Côté
;    Date Création: 9 avril 1993
;
;    Description..: Le but de ce TRIGGER, est de centraliser les traitements
;                   sur la mise à jour des cumulatif du lot lors de la
;                   modification d'un écriture de journal.
;
;/M/ François Déry, 3 juin 1999
;       Conversion en ISQL.
*/

Declare Variable t_nbrtrserr smallint;

begin
/*
  ; Avant journalisation; l'usager peut modifier le montant.
*/
  if ( NEW.ECJDATJOU = "17-NOV-1858" or NEW.ECJDATJOU is null )
  then begin
    t_nbrtrserr = 0;
/*
    ; Si l'écriture ne balancait pas et que l'usager la corrige pour la
    ; balancer, alors on décrémente le compteur des hors balance.
*/
    if ( OLD.ECJMNTCRT != OLD.ECJMNTDBT and
         NEW.ECJMNTCRT  = NEW.ECJMNTDBT )
    then t_nbrtrserr = t_nbrtrserr - 1;
/*
    ; Si l'écriture balancait et que l'usager la modifie et qu'elle
    ; devient hors balance, alor on incrémente le compteur des hors 
    ; balance.
*/
    if ( OLD.ECJMNTCRT  = OLD.ECJMNTDBT and
         NEW.ECJMNTCRT != NEW.ECJMNTDBT )
    then t_nbrtrserr = t_nbrtrserr + 1;

    Update GLLOT Set LGLCUMMNT    = LGLCUMMNT - OLD.ECJMNTDBT + NEW.ECJMNTDBT,
                     LGLNBRTRSERR = LGLNBRTRSERR + :t_nbrtrserr
               Where LGLCIECLE = OLD.ECJCIECLE
                 And PECCLE    = OLD.PECCLE
                 And LGLCLE    = OLD.LGLCLE;
  end
end !!
set term ; !!
