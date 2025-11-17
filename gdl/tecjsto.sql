set term !! ;
create trigger TECJSTO for GLECRITURE_JG
after insert
position 0 as
/*
;----------------------------------------------------------------------------
;/T/ Ajour dans la table GLECRITURE_JG
;
;/P/ Programmeur..: Alain Côté
;    Date Création: 9 avril 1993
;
;    Description..: Le but de ce TRIGGER, est de centraliser les traitements
;                   sur la mise à jour des cumulatif du lot lors de la
;                   création d'un écriture de journal.
;
;/M/ François Déry, 3 juin 1999
;       Conversion en ISQL.
*/

Declare Variable t_nbrtrserr smallint;

begin
/*
  ; Si l'écriture ne balance pas on auguemente le compteur des hors
  ; balance dans le lot.
*/      
  if ( NEW.ECJMNTCRT != NEW.ECJMNTDBT )
  then t_nbrtrserr = 1;
  else t_nbrtrserr = 0;

  Update GLLOT Set LGLCUMMNT    = LGLCUMMNT + NEW.ECJMNTDBT,
                   LGLNBRTRS    = LGLNBRTRS + 1,
                   LGLNBRTRSERR = LGLNBRTRSERR + :t_nbrtrserr
             Where LGLCIECLE = NEW.ECJCIECLE
               And PECCLE    = NEW.PECCLE
               And LGLCLE    = NEW.LGLCLE;
end !!
set term !!
