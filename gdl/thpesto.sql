set term !! ;
Create Trigger thpesto For mchis_projet_eng
Before Insert
Position 0 As
/* Ajout dans la relation MCHIS_PROJET_ENG
 ;
 ;/P/ Programmeur..: Steeve Duguay
 ;    Date Création: 7 Février 1995
 ;  
 ;    Description..: On peut faire que des ajouts dans cette table, ils sont
 ;                   faits lors des journalisations par des programmes QTP.
 ;
 ;                   Mise à jour des budgets comptables des projets et      
 ;                   sous-projets ainsi que pour l'année financière.
 ;
 ;/M/ François Déry, 3 juin 1999
 ;      Conversion en ISQL.
*/
Declare Variable t_pecann Char(2);
Declare Variable t_pecnum Char(2);
Declare Variable t_coddc  Char(1);
/* Mise à jour des montants */
Declare Variable t_eng    Double Precision;
Declare Variable t_eng01  Double Precision;
Declare Variable t_eng02  Double Precision;
Declare Variable t_eng03  Double Precision;
Declare Variable t_eng04  Double Precision;
Declare Variable t_eng05  Double Precision;
Declare Variable t_eng06  Double Precision;
Declare Variable t_eng07  Double Precision;
Declare Variable t_eng08  Double Precision;
Declare Variable t_eng09  Double Precision;
Declare Variable t_eng10  Double Precision;
Declare Variable t_eng11  Double Precision;
Declare Variable t_eng12  Double Precision;
Declare Variable t_eng13  Double Precision;
Declare Variable t_eng14  Double Precision;

Begin
/*
  Recherche des informations pour la mise à jour
*/
  t_pecann = prosig_extract(1,2,New.peccle," ");
  t_pecnum = prosig_extract(3,2,New.peccle," ");
  Select cptcoddc
    From mccompte
   Where cptcle = New.cptcle
    Into :t_coddc;
/*
  Calcul des montants à mettre à jour
*/
  If ( :t_coddc = "C" )
  Then t_eng = New.hpemntcrt - New.hpemntdbt;
  Else t_eng = New.hpemntdbt - New.hpemntcrt;

  If ( "01" = :t_pecnum )
  Then t_eng01 = t_eng;
  Else t_eng01 = 0;
  If ( "02" = :t_pecnum )
  Then t_eng02 = t_eng;
  Else t_eng02 = 0;
  If ( "03" = :t_pecnum )
  Then t_eng03 = t_eng;
  Else t_eng03 = 0;
  If ( "04" = :t_pecnum )
  Then t_eng04 = t_eng;
  Else t_eng04 = 0;
  If ( "05" = :t_pecnum )
  Then t_eng05 = t_eng;
  Else t_eng05 = 0;
  If ( "06" = :t_pecnum )
  Then t_eng06 = t_eng;
  Else t_eng06 = 0;
  If ( "07" = :t_pecnum )
  Then t_eng07 = t_eng;
  Else t_eng07 = 0;
  If ( "08" = :t_pecnum )
  Then t_eng08 = t_eng;
  Else t_eng08 = 0;
  If ( "09" = :t_pecnum )
  Then t_eng09 = t_eng;
  Else t_eng09 = 0;
  If ( "10" = :t_pecnum )
  Then t_eng10 = t_eng;
  Else t_eng10 = 0;
  If ( "11" = :t_pecnum )
  Then t_eng11 = t_eng;
  Else t_eng11 = 0;
  If ( "12" = :t_pecnum )
  Then t_eng12 = t_eng;
  Else t_eng12 = 0;
  If ( "13" = :t_pecnum )
  Then t_eng13 = t_eng;
  Else t_eng13 = 0;
  If ( "14" = :t_pecnum )
  Then t_eng14 = t_eng;
  Else t_eng14 = 0;
/*
  Mise à jour du budget comptable du projet.
  Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Insert Into gppro_bdg_ctb
              ( ciecle, prjcle, cptcle, unacle,
                pbcmntbdg, pbcmntbdgrev, pbcmntree, pbcmnteng,
                pbcdatbdg, pbcusrbdg,
                pbcdateng, pbcusreng,
                pbcdatree, pbcusrree )
         Select New.ciecle, New.prjcle, New.cptcle, New.unacle,
                0, 0, 0, 0,
                "17-NOV-1858", " ",
                "17-NOV-1858", " ",
                "17-NOV-1858", " "
           From mcholding 
          Where cienmc = "1"
            And Not Exists ( Select ciecle From gppro_bdg_ctb
                                          Where ciecle = New.ciecle
                                            And prjcle = New.prjcle
                                            And cptcle = New.cptcle
                                            And unacle = New.unacle );

  Update gppro_bdg_ctb Set pbcmnteng = pbcmnteng + :t_eng,
                           pbcdateng = "TODAY",
                           pbcusreng = User
                Where ciecle = New.ciecle
                  And prjcle = New.prjcle
                  And cptcle = New.cptcle
                  And unacle = New.unacle;
/*
    Mise à jour du budget comptable du sou-projet.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Insert Into gppra_bdg_ctb
              ( ciecle, prjcle, pracle, cptcle, unacle,
                pacmntbdg, pacmntbdgrev, pacmntree, pacmnteng,
                pacdatbdg, pacusrbdg,
                pacdateng, pacusreng,
                pacdatree, pacusrree )
         Select New.ciecle, New.prjcle, New.pracle, New.cptcle, New.unacle,
                0, 0, 0, 0,
                "17-NOV-1858", " ",
                "17-NOV-1858", " ",
                "17-NOV-1858", " "
           From mcholding
          Where cienmc = "1"
            And Not Exists ( Select ciecle From gppra_bdg_ctb
                                          Where ciecle = New.ciecle
                                            and prjcle = New.prjcle
                                            and pracle = New.pracle
                                            and cptcle = New.cptcle
                                            and unacle = New.unacle );
  Update gppra_bdg_ctb Set pacmnteng = pacmnteng + :t_eng,
                           pacdateng = "TODAY",
                           pacusreng = User
                Where ciecle = New.ciecle
                  And prjcle = New.prjcle
                  And pracle = New.pracle
                  And cptcle = New.cptcle
                  And unacle = New.unacle;
/*
    Mise à jour du budget comptable de l'immobilisation.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Insert Into imimm_bdg_ctb 
              ( ciecle, immcle, cptcle, unacle,
                ibcmntbdg, ibcmntbdgrev, ibcmnteng, ibcmntree,
                ibcdatbdg, ibcusrbdg,
                ibcdateng, ibcusreng,
                ibcdatree, ibcusrree )
         Select New.ciecle, New.immcle, New.cptcle, New.unacle,
                0, 0, 0, 0,
                "17-NOV-1858", " ",
                "17-NOV-1858", " ",
                "17-NOV-1858", " "
           From mcholding
          Where cienmc = "1"
            And Not Exists ( Select ciecle From imimm_bdg_ctb
                                          Where ciecle = New.ciecle
                                            and immcle = New.immcle
                                            and cptcle = New.cptcle
                                            and unacle = New.unacle );

  Update imimm_bdg_ctb Set ibcmnteng = ibcmnteng + :t_eng,
                           ibcdateng = "TODAY",
                           ibcusreng = User
                Where ciecle = New.ciecle
                  And immcle = New.immcle
                  And cptcle = New.cptcle
                  And unacle = New.unacle;
/*
    Mise à jour du budget comptable du projet pour l'année financière.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Insert Into gppbc_annee
              ( ciecle, pbaann, prjcle, cptcle, unacle, 
                pbamntbdg, pbamntbdgrev,
                pbamntree1  , pbamntree2  , pbamntree3  , pbamntree4  ,
                pbamntree5  , pbamntree6  , pbamntree7  , pbamntree8  ,
                pbamntree9  , pbamntree10 , pbamntree11 , pbamntree12 ,
                pbamntree13 , pbamntree14 ,
                pbamnteng1  , pbamnteng2  , pbamnteng3  , pbamnteng4  ,
                pbamnteng5  , pbamnteng6  , pbamnteng7  , pbamnteng8  ,
                pbamnteng9  , pbamnteng10 , pbamnteng11 , pbamnteng12 ,
                pbamnteng13 , pbamnteng14 ,
                pbadatbdg   , pbausrbdg   ,
                pbadateng   , pbausreng   ,
                pbadatree   , pbausrree )
         Select New.ciecle, :t_pecann, New.prjcle, New.cptcle, New.unacle,
                0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0,
                "17-NOV-1858", " ",
                "17-NOV-1858", " ",
                "17-NOV-1858", " "
           From mcholding
          Where cienmc = "1"
            And Not Exists ( Select ciecle From gppbc_annee
                                          Where ciecle = New.ciecle
                                            And pbaann = :t_pecann
                                            And prjcle = New.prjcle
                                            And cptcle = New.cptcle
                                            And unacle = New.unacle );

  Update gppbc_annee Set pbamnteng1  = pbamnteng1  + :t_eng01,
                         pbamnteng2  = pbamnteng2  + :t_eng02,
                         pbamnteng3  = pbamnteng3  + :t_eng03,
                         pbamnteng4  = pbamnteng4  + :t_eng04,
                         pbamnteng5  = pbamnteng5  + :t_eng05,
                         pbamnteng6  = pbamnteng6  + :t_eng06,
                         pbamnteng7  = pbamnteng7  + :t_eng07,
                         pbamnteng8  = pbamnteng8  + :t_eng08,
                         pbamnteng9  = pbamnteng9  + :t_eng09,
                         pbamnteng10 = pbamnteng10 + :t_eng10,
                         pbamnteng11 = pbamnteng11 + :t_eng11,
                         pbamnteng12 = pbamnteng12 + :t_eng12,
                         pbamnteng13 = pbamnteng13 + :t_eng13,
                         pbamnteng14 = pbamnteng14 + :t_eng14
                Where ciecle = New.ciecle
                  And pbaann = :t_pecann
                  And prjcle = New.prjcle
                  And cptcle = New.cptcle
                  And unacle = New.unacle;
/*
    Mise à jour du budget comptable du projet pour l'année financière.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Insert Into gppac_annee
              ( ciecle, paaann, prjcle, pracle, cptcle, unacle,
                paamntbdg  , paamntbdgrev,
                paamntree1 , paamntree2 , paamntree3 , paamntree4 ,
                paamntree5 , paamntree6 , paamntree7 , paamntree8 ,
                paamntree9 , paamntree10, paamntree11, paamntree12,
                paamntree13, paamntree14,
                paamnteng1 , paamnteng2 , paamnteng3 , paamnteng4 ,
                paamnteng5 , paamnteng6 , paamnteng7 , paamnteng8 ,
                paamnteng9 , paamnteng10, paamnteng11, paamnteng12,
                paamnteng13, paamnteng14,
                paadatbdg  , paausrbdg  ,
                paadateng  , paausreng  ,
                paadatree  , paausrree  )
         Select New.ciecle, :t_pecann, New.prjcle, New.pracle, New.cptcle, 
                                                               new.unacle,
                0, 0, 
                0, 0, 0, 0, 
                0, 0, 0, 0, 
                0, 0, 0, 0, 
                0, 0,
                0, 0, 0, 0, 
                0, 0, 0, 0, 
                0, 0, 0, 0, 
                0, 0,
                "17-NOV-1858", " ",
                "17-NOV-1858", " ",
                "17-NOV-1858", " "
           From mcholding
          Where cienmc = "1"
            And Not Exists ( Select ciecle From gppac_annee
                                          Where ciecle = New.ciecle
                                            And paaann = :t_pecann
                                            And prjcle = New.prjcle
                                            And pracle = New.pracle
                                            And cptcle = New.cptcle
                                            And unacle = New.unacle );

  Update gppac_annee Set paamnteng1  = paamnteng1  + :t_eng01,
                         paamnteng2  = paamnteng2  + :t_eng02,
                         paamnteng3  = paamnteng3  + :t_eng03,
                         paamnteng4  = paamnteng4  + :t_eng04,
                         paamnteng5  = paamnteng5  + :t_eng05,
                         paamnteng6  = paamnteng6  + :t_eng06,
                         paamnteng7  = paamnteng7  + :t_eng07,
                         paamnteng8  = paamnteng8  + :t_eng08,
                         paamnteng9  = paamnteng9  + :t_eng09,
                         paamnteng10 = paamnteng10 + :t_eng10,
                         paamnteng11 = paamnteng11 + :t_eng11,
                         paamnteng12 = paamnteng12 + :t_eng12,
                         paamnteng13 = paamnteng13 + :t_eng13,
                         paamnteng14 = paamnteng14 + :t_eng14
                Where ciecle = New.ciecle
                  And paaann = :t_pecann
                  And prjcle = New.prjcle
                  And pracle = New.pracle
                  And cptcle = New.cptcle
                  And unacle = New.unacle;
/*
    Mise à jour du budget comptable de l'immobilisation pour l'année financière.
    Si l'enregistrement n'existe pas il faut le créer, sinon on le met à jour.
*/
  Insert Into imibc_annee 
              ( ciecle, ibaann, immcle, cptcle, unacle,
                ibamntree1 , ibamntree2 , ibamntree3 , ibamntree4 , 
                ibamntree5 , ibamntree6 , ibamntree7 , ibamntree8 , 
                ibamntree9 , ibamntree10, ibamntree11, ibamntree12, 
                ibamntree13, ibamntree14, 
                ibamnteng1 , ibamnteng2 , ibamnteng3 , ibamnteng4 , 
                ibamnteng5 , ibamnteng6 , ibamnteng7 , ibamnteng8 , 
                ibamnteng9 , ibamnteng10, ibamnteng11, ibamnteng12, 
                ibamnteng13, ibamnteng14 )
         Select New.ciecle, :t_pecann, New.immcle, New.cptcle, New.unacle,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0
           From mcholding
          Where cienmc = "1"
            And Not Exists ( Select ciecle From imibc_annee
                                          Where ciecle = New.ciecle
                                            And ibaann = :t_pecann
                                            And immcle = New.immcle
                                            And cptcle = New.cptcle     
                                            And unacle = New.unacle );

  Update imibc_annee Set ibamnteng1  = ibamnteng1  + :t_eng01,
                         ibamnteng2  = ibamnteng2  + :t_eng02,
                         ibamnteng3  = ibamnteng3  + :t_eng03,
                         ibamnteng4  = ibamnteng4  + :t_eng04,
                         ibamnteng5  = ibamnteng5  + :t_eng05,
                         ibamnteng6  = ibamnteng6  + :t_eng06,
                         ibamnteng7  = ibamnteng7  + :t_eng07,
                         ibamnteng8  = ibamnteng8  + :t_eng08,
                         ibamnteng9  = ibamnteng9  + :t_eng09,
                         ibamnteng10 = ibamnteng10 + :t_eng10,
                         ibamnteng11 = ibamnteng11 + :t_eng11,
                         ibamnteng12 = ibamnteng12 + :t_eng12,
                         ibamnteng13 = ibamnteng13 + :t_eng13,
                         ibamnteng14 = ibamnteng14 + :t_eng14
                Where ciecle = New.ciecle
                  And ibaann = :t_pecann
                  And immcle = New.immcle 
                  And cptcle = New.cptcle 
                  And unacle = New.unacle;
end !!
set term ; !!
