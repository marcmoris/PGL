Create View vdiaqteaut
      (pjtabr,          
       dianumdia001,    
       dianumdia002,    
       ciecle,          
       comnumcom,
       dianum002,
       dcinumlig,
       diaqtepladbtgra, 
       diaqteplafingra, 
       diaqtefingra)    
As
 Select dia.pjtabr,
        dia.dianumdia001,
        dia.dianumdia002,
        dia.ciecle,
        dia.comnumcom,
        dia.dianum002,
        dia.dcinumlig,
        prosig_nvln( ( Select Sum( pdg.pdgqteplacpegra ) 
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqteplafingra )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) ),
        prosig_nvln( ( Select Sum( pdg.pdgqtefinprdgra )
                         From pdpriorite_diag pdg
                        Where dia.ciecle    = pdg.ciecle 
                          And dia.dianum002 = pdg.dianum002 ) )
   From pddiagramme dia;
