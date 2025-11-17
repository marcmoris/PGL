/*
 ;
 ; Créé le.....: 27 février 1995 
 ;      par....: Guy Chabot Prosig Informatique Inc.
 ;
 ; Description.: Cette vue permet de présenter par format de présentation
 ;               les valeurs contenues dans la table de ventilation d'opération
 ;               de l'immobilisation.
 ;
 ;/M/ François Déry, 8 juin 1999
 ;      Conversion en ISQL.
*/
Create View vimm02
      ( ciecle,
        immcle,
        frmcle,
        frdcle,
        fduope,
        v_mntbdg,
        v_mntree )
As
 Select frp.ciecle,
        frp.immcle,
        frp.frmcle,
        fdu.frdcle,
        fdu.fduope,
        prosig_nvln( ( Select Sum( ibu.ibumntbdg ) From imimm_bdg_unt ibu 
                                Where frp.ciecle = ibu.ciecle
                                  And frp.immcle = ibu.immcle
                                  And fdu.untcle = ibu.untcle  ) ),
        prosig_nvln( ( Select Sum( ibu.ibumntree ) From imimm_bdg_unt ibu 
                                Where frp.ciecle = ibu.ciecle
                                  And frp.immcle = ibu.immcle
                                  And fdu.untcle = ibu.untcle  ) )
   From gpfrm_projets    frp,
        gpfrd_domaine_op fdu
  Where frp.frmcle = fdu.frmcle 
    And frp.frpusr = User;
