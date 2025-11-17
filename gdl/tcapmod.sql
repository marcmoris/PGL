set term !! ;
create trigger TCAPMOD for CPCPT_A_PAYER
/*
;----------------------------------------------------------------------------
;/T/ M.a.j. d'un compte à payer.
;
;/P/ Programmeur..: Thomas BRENNEUR
;    Date Création: 12 Juin 1993
;
;    Description..: Mintenance du cumulatif du lot et du solde du
;                   fournisseur.
;
;/M/ François Déry, 2 juin 1999
;       Conversion en format ISQL pour interbase 5.
;
;/M/ Modifié par..: Guy Chabot le 11 août 1994
;    Description..: Ajout de la mise à jour du solde du client/fournisseur.
;
;/M/ Modifié par..: Guy Chabot le 12 octobre 1994
;    Description..: Ajout du concept de paiement non-appliqué.
;
;----------------------------------------------------------------------------
*/
before update
position 0 as

/* Nombre de transcation en erreur à diminué sur le lot */
Declare Variable t_lcpnbrtrserr smallint;

begin
 /* 
  * On ne traite la transaction que si ce n'est pas un paiement automatique
  * et si cette transaction n'est pas journalisée. Dans le cas ou la 
  * transaction est journalisée, les montants ne sont pas modifiables et
  * on ne peut plus la supprimer. Il est alors inutile de modifier le lot
  * pour rien.
  */
  if (     NEW.CAPTYPECR != "PA"
       and (     NEW.CAPDATJOU  = "17-NOV-1858"
             or  NEW.CAPDATJOU  is null ) )
  then begin
   /* 
    * Mise à jour du solde du fournisseur. Chaque montant de pièce est 
    * additionné au solde. Donc une facture va augmenter ce solde,
    * un crédit ou une node de crédit va le diminuer, et un ajustement va 
    * l'augmenter ou le diminuer en fonction de son signe.
    * 
    * On ne va pas mettre à jour de fournisseur dans le cas des rapports de
    * dépenses car ceux-ci ne sont pas rattachés à un fournisseur.
    * 
    * Le paiement non-appliqué ne vas en rien modifier le solde car c'est le
    * pré-paiement qui sent charge.
    * 
    */
    if ( NEW.CAPTYPECR != "RD" and
         NEW.CAPTYPECR != "NA" )
    then begin
      Update CPFOU_CIE Set FOCSLDACJ = FOCSLDACJ - OLD.CAPMNT + NEW.CAPMNT
                        Where FOUCIECLE = NEW.FOUCIECLE
                          And FOUCLE    = NEW.FOUCLE
                          And FOCCIECLE = NEW.CAPCIECLE;
/*
      ; Permet de retrouver le numéro du compte client du fournisseur.
      ;
*/
      Update MCREF_SOLDE Set FOCSLDACJ = FOCSLDACJ - OLD.CAPMNT + NEW.CAPMNT
                        Where REFCIECLE = FOUCIECLE
                          And FOUCLE    = FOUCLE
                          And CIECLE    = CAPCIECLE;
    end
   /*
    * Mise à jour du lot de la pièce :
    * 
    *     On remplace le montant de la pièce dans le cumul du lot,
    *     Le nombre de pièces du lot ne change pas,
    *     Et on met à jour le nombre de transactions en erreur si la
    *     pièce à été corrigée (ou le contraire).
    *
    * Les paiements non-appliqué non pas de lot d'assigné, alors impossible
    * d'avoir un cumulatif.
    *
    */    
    if ( NEW.CAPTYPECR != "NA" )
    then begin
      t_lcpnbrtrserr = 0;
      if (     OLD.CAPCUMMNT != ( OLD.CAPMNT - OLD.CAPMNTAVA )
           and NEW.CAPCUMMNT  = ( NEW.CAPMNT - NEW.CAPMNTAVA ) )
      then t_lcpnbrtrserr = t_lcpnbrtrserr - 1;
      if (     OLD.CAPCUMMNT  = ( OLD.CAPMNT - OLD.CAPMNTAVA )
           and NEW.CAPCUMMNT != ( NEW.CAPMNT - NEW.CAPMNTAVA ) )
      then t_lcpnbrtrserr = t_lcpnbrtrserr + 1;

      Update CPLOT Set LCPCUMMNT    = LCPCUMMNT - OLD.CAPMNT + NEW.CAPMNT,
                       LCPNBRTRSERR = LCPNBRTRSERR + :t_lcpnbrtrserr
                        Where CIECLE = NEW.CAPCIECLE
                          And PECCLE = NEW.PECCLE
                          And LCPCLE = NEW.LCPCLE;
    end
  end
end !!
set term ; !!
