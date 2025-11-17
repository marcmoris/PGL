/* VTAX_DSC Permet d'avoir la description dans la bonne langue.
   ;---------------------------------------------------------------------------
   ;/T/ Vue bilingue pour les taxes gouvernementales.
   ;
   ;/P/ Programmeur..: Guy Chabot
   ;    Date Création: 17-Mar-1992
   ;
   ;    Description..:  
   ;         Programme de création d'une vue pour extraire la description
   ;         des taxes selon la langue de l'usager.
   ;             
   ;  Modifier par : Marc Morissette
   ;
   ;/M/ François Déry, 8 juin 1999
   ;    Conversion en ISQL.
*/
Create View vtax_dsc
      ( taxcletyp ,
        taxclecod ,
        taxmod    ,
        taxflgnet ,
        taxpct    ,
        taxpctcti ,
        taxcptcticap,
        taxcptcar ,
        taxdsc )
As
 Select tax.taxcletyp ,
        tax.taxclecod ,
        tax.taxmod    ,
        tax.taxflgnet ,
        tax.taxpct    ,
        tax.taxpctcti ,
        tax.taxcptcticap,
        tax.taxcptcar ,
        tax.taxdscfra
   From mctaxe tax;
