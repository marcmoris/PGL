Set Term !! ;
Create Trigger tpamdel For cppaiement
Before Delete
Position 0 As
/*
;----------------------------------------------------------------------------
;/T/ Trigger de delete sur CPPAIEMENT
;
;/P/ Programmeur..: Thomas BRENNEUR
;    Date Création: 6 Juillet 1993
;
;    Description..: Traitement lors de la suppression d'un paiement
;                   
;                   NOTE : ON NE PEUT SUPPRIMER QUE DES PAIEMENTS
;                          DE TYPE "ANNULATION DE PAIEMENT" =  CA
;                   
;/M/ François Déry, 4 juin 1999
;       Conversion en ISQL.
;
;/M/ Modifié par..: Guy Chabot le 12 octobre 1994
;
;    Description..: Introduction du P.N.A. aux payables sur le même principe
;                   ou presque des recevables.
;
;
;----------------------------------------------------------------------------
*/
Declare Variable t_nbrtrserr Smallint;

Begin
 /*
  * CPLOT : Mise a jour du total et du nombre de transactions dans le lot
  *         et mise a jour du montant total de transaction (soit la
  *         sommation de l'imputation ou des ventilations de facture,
  *         dépendamment du type de paiement).
  */
  t_nbrtrserr = 0;
  If ( Old.pamcummnt != Old.pammnt )
  Then t_nbrtrserr = 1;

  Update cplot Set lcpcummnt    = lcpcummnt - Old.pammnt,
                   lcpnbrtrs    = lcpnbrtrs - 1,
                   lcpnbrtrserr = lcpnbrtrserr - :t_nbrtrserr
             Where ciecle = Old.ciecle
               And peccle = Old.peccle
               And lcpcle = Old.lcpcle;
End !!
Set Term ; !!
