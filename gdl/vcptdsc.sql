/* VCPT_DSC Permet d'avoir la description du compte dans la bonne langue.
   ;---------------------------------------------------------------------------
   ;/T/ Vue bilingue pour les comptes.
   ;
   ;/P/ Programmeur..: Lyne Ferland
   ;    Date Création: 20 février 1992
   ;
   ;    Description..:  
   ;         Programme de création d'une vue pour extraire la description
   ;         des comptes selon la langue de l'usager.
   ;   
   ;    Modifier Par : Marc Morissette
   ;
   ;    Modifier Par : Patrick Langlois 
   ;
   ;    Description..: Document 000054 de PGL
   ;                   Sélection des comptes de type régulier seulement
   ;
   ;                 - Diffère de la vue VCPT_DSC2 seulement par le type
   ;
   ;/M/ François Déry, 7 juin 1999
   ;    Conversion en ISQL
*/
Create View vcpt_dsc 
      ( cptcle,
        cpttyp,
        cptpecdeba,
        cptpecdebi,
        naccle ,
        cptcoddc,
        cptnivdet,
        cptcat,
        cptcptlie,
        devcle,
        cptdsc,
        cptdscabr )
As
 Select cpt.cptcle,
        cpt.cpttyp,
        cpt.cptpecdeba,
        cpt.cptpecdebi,
        cpt.naccle ,
        cpt.cptcoddc,
        cpt.cptnivdet,
        cpt.cptcat,
        cpt.cptcptlie,
        cpt.devcle,
        cpt.cptdscfra,
        cpt.cptdscabrfra
   From mccompte cpt
  Where cpt.cpttyp = "R";
