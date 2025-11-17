/*
  ;cumul des imputations pour une commande interne
  ;/t/ vue sur pdventilation, pddetail_c_i, pdcomman_interne
  ;
  ;/p/ programmeur..: martin bruyère
  ;    date création: 1995-02-03
  ;    description..: cette vue calcul le total de l'imputation
  ;                   de la commande interne pour afficher le global.
  ;
  ;/M/ François Déry, 8 juin 1999
  ;     Conversion en ISQL. Enlever V_TOT_MC2 et modifier l'écran.
*/

Create View vven_grp
      ( ciecle,
        pjtabr,
        pjtann,
        comnumcomint,
        cptcle)
As
 Select ven.ciecle,
        ven.pjtabr,
        ven.pjtann,
        ven.comnumcomint,
        ven.cptcle
   From pdventilation ven
  Group By ven.pjtabr,
           ven.pjtann,
           ven.comnumcomint,
           ven.cptcle,
           ven.ciecle;


Create View vven_tot
      ( ciecle,
        pjtabr,
        pjtann,
        comnumcomint,
        cptcle,
        v_total_unmprd,
        v_total_ven,
        v_total_fac2 )
As
 Select ven.ciecle,
        ven.pjtabr,
        ven.pjtann,
        ven.comnumcomint,
        ven.cptcle,

/*
  ; calcul du total d'unité de mesure production
*/
        prosig_nvln( ( Select Sum( dci.dciqteunmprd ) From pddetail_c_i dci
                                Where dci.ciecle       = ven.ciecle
                                  And dci.pjtabr       = ven.pjtabr
                                  And dci.pjtann       = ven.pjtann
                                  And dci.comnumcomint = ven.comnumcomint ) ),

/*
  ; total imputé par ligne total (vente)
*/
        prosig_nvln( ( Select Sum( ven1.venpriuni * dci.dciqteunmprd )
                                 From pdventilation ven1,
                                      pddetail_c_i  dci
                                Where ven1.ciecle       = ven.ciecle
                                  And ven1.pjtabr       = ven.pjtabr
                                  And ven1.pjtann       = ven.pjtann
                                  And ven1.comnumcomint = ven.comnumcomint
                                  And ven1.cptcle       = ven.cptcle
                                  And dci.ciecle        = ven1.ciecle
                                  And dci.pjtabr        = ven1.pjtabr
                                  And dci.pjtann        = ven1.pjtann
                                  And dci.comnumcomint  = ven1.comnumcomint
                                  And dci.dcinumlig     = ven1.dcinumlig ) ),


        prosig_nvln( ( Select Sum( pdf.crimnt ) From pdfac_imputation pdf
                                Where pdf.ciecle        = ven.ciecle
                                  And pdf.pjtabr        = ven.pjtabr
                                  And pdf.pjtann        = ven.pjtann
                                  And pdf.comnumcomint  = ven.comnumcomint
                                  And pdf.cptcle        = ven.cptcle ) )
   From vven_grp ven;




