/*
/M/ François Déry, 7 juin 1999
        Conversion en ISQL.
*/
Create View vact01
      ( ciecle,
        procle,
        actcle,
        forcle,
        foddsc,
        fodtyp,
        fodlig,
        v_mntcum1,
        v_mntcum2 )

As
 Select act.ciecle,
        act.procle,
        act.actcle,
        fod.forcle,
        fod.foddsc,
        fod.fodtyp,
        fod.fodlig,
        prosig_nvln( ( Select Sum( 0 - tra.trdmnt ) From gpact_trans tra,
                                            mccompte    cpt
                                      Where tra.ciecle = act.ciecle
                                        And tra.procle = act.procle
                                        And tra.actcle = act.actcle
                                        And tra.cptcle Between fod.fodcptdue 
                                                           And fod.fodcptava
                                        And cpt.cptcle = tra.cptcle
                                        And "C"        = fod.fodtyp
                                        And cpt.cptcoddc <> fod.fodcoddc ) ),
        prosig_nvln( ( Select Sum( tra.trdmnt ) From gpact_trans tra,
                                        mccompte    cpt
                                  Where tra.ciecle = act.ciecle
                                    And tra.procle = act.procle
                                    And tra.actcle = act.actcle
                                    And tra.cptcle Between fod.fodcptdue 
                                                       And fod.fodcptava
                                    And cpt.cptcle = tra.cptcle
                                    And "C"        = fod.fodtyp
                                    And cpt.cptcoddc = fod.fodcoddc ) )
   From gpactivite act,
        gpfor_detail fod
  Where act.actfrm1 = fod.forcle;
