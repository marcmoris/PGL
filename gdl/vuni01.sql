Create View vuni01
      ( ciecle,
        unicat,
        unicle,
        forcle,
        foddsc,
        fodtyp,
        fodlig,
        v_mntcum1,
        v_mntcum2 )
As
 Select uni.ciecle,
        uni.unicat,
        uni.unicle,
        fod.forcle,
        fod.foddsc,
        fod.fodtyp,
        fod.fodlig,
        prosig_nvln( ( Select Sum( 0 - tru.trdmnt ) from gpuni_trans tru,
                                                         mccompte    cpt
                                Where tru.ciecle     = uni.ciecle
                                  And tru.unicat     = uni.unicat
                                  And tru.unicle     = uni.unicle
                                  And cpt.cptcle     = tru.cptcle
                                  And fod.fodtyp     = "C"
                                  And fod.fodcoddc  <> cpt.cptcoddc 
                                  And tru.cptcle Between fod.fodcptdue 
                                                     And fod.fodcptava ) ),
        prosig_nvln( ( Select Sum( tru.trdmnt ) from gpuni_trans tru,
                                                     mccompte    cpt
                                Where tru.ciecle     = uni.ciecle
                                  And tru.unicat     = uni.unicat
                                  And tru.unicle     = uni.unicle
                                  And cpt.cptcle     = tru.cptcle
                                  And fod.fodtyp     = "C"
                                  And fod.fodcoddc   = cpt.cptcoddc 
                                  And tru.cptcle Between fod.fodcptdue 
                                                     And fod.fodcptava ) )
   From gpunite      uni,
        gpfor_detail fod
  Where uni.unifrm1 = fod.forcle;
