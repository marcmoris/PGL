/*
;/T/ Vue sur GPPROJETS et GPPRO_ACTIVITE
;
;/P/ Programmeur..: André Demers
;
;    Date création:  14 décembre 1995
;
;    Description..: Le but de cette vue logique : Le nombre de fichier dans
;                   le calcul de transfert GL dépasse 31.
;
;/M/ François Déry, 8 juin 1999
;       Conversion en ISQL.
*/
Create View vprjpra
As
 Select prj.ciecle,
        prj.prjcle,
        prj.prjstu,
        pra.pracle,
        pra.prastu
   From gpprojets      prj,
        gppro_activite pra
  Where prj.ciecle = pra.ciecle
    And prj.prjcle = pra.prjcle;
