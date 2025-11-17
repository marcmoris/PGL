/*
 ;
 ; Créé le.....: 27 février 1995 
 ;      par....: Guy Chabot Prosig Informatique Inc.
 ;
 ; Description.: Cette vue permet de présenter par format de présentation
 ;               les valeurs contenues dans la table de ventilation d'opération
 ;               du projet.
 ;
 ;/M/ François Déry, 8 juin 1999
 ;      Conversion en ISQL.
*/
Create View vprj02
      ( ciecle,
        prjcle,
        frmcle,
        frdcle,
        fduope,
        v_mntbdg,
        v_mntree )
As
 Select frp.ciecle,
        frp.prjcle,
        frp.frmcle,
        fdu.frdcle,
        fdu.fduope,
        prosig_nvln( ( Select Sum( pbu.pbubdg ) From gppro_bdg_unt pbu
                                Where frp.ciecle = pbu.ciecle
                                  And frp.prjcle = pbu.prjcle
                                  And fdu.untcle = pbu.untcle ) ),
        prosig_nvln( ( Select Sum( pbu.pburee ) From gppro_bdg_unt pbu
                                Where frp.ciecle = pbu.ciecle
                                  And frp.prjcle = pbu.prjcle
                                  And fdu.untcle = pbu.untcle ) )
   From gpfrm_projets    frp,
        gpfrd_domaine_op fdu
  Where frp.frmcle = fdu.frmcle 
    And frp.frpusr = User;
