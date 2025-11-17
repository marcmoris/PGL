/* VDEV_DSC Permet d'avoir la description dans la bonne langue.
   ;---------------------------------------------------------------------------
   ;/T/ Vue bilingue pour les devises.
   ;
   ;/P/ Programmeur..: Lyne Ferland
   ;    Date Création: 20 février 1992
   ;
   ;    Description..:  Programme de création d'une vue pour extraire la 
   ;                    description des devises selon la langue de l'usager.
   ;
   ;    Modifier par : Marc Morissette
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
*/
Create View vdev_dsc
      ( dev.devcle,
        dev.devdsc )
As
 Select dev.devcle,
        dev.devdscfra
   From mcdevise dev;
