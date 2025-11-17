/* Solde des factures, paiement non-appliqué et note de crédit.

  ;/T/ Vue sur CRCPT_A_REC et CRCAR_HISTO
  ;
  ;/P/ Programmeur..: Alain Côté
  ;    Date création: 28 mai 1993
  ;    Description..: Cette vue donne le solde du compte à recvoir.
  ;
  ;                   Seul les documents suivant peuvent être référé;
  ;                      - Les factures FA,
  ;                      - Les crédits  CR,
  ;                      - Les note de crédits NC,
  ;                      - les paiement non-appliqué NA
  ;
  ;                   Sert dans l'écran des factures pour avoir le détail
  ;                   des montants qui affecte une facture.
  ;
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL.
*/
Create View vcar_sld 
      ( ciecle,
        carcle,
        refciecle,
        refcletyp,
        refclenum,
        cardat,
        cardatjou,
        cartypecr,
        carmnt,
        v_carmntajt,
        v_carmntcrt,
        v_carmntrec,
        v_carmntesc,
        v_carmntmac )
As
 Select CAR.CIECLE,
        CAR.CARCLE,
        CAR.REFCIECLE,
        CAR.REFCLETYP,
        CAR.REFCLENUM,
        CAR.CARDAT,
        CAR.CARDATJOU,
        CAR.CARTYPECR,
        CAR.CARMNT,
/*
  Ajustement de la facture.
*/
        prosig_nvln( ( Select Sum( crh.crhmntcar ) From crcar_histo crh
                                Where crh.ciecle    = car.ciecle
                                  And crh.carcle    = car.carcle
                                  And crh.crhtyptra = "AJ" ) ),
/*
  Note de crédit, incluant ajustement sur note de crédit.
*/
        prosig_nvln( ( Select Sum( crh.crhmntcar ) From crcar_histo crh
                                Where crh.ciecle    = car.ciecle
                                  And crh.carcle    = car.carcle
                                  And crh.crhtyptra = "NC" ) ),
/*
  Montant reçu, encaissement.
*/
        prosig_nvln( ( Select Sum( crh.crhmntrec ) From crcar_histo crh
                                Where crh.ciecle    = car.ciecle
                                  And crh.carcle    = car.carcle
                                  And crh.crhtyptra = "EN" ) ),
/*
  Montant d'escompte, encaissement.
*/
        prosig_nvln( ( Select Sum( crh.crhmntesc ) From crcar_histo crh
                                Where crh.ciecle    = car.ciecle
                                  And crh.carcle    = car.carcle
                                  And crh.crhtyptra = "EN" ) ),
/*
  Mauvaise créance.
*/
        prosig_nvln( ( Select Sum( crh.crhmntcar ) From crcar_histo crh
                                Where crh.ciecle    = car.ciecle
                                  And crh.carcle    = car.carcle
                                  And crh.crhtyptra = "MC" ) )

   From crcpt_a_rec car
  Where car.cartypecr != "AJ";
