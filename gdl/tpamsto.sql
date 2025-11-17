Set Term !! ;
Create Trigger tpamsto For cppaiement
Before Insert
Position 0 As
/*
;----------------------------------------------------------------------------
;/T/ Trigger de store sur CPPAIEMENT
;
;/P/ Programmeur..: Alain Côté / Adapté pour PGL par Thomas BRENNEUR
;    Date Création: 24 Juin 1993
;
;    Description..: Traitement lors de l'ajout d'un paiement :
;                   
;                     Si c'est un paiement annulé on crée la ventilation et
;                   l'imputation du paiement annulé.
;                   
;                     Mise à jour des cumulatifs dans le lot
;
;/M/ François Déry, 4 juin 1999
;       Conversion en ISQL.
;
;/M/ Modifié par..: Guy Chabot le 12 octobre 1994
;
;    Description..: Introduction du P.N.A. aux payables sur le même principe
;                   ou presque des recevables.
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
  If ( New.pamcummnt != New.pammnt )
  Then t_nbrtrserr = 1;

  Update cplot Set lcpcummnt    = lcpcummnt + New.pammnt,
                   lcpnbrtrs    = lcpnbrtrs + 1,
                   lcpnbrtrserr = lcpnbrtrserr + :t_nbrtrserr
             Where ciecle = New.ciecle
               And peccle = New.peccle
               And lcpcle = New.lcpcle;
End !!
set term ; !!
