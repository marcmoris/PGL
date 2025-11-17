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
   ;    Créer Par : Patrick Langlois 
   ;
   ;    Description..: Document 000054 de PGL
   ;                   Sélection de tout les types de comptes 
   ;
   ;                 - Diffère de la vue VCPT_DSC seulement par le type
   ;---------------------------------------------------------------------------
*/
Create View vcpt_dsc2
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
   From mccompte cpt;
