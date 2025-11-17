/* Vue sur ARPRODUIT et ARPRD_ENT
*
* Programmeur..: Guy Chabot
* Date création: 21 Février 1994
*
* Cumulatif des quantités à l'intérieur de toutes les entrepôts.  ;
*
* Description..: Cette vue permet de visionner le cumulatif des qtes
*                en demande, en commande et en main pour l'ensemble
*                des entrepôts pour les produits de type Inventorié ou
*                Non-inventorié.
*
*                Est utilisés que pour les produits inventoriés.
*
*                Est utilisée dans le panorama du produit.
*
*
* /M/ Patrick Langlois, 7 juin 1999
*     Conversion en ISQL
*
*/

/* V_PRDQTEDEM Quantité en demande ( dans les réquisitions )  */
/* V_PRDQTECOM Quantité en commande ( dans les commandes )    */
/* V_PRDQTEPHY Quantité en main ( dans les entrepôts )        */

create view VPRD_01
  (CIECLE,
   PRDCLE,
   V_PRDQTEDEM ,
   V_PRDQTECOM ,
   V_PRDQTEPHY ,
   V_PRDCOUMYN ,
   V_PRDDERCOU ,
   V_PRDQTEMAX ,
   V_PRDPOICOM  )
as
  select PRD.CIECLE,
         PRD.PRDCLE,
         prosig_nvln( ( Select Sum(  PRE.PREQTEDEM ) from ARPRD_ENT PRE
                              where  PRE.CIECLE = PRD.CIECLE
                                and  PRE.PRDCLE = PRD.PRDCLE)),
         prosig_nvln( ( Select Sum(  PRE.PREQTECOM ) from ARPRD_ENT PRE
                              where  PRE.CIECLE = PRD.CIECLE
                                and  PRE.PRDCLE = PRD.PRDCLE)),
         prosig_nvln( ( Select Sum(  PRE.PREQTEPHY ) from ARPRD_ENT PRE
                              where  PRE.CIECLE = PRD.CIECLE
                                and  PRE.PRDCLE = PRD.PRDCLE)),
         prosig_nvln( ( Select Avg(  PRE.PRECOUMYN ) from ARPRD_ENT PRE
                              where  PRE.CIECLE = PRD.CIECLE
                                and  PRE.PRDCLE = PRD.PRDCLE 
                                and (PRE.PRECOUMYN <> 0 
                                 or  PRE.PREQTEDEM <> 0 
                                 or  PRE.PREQTECOM <> 0 
                                 or  PRE.PREQTEPHY <> 0))),
         prosig_nvln( ( Select Avg(  PRE.PREDERCOU ) from ARPRD_ENT PRE
                              where  PRE.CIECLE = PRD.CIECLE
                                and  PRE.PRDCLE = PRD.PRDCLE
                                and  PRE.PREDERCOU <> 0)),
         prosig_nvln( ( Select Avg(  PRE.PREQTEMAX ) from ARPRD_ENT PRE
                              where  PRE.CIECLE = PRD.CIECLE
                                and  PRE.PRDCLE = PRD.PRDCLE
                                and (PRE.PREQTEMAX <> 0 
                                 or  PRE.PREQTEDEM <> 0 
                                 or  PRE.PREQTECOM <> 0 
                                 or  PRE.PREQTEPHY <> 0))),
         prosig_nvln( ( Select Avg(  PRE.PREPOICOM ) from ARPRD_ENT PRE
                              where  PRE.CIECLE = PRD.CIECLE
                                and  PRE.PRDCLE = PRD.PRDCLE
                                and (PRE.PREPOICOM <> 0 
                                 or  PRE.PREQTEDEM <> 0 
                                 or  PRE.PREQTECOM <> 0 
                                 or  PRE.PREQTEPHY <> 0)))

  from ARPRODUIT      PRD
  where PRD.PRDTYP != 'D';
