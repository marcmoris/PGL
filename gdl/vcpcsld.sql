 /* 
  ;/T/ Solde des cédules - Vue sur CPCAP_CEDULE et CPCAP_HISTO
  ;
  ;/P/ Programmeur..: Thomas Brenneur
  ;    Date création: 14 Juin 1993
  ;    Description..: Cette vue donne le solde d'une cédule de paiement
  ;                   d'un compte à payer. Note : on ne sélectionne que
  ;                   les historiques qui sont journalisés.
  ;
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL.
  */
Create View vcpc_sld 
      ( fouciecle,
        foucle,
        capcle,
        cpcclelig,
        cpcdatdue,
        cpcflgsel,
        v_cpcmntajt,
        v_cpcmntpye,
        v_cpcmntesc,
        v_cpcsld )
As 
 Select cpc.fouciecle,
        cpc.foucle,
        cpc.capcle,
        cpc.cpcclelig,
        cpc.cpcdatdue,
        cpc.cpcflgsel,
 /*
  ; Montant d'ajustement de la cédule.
  */
        prosig_nvln( ( Select Sum( cph.cphmntcap ) From cpcap_histo cph
                                     Where cph.fouciecle  = cpc.fouciecle 
                                       And cph.foucle     = cpc.foucle    
                                       And cph.capcle     = cpc.capcle
                                       And cph.cpcclelig  = cpc.cpcclelig
                                       And cph.cphdatjou != "17-NOV-1858"
                                       And cph.cphtyptra In ("AJ","AR","NC"))),
 /*
  ; Montant payé de la cédule
  */
        prosig_nvln( ( Select Sum( cph.cphmntpye ) From cpcap_histo cph
                                     Where cph.fouciecle  = cpc.fouciecle 
                                       And cph.foucle     = cpc.foucle    
                                       And cph.capcle     = cpc.capcle
                                       And cph.cpcclelig  = cpc.cpcclelig
                                       And cph.cphdatjou != "17-NOV-1858"
                                       And cph.cphtyptra In ("CH","CA") ) ),
 /*
  ; Montant d'escompte de la cédule
  */
        prosig_nvln( ( Select Sum( cph.cphmntesc ) From cpcap_histo cph
                                     Where cph.fouciecle  = cpc.fouciecle 
                                       And cph.foucle     = cpc.foucle    
                                       And cph.capcle     = cpc.capcle
                                       And cph.cpcclelig  = cpc.cpcclelig
                                       And cph.cphdatjou != "17-NOV-1858"
                                       And cph.cphtyptra In ( "CH","CA" ) ) ),
 /*
  ; Solde de la cédule
  */
        ( cpc.cpcmnt
          + prosig_nvln( ( Select Sum( cph.cphmntcap ) From cpcap_histo cph
                                     Where cph.fouciecle  = cpc.fouciecle 
                                       And cph.foucle     = cpc.foucle    
                                       And cph.capcle     = cpc.capcle
                                       And cph.cpcclelig  = cpc.cpcclelig
                                       And cph.cphdatjou != "17-NOV-1858"
                                       And cph.cphtyptra In ("AJ","AR","NC") ) )
          - prosig_nvln( ( Select Sum( cph.cphmntpye + cph.cphmntesc ) 
                                      From cpcap_histo cph
                                     Where cph.fouciecle  = cpc.fouciecle 
                                       And cph.foucle     = cpc.foucle    
                                       And cph.capcle     = cpc.capcle
                                       And cph.cpcclelig  = cpc.cpcclelig
                                       And cph.cphdatjou != "17-NOV-1858"
                                       And cph.cphtyptra In ("CH","CA") ) ) )
   From cpcap_cedule cpc;
