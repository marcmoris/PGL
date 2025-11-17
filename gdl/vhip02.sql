/*
  ;/T/ Vue sur MCHIS_PROJET et MCHISTO...
  ;
  ;/P/ Programmeur..: Guy Chabot 
  ;    Date création: 8 mars 1995
  ;    Description..: 
  ;                   
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL.
  ;
*/
Create View vhip_02
As
 Select his.hiscle,
        his.hisciecle,
        his.refciecle,
        his.refcletyp,
        his.refclenum,
        his.hisnumdoc,
        his.sanann,
        his.peccle,
        his.hisnumlot,
        his.hisdat,
        his.hisdatjou,
        his.hiscodmod,
        his.histypecr,
        his.hiscle1,
        his.hiscle2,
        his.hiscle3,
        his.devcle,
        hip.hipnumlig,
        hip.prjcle,
        hip.pracle,
        hip.immcle,
        hip.ciecle,
        hip.cptcle,
        hip.unacle,
        hip.hipmntdbt,
        hip.hipmntcrt
   From mchis_projet hip,
        mchisto      his
  Where hip.hiscle = his.hiscle;
