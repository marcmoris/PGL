/*
;/T/ Vue sur CRCPT_A_REC et CRCAR_CEDULE
;
;/P/ Programmeur..: Alain Côté
;
;    Date création: 2 juin 1993
;
;    Description..: Le but de cette vue logique est de nous fournir les informa-
;                   tions(solde...) sur le compte à recevoir et les cédules 
;                   d'encaissement de celui-ci. Sert en autre dans le popup
;                   des cédules d'encaissements lors de la saisie des ajus-
;                   tement.
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
*/
Create View vcar_ccd 
      ( ciecle,
        carcle,
        cartypecr,
        cardat   ,
        cardatjou,
        refciecle,
        refclenum,
        carflgced,
        carmntnet,
        cardatesc1,
        carteresc1,
        cardatesc2,
        carteresc2,
        ccdclelig,
        ccddatdue,
        ccdmnt,
        v_ccdmntaug,
        v_ccdmntdim )
As 
 Select CAR.CIECLE,
        CAR.CARCLE,
        CAR.CARTYPECR,
        CAR.CARDAT   ,
        CAR.CARDATJOU,
        CAR.REFCIECLE,
        CAR.REFCLENUM,
        CAR.CARFLGCED,
        CAR.CARMNTNET,
        CAR.CARDATESC1,
        CAR.CARTERESC1,
        CAR.CARDATESC2,
        CAR.CARTERESC2,
        CCD.CCDCLELIG,
        CCD.CCDDATDUE,
        CCD.CCDMNT,
/*
  Ajustement de la cédule.
*/
        prosig_nvln( ( Select Sum( crh.crhmntcar ) From crcar_histo crh
                                Where crh.ciecle    = car.ciecle
                                  and crh.carcle    = car.carcle
                                  and crh.ccdclelig = ccd.ccdclelig
                                  and crh.crhtyptra = "AJ" ) ),
/*
  Montant qui diminue la cédule, les paiements sont positifs, et les
  note de crédit sont négatives.
*/
        ( prosig_nvln( ( Select Sum( crh.crhmntcar ) From crcar_histo crh
                                Where crh.ciecle    = car.ciecle
                                  And crh.carcle    = car.carcle
                                  And crh.ccdclelig = ccd.ccdclelig
                                  And crh.crhtyptra In ( "EN", "MC" ) ) )
          -
          prosig_nvln( ( Select Sum( crh.crhmntcar ) From crcar_histo crh
                                Where crh.ciecle    = car.ciecle
                                  And crh.carcle    = car.carcle
                                  And crh.ccdclelig = ccd.ccdclelig
                                  And crh.crhtyptra = "NC" ) ) )
   From crcpt_a_rec  car,
        crcar_cedule ccd
  Where car.ciecle     = ccd.ciecle
    And car.carcle     = ccd.carcle
    And car.cartypecr In ( "FA","CR","NA" );
