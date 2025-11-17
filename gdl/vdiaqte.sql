/*
  Défini des champs calculé pour éviter de les recalculer dans tout les 
  traitements

;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
*/
Create View vdiaqte 
      ( pjtabr,
        dianumdia001,
        dianumdia002,
        ciecle,
        diaqtepladbt,
        diaqtepladbtgra,
        diaqtepladbtusc,
        diaqtepladbtsct,
        diaqteplafin,
        diaqteplafingra,
        diaqteplafinusc,
        diaqteplafinsct,
        diaqtedbt,
        diaqtedbtgra,
        diaqtedbtusc,
        diaqtedbtsct,
        diaqtefin,
        diaqtefingra,
        diaqtefinusc,
        diaqtefinsct )
As
 Select dia.pjtabr,
        dia.dianumdia001,
        dia.dianumdia002,
        dia.ciecle,
/*
  Champ calculé
*/
        prosig_nvln( ( Select Sum(   pdg.pdgqteplacpegra 
                                   + pdg.pdgqteplacpesct 
                                   + pdg.pdgqteplacpeusc ) 
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqteplacpegra ) 
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqteplacpeusc ) 
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqteplacpesct ) 
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum(   pdg.pdgqteplafingra 
                                   + pdg.pdgqteplafinusc 
                                   + pdg.pdgqteplafinsct ) 
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqteplafingra )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqteplafinusc )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqteplafinsct ) 
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
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqtecpercuusc )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqtecpercusct )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum(   pdg.pdgqtefinprdgra 
                                   + pdg.pdgqtefinrcuusc 
                                   + pdg.pdgqtefinrcusct )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqtefinprdgra )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqtefinrcuusc )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqtefinrcusct )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) )
   From pddiagramme dia;
