/* VXLO_DSC Permet d'avoir la description dans la bonne langue.
  ;
  ;/P/ Programmeur..: Alain Côté
  ;    Date Création: 31 août 1992
  ;
  ;    Description..: Vue logique pour extraire la description de la localisation
  ;                   selon la langue de l'usager.
  ;
  ;/M/ François Déry, 8 juin 1999
  ;     Conversion en ISQL.
*/
Create View vxlo_dsc 
      ( xlocle,
        xlodsc )
As
 Select xlo.xlocle,
        xlo.xlodscfra
   From gslocal xlo;
