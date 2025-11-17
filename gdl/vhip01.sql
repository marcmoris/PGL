/*
  ;/T/ Vue sur MCHIS_PROJET et MCHISTO...
  ;
  ;/P/ Programmeur..: Alain Côté
  ;    Date création: 12 octobre 1993
  ;    Description..: Lien entre les tables MCHIS_PROJET, MCHISTO, GPPROJET
  ;                   et GPACTIVITE dans le but de faciliter la réalisation
  ;                   des rapports.
  ;
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL.
*/
Create view vhip_01
As
 Select his.hiscle,
        his.refciecle,
        his.refcletyp,
        his.refclenum,
        his.hisnumdoc,
        his.peccle,
        his.hisnumlot,
        his.hisdat,
        his.hiscodmod,
        his.histypecr,
        his.hisdscgen,
        his.hisdscsai,
        his.hisdscsai2,
        hip.ciecle,   
        hip.procle,    
        hip.actcle,   
        hip.unicat,   
        hip.unicle,   
        hip.unacle,   
        hip.cptcle,  
        hip.hipmntdbt,   
        hip.hipmntcrt, 
        pro.prodsc   ,      
        pro.prodsc2  ,      
        pro.probdg   ,      
        pro.prostu   ,      
        pro.prodatdeb,      
        pro.prodatfin,      
        pro.prorps   ,
        act.actstu   ,
        act.actbdg   ,
        act.actrps   ,
        act.actdatfin
   From mchis_projet hip,
        mchisto      his,
        gpprojet     pro,
        gpactivite   act
  Where hip.hiscle = his.hiscle 
    And hip.ciecle = pro.ciecle 
    And hip.procle = pro.procle
    And hip.ciecle = act.ciecle 
    And hip.procle = act.procle
    And hip.actcle = act.actcle;
            
