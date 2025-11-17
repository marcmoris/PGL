/* 
  ;Solde des factures, rapports de dépenses et notes de crédit.
  ;/T/ Vue sur CPCPT_A_PAYER et CPCAP_HISTO
  ;
  ;/P/ Programmeur..: Thomas .Brenneur
  ;    Date création: 15 Juin 1993
  ;    Description..: Cette vue donne le solde des pièces de type FA, RD et CR.
  ;                   Sert dans l'écran pop-up sur les factures pour
  ;                   valider la référence.
  ;                   NOTE : on ne sélectionne que les pièces journalisées.
  ;
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL.
  ;
*/
Create View vcap_ref 
      ( fouciecle,
        foucle,
        capcle,
        capciecle,
        refciecle,
        refcletyp,
        refclenum,
        captypecr,
        capdat,
        capdatjou,
        capmnt,
        capmntava,
        v_capmntajt,
        v_capmntcrt,
        v_capmntpye,
        v_capmntesc )
As 
 Select cap.fouciecle,
        cap.foucle,
        cap.capcle,
        cap.capciecle,
        cap.refciecle,
        cap.refcletyp,
        cap.refclenum,
        cap.captypecr,
        cap.capdat,
        cap.capdatjou,
        cap.capmnt,
        cap.capmntava,
/*
  Le type de traitement (CPHTYPTRA) indique la façon d'utiliser le
  montant d'historique :

        AJ = C'est un ajustement

        NC = C'est une note de crédit (note de crédit ou ajustement de note
             de crédit)

        PA = C'est un paiement (c'est un chèque ou un chèque annulé)
*/

/*
  Ajustement du compte à payer.
*/
        prosig_nvln( ( Select Sum( cph.cphmntcap ) from cpcap_histo cph
                        Where cph.fouciecle = cap.fouciecle
                          And cph.foucle    = cap.foucle
                          And cph.capcle    = cap.capcle
                          And cph.cphtyptra In ( "AJ","AR" )
                          And cph.cphdatjou != "17-NOV-1858" ) ),
/*
  Notes de crédit, incluant ajustement sur ces notes de crédit.
*/
        prosig_nvln( ( Select Sum( cph.cphmntcap ) from cpcap_histo cph
                        Where cph.fouciecle = cap.fouciecle
                          And cph.foucle    = cap.foucle
                          And cph.capcle    = cap.capcle
                          And cph.cphtyptra = "NC"
                          And cph.cphdatjou != "17-NOV-1858" ) ),
/*
  Montant payé sur la pièce, paiements.
*/
        prosig_nvln( ( Select Sum( cph.cphmntpye ) from cpcap_histo cph
                        Where cph.fouciecle = cap.fouciecle
                          And cph.foucle    = cap.foucle
                          And cph.capcle    = cap.capcle
                          And cph.cphtyptra In ( "CH","CA" )
                          And cph.cphdatjou != "17-NOV-1858" ) ),
/*
  Montant d'escompte, encaissement.
*/
        prosig_nvln( ( Select Sum( cph.cphmntesc ) from cpcap_histo cph
                        Where cph.fouciecle = cap.fouciecle
                          And cph.foucle    = cap.foucle
                          And cph.capcle    = cap.capcle
                          And cph.cphtyptra In ( "CH","CA" )
                          And cph.cphdatjou != "17-NOV-1858" ) )
   From cpcpt_a_payer cap
  Where cap.captypecr Not In ( "AJ", "AR" )
    And cap.capdatjou != "17-NOV-1858";
