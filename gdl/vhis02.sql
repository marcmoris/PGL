/* VHIS_02 Permet d'avoir le maitre et détail d'écriture ensemble.
  ;/T/ Vue sur MCHISTO_ENG et MCHIS_ECR_ENG
  ;
  ;/P/ Programmeur..: Steeve Duguay
  ;    Date création: Le 9 février 1995
  ;    Description..: Lien entre les tables MCHISTO_ENG ET MCHIS_ECR_ENG
  ;                   dans le but de faciliter la réalisation des rapports.
  ;
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL.
*/      
Create View vhis_02 
As
 Select hen.hencle,
        hen.henciecle,
        hen.refciecle,
        hen.refcletyp,
        hen.refclenum,
        hen.hennumdoc,
        hen.sanann,
        hee.peccle,
        hen.hennumlot,
        hen.hendat,
        hen.hendatjou,
        hen.hencodmod,
        hen.hentypecr,
        hen.hendscgen,
        hen.hendscsai,
        hen.hendscsai2,
        hen.henusrcre,
        hen.hencle1,
        hen.hencle2,
        hen.hencle3,
        hen.devcle,
        hee.cptcle,
        hee.ciecle,
        hee.unacle,
        hee.heenumdoc2,
        hee.heemntdbt,
        hee.heemntcrt,
        hee.heemntdbtori,
        hee.heemntcrtori,
        hee.heeflgint
   From mchis_ecr_eng hee,
        mchisto_eng   hen
  Where hen.hencle = hee.hencle;
