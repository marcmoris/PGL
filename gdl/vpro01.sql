/*
;/M/ François Déry, 8 juin 1999
;       Conversion en ISQL.
*/
Create View vpro01
      ( ciecle,
        procle,
        forcle,
        foddsc,
        fodtyp,
        fodlig,
        v_mntcum1,
        v_mntcum2 )
As
 Select pro.ciecle,
        pro.procle,
        fod.forcle,
        fod.foddsc,
        fod.fodtyp,
        fod.fodlig,
        prosig_nvln( ( Select Sum( 0 - trd.trdmnt ) From gppro_trans trd,
                                                         mccompte    cpt
                                Where trd.ciecle     = pro.ciecle 
                                  And trd.procle     = pro.procle
                                  And cpt.cptcle     = trd.cptcle
                                  And fod.fodtyp     = "C"
                                  And fod.fodcoddc  <> cpt.cptcoddc 
                                  And trd.cptcle Between fod.fodcptdue 
                                                     And fod.fodcptava ) ),
        prosig_nvln( ( Select Sum( trd.trdmnt ) From gppro_trans trd,
                                                     mccompte    cpt
                                Where trd.ciecle     = pro.ciecle 
                                  And trd.procle     = pro.procle
                                  And cpt.cptcle     = trd.cptcle
                                  And fod.fodtyp     = "C"
                                  And fod.fodcoddc   = cpt.cptcoddc 
                                  And trd.cptcle Between fod.fodcptdue 
                                                     And fod.fodcptava ) )
   From gpprojet     pro,
        gpfor_detail fod
  Where pro.profrm1 = fod.forcle;
