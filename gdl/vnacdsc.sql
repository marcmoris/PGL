/* VNAC_DSC Permet d'avoir la description dans la bonne langue.
   ;---------------------------------------------------------------------------
   ;/T/ Vue bilingue des natures de compte.
   ;
   ;/P/ Programmeur..: Lyne Ferland
   ;    Date Création: 20 février 1992
   ;
   ;    Description..:  
   ;          Programme de création d'une vue pour extraire la description
   ;          des natures de compte selon la langue de l'usager.
   ;
   ; Modifier par : Marc Morissette
   ;
   ;/M/ François Déry, 8 juin 1999
   ;    Conversion en ISQL.
   ;---------------------------------------------------------------------------
*/
Create View vnac_dsc
      ( naccle,
        nacdsc,
        nacdscabr )
As 
 Select nac.naccle,
        nac.nacdscfra,
        nac.nacdscabrfra
   From mcnature_ctb nac;
