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
Create View vpra02
      ( ciecle,
        prjcle,
        pracle,
        frmcle,
        frdcle,
        fduope,
        v_mntbdg,
        v_mntree )
As
 Select frp.ciecle,
        frp.prjcle,
        frp.pracle,
        frp.frmcle,
        fdu.frdcle,
        fdu.fduope,
        prosig_nvln( ( Select Sum( pau.paubdg ) From gppra_bdg_unt pau
                                Where frp.ciecle = pau.ciecle
                                  And frp.prjcle = pau.prjcle
                                  And frp.pracle = pau.pracle
                                  And fdu.untcle = pau.untcle ) ),
        prosig_nvln( ( Select Sum( pau.pauree ) From gppra_bdg_unt pau
                                Where frp.ciecle = pau.ciecle
                                  And frp.prjcle = pau.prjcle
                                  And frp.pracle = pau.pracle
                                  And fdu.untcle = pau.untcle ) )
   From gpfrm_projets    frp,
        gpfrd_domaine_op fdu
  Where frp.frmcle = fdu.frmcle 
    And frp.frpusr = User;
