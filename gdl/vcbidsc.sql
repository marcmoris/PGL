/* VCBI_DSC Permet d'avoir la description dans la langue voulue.

   ;---------------------------------------------------------------------------
   ;/T/ Vue bilingue pour les codes bilingues.
   ;
   ;/P/ Programmeur..: Guy Chabot
   ;    Date Création: 15 Octobre 1992
   ;
   ;    Description..:  
   ;         Programme de création d'une vue pour extraire la description
   ;         des codes bilingue selon la langue de l'usager.
   ;             
   ;/M/ François Déry , 7 juin 1999
   ;    Conversion en ISQL.
*/
Create View vcbi_dsc 
      ( XELNOM,
        CBICLE,
        CBIDSC )
As
 Select CBI.XELNOM,
        CBI.CBICLE,
        CBI.CBIDSCFRA
   From mccode_bilingue cbi;

