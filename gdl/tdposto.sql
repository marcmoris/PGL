set term !! ;
create trigger TDPOSTO for CRDEPOT
before insert
position 0 as
/*
;/T/ Ajout dans la table CRDEPOT
;
;/P/ Programmeur..: Alain Côté
;    Date création: 28 juin 1993
;
;    Description..: Le but est de maintenir les cumulatifs dans le lot.
;
;/M/ François Déry, 3 juin 1999
;       Conversion en ISQL.

    Pour déterminer si une transaction balance.

    - Un encaissement balance, si le montant de l'encaissement est égale
      à la sommation de la ventilation factures et de la sommation de 
      l'imputation.

    - Une mauvaise créance balance, si le montant de la mauvaise créance est
      égale à la sommation de l'imputation, et cela seulement pour les
      mauvaises créance de type Manuel. Pour les mauvaise créances de type
      Automatique le montant de la mauvaise créance est égale à la sommation
      de la ventilation de factures, donc une mauvaise créance Automatique
      balance tout le temps.
*/

Declare Variable t_nbrtrserr smallint;

begin
  t_nbrtrserr = 0;

  if ( NEW.DPOTYPECR = "EN" )
  then begin
    if ( NEW.DPOMNTPAM != ( NEW.DPOCUMMNT + NEW.DPOMNTFAC ) )
    then t_nbrtrserr = t_nbrtrserr + 1;
  end
  else begin
    if (     NEW.DPOTYPMAC = "M"
         and NEW.DPOMNTPAM != NEW.DPOCUMMNT )
    then t_nbrtrserr = t_nbrtrserr + 1;
  end

  Update CRLOT Set LCRCUMMNT    = LCRCUMMNT + NEW.DPOMNTPAM,
                   LCRNBRTRS    = LCRNBRTRS + 1,
                   LCRNBRTRSERR = LCRNBRTRSERR + :t_nbrtrserr
             Where CIECLE = NEW.CIECLE
               And PECCLE = NEW.PECCLE
               And LCRCLE = NEW.LCRCLE;
end !!
set term ; !!
