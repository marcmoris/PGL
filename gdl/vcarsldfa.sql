/* Solde des factures, crédit et paiement non-appliqué.
  ;/T/ Vue sur CRCPT_A_REC et CRCAR_HISTO
  ;
  ;/P/ Programmeur..: Alain Côté
  ;    Date création: 28 mai 1993
  ;    Description..: Cette vue donne le solde des factures, type FA,CR et NA
  ;                   Sert dans l'écran de consultation des facture sous
  ;                   le client.
  ;
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL.
*/
Create View vcar_sld_fa 
      ( ciecle,
        carcle,
        refciecle,
        refcletyp,
        refclenum,
        cardat,
        cartypecr,
        carmnt,
        v_carmntaug,
        v_carmntdim )
As
 Select CAR.CIECLE,
        CAR.CARCLE,
        CAR.REFCIECLE,
        CAR.REFCLETYP,
        CAR.REFCLENUM,
        CAR.CARDAT,
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
  Montant qui diminue la facture, les paiements sont positifs, et les
  note de crédit sont négatives.
*/
        ( prosig_nvln( ( Select Sum( crh.crhmntcar ) From crcar_histo crh
                                Where crh.ciecle    = car.ciecle
                                  And crh.carcle    = car.carcle
                                  And crh.crhtyptra In ( "EN","MC" ) ) )
          -
          prosig_nvln( ( Select Sum( crh.crhmntcar ) From crcar_histo crh
                                Where crh.ciecle    = car.ciecle
                                  And crh.carcle    = car.carcle
                                  And crh.crhtyptra = "NC" ) ) )
   From crcpt_a_rec car
  Where car.cardatjou != "17-NOV-1858"
    And car.cartypecr In ("FA","CR","NA" );
