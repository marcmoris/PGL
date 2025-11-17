set term !! ;
create trigger TDPODEL for CRDEPOT
before delete
position 0 as
/*
;/T/ Destruction dans la table CRDEPOT
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

  if ( OLD.DPOTYPECR = "EN" )
  then begin
    if ( OLD.DPOMNTPAM != ( OLD.DPOCUMMNT + OLD.DPOMNTFAC ) )
    then t_nbrtrserr = t_nbrtrserr + 1;
  end
  else begin
    if (     OLD.DPOTYPMAC = "M"
         and OLD.DPOMNTPAM != OLD.DPOCUMMNT )
    then t_nbrtrserr = t_nbrtrserr + 1;
  end

  Update CRLOT Set LCRCUMMNT    = LCRCUMMNT - OLD.DPOMNTPAM,
                   LCRNBRTRS    = LCRNBRTRS - 1,
                   LCRNBRTRSERR = LCRNBRTRSERR - :t_nbrtrserr
             Where CIECLE = OLD.CIECLE
               And PECCLE = OLD.PECCLE
               And LCRCLE = OLD.LCRCLE;

end !!
set term ; !!
