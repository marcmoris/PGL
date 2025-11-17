/* Vue sur PDCOMMAN_INTERNE, PDDIAGRAMME et PDPRIORITE_DIAG
*
* Pour conserver uniquement la commande interne
* 
* /M/ Marc Poulin, 8 novembre 1999
*
*
*/

create view vcomdiapdg
as
 select  com.pjtabr          ,
         com.ciecle          ,
         com.comnumcomint    ,
         com.pjtann          ,
         com.comstu          ,
         pdg.dianum002       ,
         pdg.dianumdia002    ,
         pdg.pricodpri       ,
         pdg.dcinumlig       ,
         pdg.comnumcom       
   from  pdcomman_interne com,
         pddiagramme      dia,
         pdpriorite_diag  pdg 
  where  com.pjtabr       = dia.pjtabr       and
         com.pjtann       = dia.pjtann       and
         com.comnumcomint = dia.comnumcomint and
         com.ciecle       = dia.ciecle       and
         dia.dianum002    = pdg.dianum002    and
         dia.ciecle       = pdg.ciecle ;
