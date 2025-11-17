/* 
  ;Solde des factures, rapports de dépenses, notes de crédit....
  ;/T/ Vue sur CPCPT_A_PAYER et CPCAP_HISTO
  ;
  ;/P/ Programmeur..: Alain Côté / Adapté pour les CP par T.Brenneur
  ;    Date création: 28 mai 1993
  ;    Description..: Cette vue donne le solde des pièces de type FA, RD et CR.
  ;                   Sert dans l'écran des factures pour avoir le détail
  ;                   des montants qui affecte une facture.
  ;
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL
*/
Create View vcap_sld 
      ( fouciecle,
        foucle,
        capcle,
        v_capmntajt,
        v_capmntcrt,
        v_capmntpye,
        v_capmntesc )
As
 Select cap.fouciecle,
        cap.foucle,
        cap.capcle,
/*
  Le type de traitement (CPHTYPTRA) indique la façon d'utiliser le
  montant d'historique :

        AJ = C'est un ajustement

        AR = C'est un ajustement de rapport de dépense

        NC = C'est une note de crédit (note de crédit ou ajustement de note
             de crédit)

        CH = C'est un chèque

        CA = C'est un chèque annulé

  Ajustement de la facture.
*/
        prosig_nvln( ( Select Sum( cph.cphmntcap ) From cpcap_histo cph
                                     Where cph.fouciecle = cap.fouciecle
                                       And cph.foucle    = cap.foucle
                                       And cph.capcle    = cap.capcle
                                       And cph.cphtyptra In ( "AJ" , "AR" ) ) ),
/*
  Notes de crédit sur facture, incluant ajustement sur ces notes de crédit.
*/
        prosig_nvln( ( Select Sum( cph.cphmntcap ) From cpcap_histo cph
                                     Where cph.fouciecle = cap.fouciecle
                                       And cph.foucle    = cap.foucle
                                       And cph.capcle    = cap.capcle
                                       And cph.cphtyptra = "NC" ) ),
/*
  Montant payé sur la pièce, paiements.
*/
        prosig_nvln( ( Select Sum( cph.cphmntpye ) From cpcap_histo cph
                                     Where cph.fouciecle = cap.fouciecle
                                       And cph.foucle    = cap.foucle
                                       And cph.capcle    = cap.capcle
                                       And cph.cphtyptra In ( "CH" , "CA" ) ) ),
/*
  Montant d'escompte, encaissement.
*/
        prosig_nvln( ( Select Sum( cph.cphmntesc ) From cpcap_histo cph
                                     Where cph.fouciecle = cap.fouciecle
                                       And cph.foucle    = cap.foucle
                                       And cph.capcle    = cap.capcle
                                       And cph.cphtyptra In ( "CH" , "CA" ) ) )
   From cpcpt_a_payer cap
  Where captypecr Not In ( "AJ" , "AR" );
