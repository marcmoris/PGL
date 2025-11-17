/* 
  ;/T/ Solde des factures - Vue sur CPCPT_A_PAYER et CPCAP_HISTO
  ;
  ;/P/ Programmeur..: Alain Côté / Adaptée pour les C.P. par T.Brenneur
  ;    Date création: 28 mai 1993
  ;    Description..: Cette vue donne le solde des factures de type FA.
  ;                   Elle sert dans l'écran de consultation des facture
  ;                   sous le fournisseur.
  ;
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL.
  ;
  ;/M/ Modifié par..: Guy Chabot le 31 octobre 1994
  ;            but..: Introduire le 'NA'.
  ;
  ;
*/
Create View vcap_sld_fa 
      ( cap.fouciecle,
        cap.foucle,
        cap.capcle,
        cap.capciecle,
        cap.capdat,
        cap.pamdat,
        cap.lbqcptenc,
        cap.pamcle,
        cap.capmnt,
        v_capmntaug,
        v_capmntdim )
As
 Select cap.fouciecle,
        cap.foucle,
        cap.capcle,
        cap.capciecle,
        cap.capdat,
        cap.pamdat,
        cap.lbqcptenc,
        cap.pamcle,
        cap.capmnt,
/*
  Pour déterminer si on doit additionner ou soustraire un montant de
  l'historique, il faut regarder le type de traitement CPHTYPTRA.

  Celui-ci à quatres valeurs :

    AJ =  Ajustements

    AR =  Ajustements de rapports de dépenses

    NC =  Note de crédit sur factures

          Comprenant les notes de crédits sur factures et les ajustements
          de ces notes de crédits. (NC et AJ)

    CH =  Chèques

    CA =  Chèques annulés


  Donc suivant le type de traitement :

    AJ ou AR        = On augmente le montant de la pièce

    NC ou CH ou CA  = On diminue le montant de la pièce

  Ajustement de la facture.(Montants qui augmentent la facture)
*/
        prosig_nvln( ( Select Sum( cph.cphmntcap ) From cpcap_histo cph
                                     Where CPH.FOUCIECLE = CAP.FOUCIECLE 
                                       And CPH.FOUCLE    = CAP.FOUCLE    
                                       And CPH.CAPCLE    = CAP.CAPCLE
                                       And CPH.CPHTYPTRA In ( "AJ" , "AR" ) ) ),
/*
  Montant qui diminue la facture, les paiements sont positifs, et les
  notes de crédit sont négatives.
*/
        prosig_nvln( ( Select Sum( prosig_decnum( cph.cphtyptra, "CH", cph.cphmntpye, 0 ) +
                      prosig_decnum( cph.cphtyptra, "CA", cph.cphmntpye, 0 ) +
                      prosig_decnum( cph.cphtyptra, "CH", cph.cphmntesc, 0 ) +
                      prosig_decnum( cph.cphtyptra, "CA", cph.cphmntesc, 0 ) -        
                      prosig_decnum( cph.cphtyptra, "NC", cph.cphmntcap, 0 ) )
                                  From cpcap_histo cph
                                 Where cph.fouciecle = cap.fouciecle 
                                   And cph.foucle    = cap.foucle    
                                   And cph.capcle    = cap.capcle
                                   And cph.cphtyptra In ( "CH" , "CA" , "NC" ) ) )
   From cpcpt_a_payer cap
  Where cap.captypecr In ( "FA","NA","CR" )
    And cap.capdatjou != "17-NOV-1858";
