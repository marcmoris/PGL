/*
 ;
 ; Créé le.....: 2 mars 1995 
 ;      par....: Guy Chabot Prosig Informatique Inc.
 ;
 ; Description.: Cette vue permet de présenter par format de présentation
 ;               les valeurs contenues dans la table de ventilation comptable
 ;               du sous-projet.
 ;
 ;/M/ François Déry, 8 juin 1999
 ;      Conversion en ISQL.
*/
Create View vpra01
      ( ciecle,
        prjcle,
        pracle,
        frmcle,
        frdcle,
        fdoope,
        v_mntbdg,
        v_mntbdgrev,
        v_mntree,
        v_mnteng )
As
 Select frp.ciecle,
        frp.prjcle,
        frp.pracle,
        frp.frmcle,
        fdo.frdcle,
        fdo.fdoope,
        prosig_nvln( ( Select Sum( pac.pacmntbdg ) From gppra_bdg_ctb pac
                                Where pac.ciecle = frp.ciecle
                                  And pac.prjcle = frp.prjcle
                                  And pac.pracle = frp.pracle
                                  And pac.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin 
                                  And (    pra.prapacdatapp = "17-NOV-1858"
                                        Or pra.prapacdatapp Is Null ) ) ),
        prosig_nvln( ( Select Sum( pac.pacmntbdgrev ) From gppra_bdg_ctb pac
                                Where pac.ciecle = frp.ciecle
                                  And pac.prjcle = frp.prjcle
                                  And pac.pracle = frp.pracle
                                  And pac.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin 
                                  And pra.prapacdatapp != "17-NOV-1858" ) ),
        prosig_nvln( ( Select Sum( pac.pacmntree ) From gppra_bdg_ctb pac
                                Where pac.ciecle = frp.ciecle
                                  And pac.prjcle = frp.prjcle
                                  And pac.pracle = frp.pracle
                                  And pac.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin  ) ),
        prosig_nvln( ( Select Sum( pac.pacmnteng ) From gppra_bdg_ctb pac
                                Where pac.ciecle = frp.ciecle
                                  And pac.prjcle = frp.prjcle
                                  And pac.pracle = frp.pracle
                                  And pac.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin  ) )
   From gpfrm_projets  frp,
        gpfrd_domaine  fdo,
        gppro_activite pra
  Where frp.frmcle = fdo.frmcle
    And frp.frpusr = User
    And frp.ciecle = pra.ciecle
    And frp.prjcle = pra.prjcle
    And frp.pracle = pra.pracle;
