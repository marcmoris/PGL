set term !! ;
create trigger TCAPSTO for CPCPT_A_PAYER
/*
;----------------------------------------------------------------------------
;/T/ Ajout d'une pièce dans les compte à payer. (FA,CR,NC,AJ,RD)
;
;/P/ Programmeur..: Adapté pour PGL par Thomas BRENNEUR
;    Date Création: 12 Juin 1993
;
;    Description..: Mise à jour des informations du fournisseur et du lot
;                   lors de la création d'une pièce aux comptes à payer.
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
after insert
position 0 as

/* Nombre de transcation en erreur à diminué sur le lot */
Declare Variable t_lcpnbrtrserr smallint;

Declare Variable t_clicle char(6);

begin
 /*
  * Les paiements automatiques ne sont jamais pris en compte lors de leur
  * création. Ils ne deviennent réels que lors de la création des
  * paiements (chèques).
  */
  if ( NEW.CAPTYPECR != "PA" )
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
    if (  NEW.CAPTYPECR != "RD" and
          NEW.CAPTYPECR != "NA" )
     then begin
      Update CPFOU_CIE set FOCSLDACJ = FOCSLDACJ + NEW.CAPMNT
                        Where FOUCIECLE = NEW.FOUCIECLE
                          And FOUCLE    = NEW.FOUCLE
                          And FOCCIECLE = NEW.CAPCIECLE;
/*
      ;
      ; Permet de retrouver le numéro du compte client du fournisseur.
      ;
*/
      Select CLICLE 
        From CPFOURNISSEUR 
       Where FOUCIECLE = NEW.FOUCIECLE
         And FOUCLE    = NEW.FOUCLE
        into :t_clicle ;

      Insert into MCREF_SOLDE 
                     ( REFCIECLE, CIECLE, FOUCLE, CLICLE, CLCSLDACJ, FOCSLDACJ )
              Select NEW.FOUCIECLE,
                     NEW.CAPCIECLE,
                     NEW.FOUCLE,
                     :t_clicle,
                     0,
                     0
                From MCHOLDING
               Where CIENMC = "1"
                 And Not Exists ( Select REFCIECLE From MCREF_SOLDE
                                        Where REFCIECLE = NEW.FOUCIECLE
                                          And FOUCLE    = NEW.FOUCLE
                                          And CIECLE    = NEW.CAPCIECLE 
                                          And CLICLE    = :t_clicle );
/*
      ;
      ; Après création de l'enregistrement, mise à jour du solde
      ;
*/
      Update MCREF_SOLDE Set FOCSLDACJ = FOCSLDACJ + NEW.CAPMNT
                        Where REFCIECLE = NEW.FOUCIECLE
                          And FOUCLE    = NEW.FOUCLE
                          And CIECLE    = NEW.CAPCIECLE
                          And CLICLE    = :t_clicle;
    end
   /*
    * Mise à jour du lot de la nouvelle pièce :
    * 
    *     On ajoute le montant de la pièce au cumul du lot,
    *     On augmente le nombre de pièces du lot,
    *     Si l'imputation et le montant de la pièce ne balancent pas alors
    *     on augmente le nombre de transactions en erreurs.
    *
    * Les paiements non-appliqué non pas de lot d'assigné, alors impossible
    * d'avoir un cumulatif.
    *
    */
    if ( NEW.CAPTYPECR != "NA" )
    then begin
      if ( NEW.CAPCUMMNT != ( NEW.CAPMNT - NEW.CAPMNTAVA ) )
      then t_lcpnbrtrserr = 1;
      else t_lcpnbrtrserr = 0;

      Update CPLOT Set LCPCUMMNT     = LCPCUMMNT + NEW.CAPMNT,
                       LCPNBRTRS     = LCPNBRTRS + 1,
                       LCPNBRTRSERR  = LCPNBRTRSERR + :t_lcpnbrtrserr
                        Where CIECLE = NEW.CAPCIECLE
                          And PECCLE = NEW.PECCLE
                          And LCPCLE = NEW.LCPCLE;
    end
  end
end !!
set term ; !!
