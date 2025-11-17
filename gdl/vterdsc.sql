/* ;---------------------------------------------------------------------------
   ;/T/ Vue bilingue pour les termes.
   ;
   ;/P/ Programmeur..: Guy Chabot
   ;    Date Création: 17-Mar-1992
   ;
   ;    Description..:  
   ;         Programme de création d'une vue pour extraire la description
   ;         des termes selon la langue de l'usager.
   ;             
   ;/M/ François Déry, 8 juin 1999
   ;    Conversion en ISQL.
*/
Create View vter_dsc
      ( tercle,
        tercat,
        tertypcal,
        ternbrjrsajt,
        ternbrjrsdel,
        ternbrmoi,
        terpct,
        terdsc,
        terdscabr )
As
 Select ter.tercle,
        ter.tercat,
        ter.tertypcal,
        ter.ternbrjrsajt,
        ter.ternbrjrsdel,
        ter.ternbrmoi,
        ter.terpct,
        ter.terdscfra,
        ter.terdscabrfra
   From cpterme ter;
