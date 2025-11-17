/* VRAD_01 Permet d'avoir sur le détail des adresses le maitre pour cli/fou
;/T/ Vue sur MCREF_ADRESSE avec devise
;
;/P/ Programmeur: Alain Côté
;    Date création: 27 mai 1992
;    Description..: Lien entre les tables MCREF_ADRESSE et MCREFERENCE pour
;                   avoir la devise de la référence dans le but de faciliter
;                   la réalisation des rapports.
;
;/M/ François Déry, 8 juin 1999
;       Conversion en ISQL
*/
Create View vrad_01
As
 Select ref.refciecle,
        ref.refcletyp,
        ref.refclenum,
        rad.radcle   ,
        rad.radnom   ,
        rad.radnomabr,
        rad.radadr1  ,
        rad.radadr2  ,
        rad.radadr3  ,
        rad.radadr4  ,
        rad.radcp    ,
        rad.radtel   ,
        rad.radfax   ,
        rad.radpamcp ,
        rad.radachcp ,
        rad.radretcp ,
        rad.radlivcr ,
        rad.radfaccr ,
        rad.radetacptcr,
        rad.radenrtps,
        rad.radenrtvq,
        ref.devcle,
        ref.refstu,
        ref.reffourtu
   From mcref_adresse rad,
        mcreference   ref
  Where ref.refciecle = rad.refciecle
    And ref.refcletyp = rad.refcletyp
    And ref.refclenum = rad.refclenum;
