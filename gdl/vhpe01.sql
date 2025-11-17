/*
  ;/T/ Vue sur MCHIS_PROJET_ENG et MCHISTO_ENG
  ;
  ;/P/ Programmeur..: Guy Chabot 
  ;    Date création: 8 mars 1995
  ;    Description..: 
  ;                   
  ;/M/ François Déry, 7 juin 1999                   
  ;     Conversion en ISQL.
  ;
*/
Create View vhpe_01
As
 Select hen.hencle,
        hen.henciecle,
        hen.refciecle,
        hen.refcletyp,
        hen.refclenum,
        hen.hennumdoc,
        hen.sanann,
        hen.hennumlot,
        hen.hendat,
        hen.hendatjou,
        hen.hencodmod,
        hen.hentypecr,
        hen.hencle1,
        hen.hencle2,
        hen.hencle3,
        hen.devcle,
        hpe.hpenumlig,
        hpe.peccle,
        hpe.prjcle,
        hpe.pracle,
        hpe.immcle,
        hpe.ciecle,
        hpe.cptcle,
        hpe.unacle,
        hpe.hpemntdbt,
        hpe.hpemntcrt
   From mchis_projet_eng hpe,
        mchisto_eng      hen
  where hpe.hencle = hen.hencle;
