/* ;---------------------------------------------------------------------------
   ;/T/ Vue bilingue pour les termes.
   ;
   ;/P/ Programmeur..: Alain Côté
   ;    Date Création: 18 mai 1993
   ;
   ;    Description..:  Le but est de retourner la description française ou
   ;                    anglaise du terme selon la langue.
   ;             
   ;/M/ François Déry, 8 juin 1999
   ;    Conversion en ISQL.
*/
Create View vtme_dsc 
      ( tmecle,
        tmecat,
        tmetypcal,
        tmenbrjrsajt,
        tmenbrjrsdel,
        tmenbrmoi,
        tmepct,
        tmedsc,
        tmedscabr )
As
 select tme.tmecle,
        tme.tmecat,
        tme.tmetypcal,
        tme.tmenbrjrsajt,
        tme.tmenbrjrsdel,
        tme.tmenbrmoi,
        tme.tmepct,
        tme.tmedscfra,
        tme.tmedscabrfra
   From crterme tme;
