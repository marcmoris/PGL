/* VHIS_01 Permet d'avoir le maitre et détail d'écriture ensemble.
  ;/T/ Vue sur GLHISTO et GLHIS_ECR
  ;
  ;/P/ Programmeur..: Alain Côté
  ;    Date création: 17 juin mai 1992
  ;    Description..: Lien entre les tables GLHISTO et GLHIS_ECR 
  ;                   dans le but de faciliter la réalisation des rapports.
  ;
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL.
*/
Create View vhis_01 
As 
 Select his.hiscle,
        his.hisciecle,
        his.refciecle,
        his.refcletyp,
        his.refclenum,
        his.hisnumdoc,
        his.sanann,
        hec.peccle,
        his.hisnumlot,
        his.hisdat,
        his.hisdatjou,
        his.hiscodmod,
        his.histypecr,
        his.hisdscgen,
        his.hisdscsai,
        his.hisdscsai2,
        his.hisusrcre,
        his.hiscle1,
        his.hiscle2,
        his.hiscle3,
        his.devcle,
        hec.cptcle,
        hec.ciecle,
        hec.unacle,
        hec.hecnumdoc2,
        hec.hecmntdbt,
        hec.hecmntcrt,
        hec.hecmntdbtori,
        hec.hecmntcrtori,
        hec.hecflgint
   From mchis_ecr hec,
        mchisto   his
  Where his.hiscle = hec.hiscle;
