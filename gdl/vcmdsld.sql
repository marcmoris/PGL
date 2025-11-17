/* Vue sur ARCOMMANDE, et ARCMD_HISTO
*
* Pour consulter les ajustements à la commande.
* 
* /M/ Patrick Langlois, 7 juin 1999
*     Conversion en ISQL 
*
*
*/

create view VCMD_SLD

 (CIECLE,
  CMDCLE,
  CMDAJT,
  V_CMDMNTAJT,
  V_CMDMNTTPS,
  V_CMDMNTTVQ,
  V_CMDMNTCTI,
  V_CMDMNTRTI,
  V_CMDMNTNET)
as
select CMD.CIECLE,
       CMD.CMDCLE,
       CMD.CMDAJT,
       prosig_nvln( ( Select Sum( CMH.CMHMNT ) from ARCMD_HISTO CMH
                                 where CMH.CIECLE = CMD.CIECLE
                                   and CMH.CMDCLE = CMD.CMDCLE
                                   and CMH.CMDAJT = CMD.CMDAJT
                                   and CMH.CMHTYP = 'AJ')),                      
       prosig_nvln( ( Select Sum( CMH.CMHMNTTPS ) from ARCMD_HISTO CMH
                                 where CMH.CIECLE = CMD.CIECLE
                                   and CMH.CMDCLE = CMD.CMDCLE
                                   and CMH.CMDAJT = CMD.CMDAJT
                                   and CMH.CMHTYP = 'AJ')),                      
       prosig_nvln( ( Select Sum( CMH.CMHMNTTVQ ) from ARCMD_HISTO CMH
                                 where CMH.CIECLE = CMD.CIECLE
                                   and CMH.CMDCLE = CMD.CMDCLE
                                   and CMH.CMDAJT = CMD.CMDAJT
                                   and CMH.CMHTYP = 'AJ')),                      
       prosig_nvln( ( Select Sum( CMH.CMHMNTCTI ) from ARCMD_HISTO CMH
                                 where CMH.CIECLE = CMD.CIECLE
                                   and CMH.CMDCLE = CMD.CMDCLE
                                   and CMH.CMDAJT = CMD.CMDAJT
                                   and CMH.CMHTYP = 'AJ')),                      
       prosig_nvln( ( Select Sum( CMH.CMHMNTRTI ) from ARCMD_HISTO CMH
                                 where CMH.CIECLE = CMD.CIECLE
                                   and CMH.CMDCLE = CMD.CMDCLE
                                   and CMH.CMDAJT = CMD.CMDAJT
                                   and CMH.CMHTYP = 'AJ')),                      
       prosig_nvln( ( Select Sum( CMH.CMHMNTNET ) from ARCMD_HISTO CMH
                                 where CMH.CIECLE = CMD.CIECLE
                                   and CMH.CMDCLE = CMD.CMDCLE
                                   and CMH.CMDAJT = CMD.CMDAJT
                                   and CMH.CMHTYP = 'AJ'))                      
  from ARCOMMANDE CMD
    where CMD.CMDTYP = 'CM';
