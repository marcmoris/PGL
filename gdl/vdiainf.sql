/*
  Défini des champs calculé pour éviter de les recalculer dans tout les 
  traitements

;/M/ Marc Poulin, 03 juillet 2001

*/
Create View vdiainf 
      ( dianumdia002       , 
        ciecle             , 
        pjtabr             ,
        dianumdia001       ,
        tyfcodfin          ,
        tgrcodgra          ,
        comnumcomint       ,
        pjtann             ,
        diaqteemb          ,
        diaqterej          ,
        diaqteexpusiscd    ,
        diaqteexpsct       ,
        diasurmc2          ,
        pjtnumpro          ,
        diaepa             ,
        dialon             ,
        diahau             ,
        dia.diaqtepladbtsct, 
        dia.diaqtedbt      ,
        dia.diaqtedbtgra )
As
 Select dianumdia002       , 
        ciecle             , 
        pjtabr             ,
        dianumdia001       ,
        tyfcodfin          ,
        tgrcodgra          ,
        comnumcomint       ,
        pjtann             ,
        diaqteemb          ,
        diaqterej          ,
        diaqteexpusiscd    ,
        diaqteexpsct       ,
        diasurmc2          ,
        pjtnumpro          ,
        diaepa             ,
        dialon             ,
        diahau             ,
/*
  Champ calculé
*/
        prosig_nvln( ( Select Sum( pdg.pdgqteplacpesct ) 
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum(   pdg.pdgqtecpeprdgra 
                                   + pdg.pdgqtecpercuusc 
                                   + pdg.pdgqtecpercusct )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqtecpeprdgra )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) )
   From pddiagramme dia 
  where dia.diastu = 'A';
