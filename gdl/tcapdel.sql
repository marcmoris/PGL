set term !! ;
create trigger TCAPDEL for CPCPT_A_PAYER
/*
;----------------------------------------------------------------------------
;/T/ Suppression d'une pièce dans les compte à payer. (FA,CR,NC,AJ,RD)
;
;/P/ Programmeur..: Thomas BRENNEUR
;    Date Création: 12 Juin 1993
;
;    Description..: Mise à jour des informations du fournisseur et du lot
;                   lors de la destruction d'une pièce aux comptes à payer.
;                   On maintient le solde du fournisseur, et les cumuls du
;                   nombre de transactions et du montant total dans le lot.
;
;/M/ François Déry, 2 juin 1999
;       Conversion en ISQL pour interbase 5.
;
;/M/ Modifié par..: Guy Chabot le 11 août 1994
;    Description..: Ajout de la mise à jour du solde du client/fournisseur.
;
;/M/ Modifié par..: Guy Chabot le 12 octobre 1994
;    Description..: Ajout du concept du paiement non-appliqué.
;
;----------------------------------------------------------------------------
*/
before delete
position 0 as

/* Nombre de transcation en erreur à diminué sur le lot */
Declare Variable t_lcpnbrtrserr smallint;

begin
 /*
  * Les paiements automatiques ne sont jamais pris en compte lors de leur
  * suppression. Ils ne deviennent réels que lors de la création des
  * paiements (chèques).
  */
  if ( OLD.CAPTYPECR != "PA" )
  then begin
   /* 
    * Mise à jour du solde du fournisseur. Chaque montant de pièce est 
    * soustrait au solde. Donc détruire une facture va diminuer ce solde,
    * un crédit ou une node de crédit va l'augmenter, et un ajustement va 
    * l'augmenter ou le diminuer en fonction de son signe.
    * 
    * On ne va pas mettre à jour de fournisseur dans le cas des rapports de
    * dépenses car ceux-ci ne sont pas rattachés à un fournisseur.
    * 
    * Le paiement non-appliqué ne vas en rien modifier le solde car c'est le
    * pré-paiement qui sent charge.
    * 
    */
    if ( OLD.CAPTYPECR != "RD" and
         OLD.CAPTYPECR != "NA" )
    Then Begin
      Update CPFOU_CIE Set FOCSLDACJ = FOCSLDACJ - OLD.CAPMNT
                       Where FOUCIECLE = OLD.FOUCIECLE
                         And FOUCLE    = OLD.FOUCLE
                         And FOCCIECLE = OLD.CAPCIECLE;
/*
      ;
      ; Permet de retrouver le numéro du compte client du fournisseur.
      ;
*/
      Update MCREF_SOLDE Set FOCSLDACJ = FOCSLDACJ - OLD.CAPMNT
                        Where REFCIECLE = OLD.FOUCIECLE
                          And FOUCLE    = OLD.FOUCLE
                          And CIECLE    = OLD.CAPCIECLE;
    end
   /*
    * Mise à jour du lot de la pièce qui est supprimé :
    * 
    *     On soustrait le montant de la pièce au cumul du lot,
    *     On diminue le nombre de pièces du lot,
    *     Si l'imputation et le montant de la pièce ne balancaient pas alors
    *     on diminue le nombre de transactions en erreurs.
    *
    * Les paiements non-appliqué non pas de lot d'assigné, alors impossible
    * d'avoir un cumulatif.
    *
    */
    if ( OLD.CAPTYPECR != "NA" )
    then begin
      t_lcpnbrtrserr = 0;
      if ( OLD.CAPCUMMNT != ( OLD.CAPMNT - OLD.CAPMNTAVA ) )
      then t_lcpnbrtrserr = 1;
      else t_lcpnbrtrserr = 0;

      Update CPLOT Set LCPCUMMNT     = LCPCUMMNT - OLD.CAPMNT,
                       LCPNBRTRS     = LCPNBRTRS - 1,
                       LCPNBRTRSERR  = LCPNBRTRSERR - :t_lcpnbrtrserr
                        Where CIECLE = OLD.CAPCIECLE
                          And PECCLE = OLD.PECCLE
                          And LCPCLE = OLD.LCPCLE;
    end
  end
end !!
set term ; !!
