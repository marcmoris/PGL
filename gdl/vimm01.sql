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
Create View vimm01
      ( ciecle,
        immcle,
        frmcle,
        frdcle,
        fdoope,
        v_mntbdg,
        v_mntree,
        v_mnteng )
As
 Select frp.ciecle,
        frp.immcle,
        frp.frmcle,
        fdo.frdcle,
        fdo.fdoope,
        prosig_nvln( ( Select Sum( ibc.ibcmntbdg ) From imimm_bdg_ctb ibc
                                Where ibc.ciecle = frp.ciecle
                                  And ibc.immcle = frp.immcle
                                  And ibc.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin ) ),
        prosig_nvln( ( Select Sum( ibc.ibcmntree ) From imimm_bdg_ctb ibc
                                Where ibc.ciecle = frp.ciecle
                                  And ibc.immcle = frp.immcle
                                  And ibc.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin ) ),
        prosig_nvln( ( Select Sum( ibc.ibcmnteng ) From imimm_bdg_ctb ibc
                                Where ibc.ciecle = frp.ciecle
                                  And ibc.immcle = frp.immcle
                                  And ibc.cptcle Between fdo.fdocptdeb 
                                                     And fdo.fdocptfin ) )
   From gpfrm_projets frp,
        gpfrd_domaine fdo
  Where frp.frmcle = fdo.frmcle 
    And frp.frpusr = User;
