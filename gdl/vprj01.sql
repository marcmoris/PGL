/*
 ;
 ; Créé le.....: 27 février 1995 
 ;      par....: Guy Chabot Prosig Informatique Inc.
 ;
 ; Description.: Cette vue permet de présenter par format de présentation
 ;               les valeurs contenues dans la table de ventilation comptable
 ;               du projet.
 ;
 ;/M/ François Déry, 8 juin 1999
 ;      Conversion en ISQL.
*/
Create View vprj01
      ( ciecle,
        prjcle,
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
        frp.frmcle,
        fdo.frdcle,
        fdo.fdoope,
        prosig_nvln( ( Select Sum( pbc.pbcmntbdg ) From gppro_bdg_ctb pbc
                                Where pbc.ciecle = frp.ciecle
                                  And pbc.prjcle = frp.prjcle
                                  And pbc.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin 
                                  And (    prj.prjpbcdatapp = "17-NOV-1858"
                                        Or prj.prjpbcdatapp Is Null ) ) ),
        prosig_nvln( ( Select Sum( pbc.pbcmntbdgrev ) From gppro_bdg_ctb pbc
                                Where pbc.ciecle = frp.ciecle
                                  And pbc.prjcle = frp.prjcle
                                  And pbc.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin 
                                  And prj.prjpbcdatapp != "17-NOV-1858" ) ),
        prosig_nvln( ( Select Sum( pbc.pbcmntree ) From gppro_bdg_ctb pbc
                                Where pbc.ciecle = frp.ciecle
                                  And pbc.prjcle = frp.prjcle
                                  And pbc.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin ) ),
        prosig_nvln( ( Select Sum( pbc.pbcmnteng ) From gppro_bdg_ctb pbc
                                Where pbc.ciecle = frp.ciecle
                                  And pbc.prjcle = frp.prjcle
                                  And pbc.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin ) )
   From gpfrm_projets frp,
        gpfrd_domaine fdo,
        gpprojets     prj
  Where frp.frmcle = fdo.frmcle 
    And frp.frpusr = User
    And frp.ciecle = prj.ciecle
    And frp.prjcle = prj.prjcle;
