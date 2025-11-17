Set Term !! ;
Create Trigger tpammod FOr cppaiement
Before Update
Position 0 As
/*
;----------------------------------------------------------------------------
;/T/ Trigger de modification d'un paiement
;
;/P/ Programmeur..: Thomas BRENNEUR
;    Date Création: 25 Juin 1993
;
;    Description..: Traitement à effectuer lors de l'annulation d'un paiement
;                   non imprimé et non journalisé.
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
Declare Variable t_fouciecle Char(4);
Declare Variable t_foucle    Char(6);
Declare Variable t_capcle    Char(15);
Declare Variable t_nbrtrserr Smallint;

Begin
 /*
  * Le paiement ne doit pas être journalisé
  * 
  */
  If (    New.pamdatjou = "17-NOV-1858" 
       Or New.pamdatjou Is Null
     )
  Then Begin
   /*
    * Si on annule un chèque NON IMPRIMÉ (à moins que ce ne soit un 
    * paiement externe) et NON JOURNALISÉ il faut détruire la ventilation
    * facture (qui est dans l'historique) et l'imputation.
    * Note : lors de ce traitement, le trigger sur l'historique va dereserver
    * la cédule de paiement. Il va aussi mettre à jour le cumul du lot.
    */
    if (     Old.pamcodann = "0"
         And New.pamcodann = "1"
         And (    New.pamflgimp = "0"
               Or New.pamtyppam = "E"
               Or New.pamtyppam = "2" 
             )
       )
    Then Begin
/*
        ;
        ; Si le paiement est un pré-paiement alors il a surement
        ; généré une pièce NA alors il faut la détruire avec sa cédule.
        ;
*/
      If (    Old.pamtyppam = "1" 
           Or Old.pamtyppam = "2"
         )
      Then Begin
       For Select fouciecle, foucle, capcle
             From cpcap_histo
            Where cphcle1 = New.ciecle
              And cphcle2 = New.lbqcptenc
              And cphcle3 = New.pamcle
             Into :t_fouciecle, :t_foucle, :t_capcle
       Do
         Begin
           Delete From cpcpt_a_payer
                 Where fouciecle = :t_fouciecle
                   And foucle    = :t_foucle
                   And capcle    = :t_capcle;
         End
      End
      Delete From cpcap_histo 
            Where cphcle1 = New.ciecle
              And cphcle2 = New.lbqcptenc
              And cphcle3 = New.pamcle;

      Delete From cppam_imputation
            Where ciecle    = New.ciecle
              And lbqcptenc = New.lbqcptenc
              And pamcle    = New.pamcle;
     /*
      * Mise à jour des cumulatifs du lot
      */
      t_nbrtrserr = 0;
      If ( Old.pamcummnt != Old.pammnt )
      Then t_nbrtrserr = 1;

      Update cplot Set lcpcummnt    = lcpcummnt - Old.pammnt,
                       lcpnbrtrserr = lcpnbrtrserr - :t_nbrtrserr
                 Where ciecle = Old.ciecle
                   And peccle = Old.peccle
                   And lcpcle = Old.lcpcle;
    End
    Else Begin
     /*
      * SI CE N'EST PAS UNE ANNULATION DE CHÈQUE
      *
      *
      * Mise à jour du total et du nombre de transactions dans le lot
      * et mise a jour du montant total de transaction (soit la
      * sommation de l'imputation ou des ventilations de facture,
      * dépendamment du type de paiement).
      */
      t_nbrtrserr = 0;
      If (     Old.pamcummnt != Old.pammnt
           And New.pamcummnt  = New.pammnt
         )
      Then t_nbrtrserr = t_nbrtrserr - 1;
      If (     Old.pamcummnt  = Old.pammnt
           And New.pamcummnt != New.pammnt
         )
      Then t_nbrtrserr = t_nbrtrserr + 1;

      Update cplot Set lcpcummnt    = lcpcummnt - Old.pammnt + New.pammnt,
                       lcpnbrtrserr = lcpnbrtrserr + :t_nbrtrserr
                 Where ciecle = Old.ciecle
                   And peccle = Old.peccle
                   And lcpcle = Old.lcpcle;
    End
  End
End !!
Set Term ; !!
